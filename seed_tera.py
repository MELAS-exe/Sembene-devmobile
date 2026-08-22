"""
Tera backend seeding script — comprehensive DB population for testing.

Populates every table:
  - Users: warehouse admins, consumers
  - Drivers: name + phone passed inline when assigning to a delivery (no separate entity)
  - Catalog: products (with per-product billing rates and tags)
  - Stock: warehouses, INBOUND storage requests
    (~40% flagged as delegatedSale to exercise revenue tracking),
    OUTBOUND requests
  - Orders: 1-3 per consumer, auto-delivery (PENDING) via OrderCreatedEvent;
    single-warehouse first, multi-warehouse fallback if needed
  - Deliveries: PENDING → ASSIGNED → IN_TRANSIT → DELIVERED progression
  - Billing: a fraction of INBOUND requests completed (billingAmount from product rates)
  - Revenue: consumers whose delegated stock is sold accumulate totalRevenue

Usage:
    python seed_tera.py
    python seed_tera.py --base-url http://10.0.0.5:8080
    python seed_tera.py --reset-state

Requirements:
    pip install requests
"""

from __future__ import annotations

import argparse
import json
import random
import sys
import time
import unicodedata
from dataclasses import dataclass, field
from datetime import datetime, timedelta
from pathlib import Path
from typing import Any

import requests

# ---------------------------------------------------------------------------
# Config
# ---------------------------------------------------------------------------

# DEFAULT_BASE_URL = "https://backend.terasn.shop"
DEFAULT_BASE_URL = "http://localhost:8080"
SUPERADMIN_PHONE = "221772222224"
SUPERADMIN_PASSWORD = "AdminDefault"

STATE_FILE = Path(".seed_state.json")

# ---------------------------------------------------------------------------
# Data pools
# ---------------------------------------------------------------------------

FIRST_NAMES = [
    "Aminata", "Fatou", "Awa", "Mariama", "Khadija", "Aïssatou", "Bineta",
    "Ndèye", "Coumba", "Astou", "Mame Diarra", "Adja",
    "Moussa", "Cheikh", "Ibrahima", "Ousmane", "Mamadou", "Abdoulaye",
    "Babacar", "Modou", "Pape", "Souleymane", "Lamine", "Saliou",
    "Demba", "Birane", "Tidiane", "Assane", "Boubacar", "Serigne",
]

LAST_NAMES = [
    "Diop", "Ndiaye", "Diallo", "Faye", "Sow", "Ba", "Sy", "Gueye",
    "Mbaye", "Sarr", "Sall", "Niang", "Cissé", "Sène", "Thiam", "Wade",
    "Mendy", "Camara", "Touré", "Diouf", "Fall", "Sagna", "Diagne", "Kane",
]

PHONE_PREFIXES = ["70", "75", "76", "77", "78"]

DAKAR_ADDRESSES = [
    "Sacré-Coeur 3, Villa 412, Dakar",
    "Médina, Rue 15 x 22, Dakar",
    "Almadies, Cité Keur Gorgui, Dakar",
    "Liberté 6 Extension, Dakar",
    "Mermoz Sud, Lot 88, Dakar",
    "Thiès, Quartier Randoulène, Maison 24",
    "Saint-Louis, Sor, Pikine Tableau, Maison 7",
    "Kaolack, Quartier Ndorong, Maison 12",
    "Ziguinchor, Boucotte, Villa 5",
    "Touba, Quartier Darou Khoudoss, Lot 33",
]


@dataclass
class WarehouseSeed:
    name: str
    latitude: float
    longitude: float
    capacity: float


WAREHOUSES: list[WarehouseSeed] = [
    WarehouseSeed("Entrepôt Dakar Centre", 14.6928, -17.4467, 50000),
    WarehouseSeed("Entrepôt Thiès Nord",   14.7886, -16.9260, 35000),
    WarehouseSeed("Entrepôt Saint-Louis",  16.0179, -16.4896, 25000),
    WarehouseSeed("Entrepôt Kaolack",      14.1825, -16.2533, 40000),
    WarehouseSeed("Entrepôt Ziguinchor",   12.5681, -16.2719, 30000),
    WarehouseSeed("Entrepôt Touba",        14.8500, -15.8833, 45000),
]


@dataclass
class ProductSeed:
    name: str
    description: str
    unit: str
    price: float
    daily_rate: float     # XOF per day — standardised across all warehouses
    per_kg_rate: float    # XOF per kg per day
    tags: list[str] = field(default_factory=list)


PRODUCTS: list[ProductSeed] = [
    # Céréales — dry goods, basic storage
    ProductSeed("Mil souna",        "Mil traditionnel sénégalais, cultivé dans le bassin arachidier", "kg",  650.0, 300.0, 1.5, ["cereale", "sec", "local"]),
    ProductSeed("Riz de la Vallée", "Riz local de la vallée du fleuve Sénégal",                       "kg",  550.0, 280.0, 1.4, ["cereale", "sec", "local"]),
    ProductSeed("Maïs jaune",       "Maïs sec destiné à la consommation",                             "kg",  425.0, 260.0, 1.3, ["cereale", "sec"]),
    ProductSeed("Sorgho",           "Sorgho rouge cultivé en culture pluviale",                       "kg",  475.0, 270.0, 1.4, ["cereale", "sec"]),
    ProductSeed("Fonio brut",       "Fonio non transformé, récolte locale",                           "kg",  900.0, 350.0, 1.8, ["cereale", "sec", "bio"]),
    # Légumineuses — medium storage needs
    ProductSeed("Niébé",                   "Haricot niébé, riche en protéines",              "kg",  950.0, 380.0, 2.0, ["legumineuse", "sec", "proteine"]),
    ProductSeed("Arachide en coque",       "Arachide non décortiquée, récolte récente",      "kg",  700.0, 340.0, 1.8, ["legumineuse", "sec"]),
    ProductSeed("Arachide décortiquée",    "Arachide grains, prête à la vente directe",     "kg", 1100.0, 420.0, 2.2, ["legumineuse", "sec", "proteine"]),
    # Tubercules frais — climate-sensitive
    ProductSeed("Manioc frais",   "Manioc local, livré dans les 48h",             "kg",  350.0, 550.0, 2.8, ["tubercule", "frais"]),
    ProductSeed("Patate douce",   "Patate douce à chair orange",                  "kg",  600.0, 520.0, 2.6, ["tubercule", "frais"]),
    ProductSeed("Igname",         "Igname blanche de Casamance",                  "kg",  850.0, 580.0, 3.0, ["tubercule", "frais", "local"]),
    # Légumes frais — high-turnover, temperature-controlled
    ProductSeed("Oignon de Potou", "Oignon local de la zone des Niayes",               "kg",  500.0, 620.0, 3.2, ["legume", "frais", "local"]),
    ProductSeed("Pomme de terre",  "Pomme de terre des Niayes, calibre moyen",         "kg",  800.0, 640.0, 3.3, ["legume", "frais"]),
    ProductSeed("Tomate fraîche",  "Tomate ronde des Niayes, récoltée à maturité",     "kg",  600.0, 680.0, 3.5, ["legume", "frais"]),
    ProductSeed("Piment antillais","Piment frais de la région de Thiès",               "kg", 1200.0, 700.0, 3.6, ["legume", "frais", "epice"]),
    ProductSeed("Gombo frais",     "Gombo vert récolté à la main",                     "kg",  750.0, 650.0, 3.3, ["legume", "frais", "local"]),
    ProductSeed("Aubergine locale","Aubergine africaine ronde, variété locale",         "kg",  550.0, 600.0, 3.1, ["legume", "frais", "local"]),
    # Fruits frais — highest storage cost
    ProductSeed("Mangue Kent",   "Mangue Kent de Casamance, mûre à point",   "kg", 1500.0, 780.0, 4.0, ["fruit", "frais", "casamance"]),
    ProductSeed("Pastèque",      "Pastèque de la zone des Niayes",           "kg",  400.0, 700.0, 3.5, ["fruit", "frais"]),
    ProductSeed("Banane douce",  "Banane locale de Tambacounda",             "kg",  750.0, 730.0, 3.8, ["fruit", "frais", "local"]),
]


# ---------------------------------------------------------------------------
# HTTP client
# ---------------------------------------------------------------------------

@dataclass
class TeraClient:
    base_url: str
    token: str | None = None

    def _headers(self, auth: bool = True) -> dict[str, str]:
        h = {"Content-Type": "application/json"}
        if auth and self.token:
            h["Authorization"] = f"Bearer {self.token}"
        return h

    def post(self, path: str, body: Any = None, auth: bool = True) -> requests.Response:
        return requests.post(
            f"{self.base_url}{path}",
            headers=self._headers(auth),
            data=json.dumps(body) if body is not None else None,
            timeout=15,
        )

    def get(self, path: str, params: dict | None = None) -> requests.Response:
        return requests.get(
            f"{self.base_url}{path}",
            headers=self._headers(),
            params=params,
            timeout=15,
        )

    def put(self, path: str) -> requests.Response:
        return requests.put(
            f"{self.base_url}{path}",
            headers=self._headers(),
            timeout=15,
        )

    def patch(self, path: str, params: dict | None = None, body: Any = None) -> requests.Response:
        return requests.patch(
            f"{self.base_url}{path}",
            headers=self._headers(),
            params=params,
            data=json.dumps(body) if body is not None else None,
            timeout=15,
        )

    def login(self, phone: str, password: str) -> None:
        r = self.post("/api/auth/login", {"phoneNumber": phone, "password": password}, auth=False)
        if r.status_code not in (200, 201):
            raise RuntimeError(f"Login failed for {phone}: {r.status_code} {r.text}")
        data = r.json()
        self.token = data["token"]


# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

def unique_phone(used: set[str]) -> str:
    for _ in range(1000):
        prefix = random.choice(PHONE_PREFIXES)
        digits = "".join(str(random.randint(0, 9)) for _ in range(7))
        phone = "221" + prefix + digits
        if phone not in used and phone != SUPERADMIN_PHONE:
            used.add(phone)
            return phone
    raise RuntimeError("Could not generate unique phone")


def _ascii(s: str) -> str:
    return "".join(
        c for c in unicodedata.normalize("NFD", s)
        if unicodedata.category(c) != "Mn"
    ).lower().replace(" ", ".")


def random_person(used_phones: set[str]) -> dict:
    first = random.choice(FIRST_NAMES)
    last = random.choice(LAST_NAMES)
    phone = unique_phone(used_phones)
    return {
        "firstName": first,
        "lastName": last,
        "phoneNumber": phone,
        "password": "Passw0rd!",
        "email": f"{_ascii(first)}.{_ascii(last)}.{phone[-4:]}@example.com",
    }


def _storage_dates() -> tuple[str, str]:
    start = datetime.now() + timedelta(days=random.randint(1, 7))
    end = start + timedelta(days=random.randint(14, 60))
    fmt = "%Y-%m-%dT%H:%M:%S"
    return start.strftime(fmt), end.strftime(fmt)


def consumer_post(base_url: str, path: str, token: str, body: Any) -> requests.Response:
    return requests.post(
        f"{base_url}{path}",
        headers={"Authorization": f"Bearer {token}", "Content-Type": "application/json"},
        data=json.dumps(body),
        timeout=15,
    )


def fetch_all_pages(client: TeraClient, path: str, params: dict | None = None) -> list[dict]:
    """Collect all items from a paginated endpoint."""
    items: list[dict] = []
    page = 0
    while True:
        p = dict(params or {})
        p["page"] = page
        p["size"] = 100
        r = client.get(path, params=p)
        if r.status_code not in (200, 201):
            break
        data = r.json()
        content = data.get("content", [])
        items.extend(content)
        if page >= data.get("totalPages", 1) - 1:
            break
        page += 1
    return items


def section(title: str) -> None:
    print()
    print("=" * 70)
    print(f"  {title}")
    print("=" * 70)

def ok(msg: str) -> None:  print(f"  ✓ {msg}")
def warn(msg: str) -> None: print(f"  ! {msg}")
def err(msg: str) -> None:  print(f"  ✗ {msg}")


# ---------------------------------------------------------------------------
# Step 1 — Users
# ---------------------------------------------------------------------------

def register_warehouse_admins(client: TeraClient, used_phones: set[str], count: int) -> list[dict]:
    section(f"Registering {count} warehouse admins")
    admins: list[dict] = []
    for _ in range(count):
        person = random_person(used_phones)
        r = client.post("/api/admin/auth/register_warehouse_admin", person)
        if r.status_code not in (200, 201):
            err(f"Warehouse admin failed ({person['phoneNumber']}): {r.status_code} {r.text[:100]}")
            continue
        data = r.json()
        admins.append({**person, "id": data["id"]})
        ok(f"{person['firstName']} {person['lastName']} ({person['phoneNumber']}) → {data['id']}")
    return admins


def _driver_pool(used_phones: set[str], count: int) -> list[dict]:
    """Generates driver info dicts (name + phone). No API call — passed inline when assigning."""
    drivers = []
    for _ in range(count):
        person = random_person(used_phones)
        drivers.append({
            "firstName": person["firstName"],
            "lastName": person["lastName"],
            "phoneNumber": person["phoneNumber"],
        })
    return drivers


def register_consumers(client: TeraClient, used_phones: set[str], count: int) -> list[dict]:
    section(f"Registering {count} consumers")
    consumers: list[dict] = []
    for _ in range(count):
        person = random_person(used_phones)
        r = client.post("/api/auth/register_consumer", person, auth=False)
        if r.status_code not in (200, 201):
            err(f"Consumer failed ({person['phoneNumber']}): {r.status_code} {r.text[:100]}")
            continue
        data = r.json()
        consumers.append({**person, "token": data["token"]})
        ok(f"{person['firstName']} {person['lastName']} ({person['phoneNumber']})")
    return consumers


# ---------------------------------------------------------------------------
# Step 2 — Catalog & Warehouses
# ---------------------------------------------------------------------------

def create_warehouses(client: TeraClient, admins: list[dict]) -> list[dict]:
    section(f"Creating {len(WAREHOUSES)} warehouses")
    if not admins:
        err("No admins — skipping")
        return []
    created: list[dict] = []
    for i, w in enumerate(WAREHOUSES):
        admin = admins[i % len(admins)]
        r = client.post("/api/warehouse/admin", {
            "name": w.name,
            "location": {"latitude": w.latitude, "longitude": w.longitude},
            "capacity": w.capacity,
            "adminId": admin["id"],
        })
        if r.status_code not in (200, 201):
            err(f"{w.name}: {r.status_code} {r.text[:100]}")
            continue
        data = r.json()
        created.append(data)
        ok(f"{w.name} → {data['warehouseId']}  (admin: {admin['firstName']} {admin['lastName']})")
    return created


def create_products(client: TeraClient) -> list[dict]:
    section(f"Creating {len(PRODUCTS)} products")
    created: list[dict] = []
    for p in PRODUCTS:
        r = client.post("/api/products/admin", {
            "name": p.name,
            "description": p.description,
            "unit": p.unit,
            "price": p.price,
            "dailyRate": p.daily_rate,
            "perKgRate": p.per_kg_rate,
            "tags": p.tags,
        })
        if r.status_code not in (200, 201):
            err(f"{p.name}: {r.status_code} {r.text[:100]}")
            continue
        data = r.json()
        created.append(data)
        ok(f"{p.name}  {p.price} XOF/{p.unit}  rate={p.daily_rate} XOF/day + {p.per_kg_rate} XOF/kg  → {data['id']}")
    return created


# ---------------------------------------------------------------------------
# Step 3 — Stock via INBOUND (one per product × warehouse)
# ---------------------------------------------------------------------------

def seed_inbound_stock(
    client: TeraClient,
    consumers: list[dict],
    products: list[dict],
    warehouses: list[dict],
    base_url: str,
    delegated_ratio: float = 0.4,
) -> list[dict]:
    """
    Creates one INBOUND storage request per product per warehouse.
    ~40% are flagged delegatedSale=true so those consumers will accumulate
    totalRevenue when orders pull from their stock (minus platform commission).
    """
    total = len(products) * len(warehouses)
    delegated_count = int(total * delegated_ratio)
    section(
        f"Creating {total} INBOUND requests  "
        f"({len(products)} products × {len(warehouses)} warehouses, "
        f"~{delegated_count} delegated)"
    )
    created: list[dict] = []
    indices = list(range(total))
    delegated_indices = set(random.sample(indices, k=delegated_count))

    idx = 0
    for product in products:
        for warehouse in warehouses:
            consumer = random.choice(consumers)
            start_date, end_date = _storage_dates()
            is_delegated = idx in delegated_indices
            r = consumer_post(base_url, "/api/storage", consumer["token"], {
                "productId": product["id"],
                "destinationWarehouseId": warehouse["warehouseId"],
                "quantity": random.choice([300, 400, 500, 600]),
                "type": "INBOUND",
                "startDate": start_date,
                "endDate": end_date,
                "delegatedSale": is_delegated,
            })
            if r.status_code not in (200, 201):
                err(f"INBOUND {product['name']} → {warehouse['name']}: {r.status_code} {r.text[:80]}")
                idx += 1
                continue
            data = r.json()
            label = " [DELEGATED]" if is_delegated else ""
            created.append({**data, "_productName": product["name"], "_warehouseName": warehouse["name"]})
            ok(f"INBOUND {data['quantity']} kg  {product['name']}  →  {warehouse['name']}{label}")
            idx += 1
    return created


def approve_all_inbound(client: TeraClient, inbound_reqs: list[dict]) -> list[dict]:
    section(f"Approving all {len(inbound_reqs)} INBOUND requests → stock + ownerId created")
    approved: list[dict] = []
    for req in inbound_reqs:
        r = client.post(f"/api/storage/admin/approve/{req['id']}")
        if r.status_code in (200, 201):
            approved.append(req)
            delegated = " [DELEGATED]" if req.get("delegatedSale") else ""
            ok(f"Approved {req['id']}  ({req['_productName']} → {req['_warehouseName']}){delegated}")
        else:
            err(f"Approve failed {req['id']}: {r.status_code} {r.text[:80]}")
    return approved


def complete_some_inbound(client: TeraClient, approved_inbound: list[dict], fraction: float = 0.25) -> None:
    """Complete a fraction of approved INBOUNDs to exercise billing (product rates × days × qty)."""
    to_complete = random.sample(approved_inbound, k=max(1, int(len(approved_inbound) * fraction)))
    section(f"Completing {len(to_complete)} INBOUND requests (billing = product.dailyRate × days + product.perKgRate × qty × days)")
    for req in to_complete:
        r = client.post(f"/api/storage/admin/complete/{req['id']}")
        if r.status_code in (200, 201):
            billing = r.json().get("billingAmount", "N/A")
            ok(f"Completed {req['id']}  billingAmount={billing} XOF")
        else:
            err(f"Complete failed {req['id']}: {r.status_code} {r.text[:80]}")


# ---------------------------------------------------------------------------
# Step 4 — Orders (auto-delivery via StockReservedEvent)
# ---------------------------------------------------------------------------

def create_orders(
    client: TeraClient,
    consumers: list[dict],
    products: list[dict],
    base_url: str,
) -> list[dict]:
    """
    Each consumer places 1-3 orders.  Each order triggers:
      OrderCreatedEvent → stock reservation (single-warehouse preferred,
        multi-warehouse fallback) → StockReservedEvent
      → delivery auto-created (PENDING) + order status → CONFIRMED
      → RevenueEarnedEvent for any delegated stock consumed
    """
    section("Creating orders (1-3 per consumer)")
    if not products:
        err("No products — skipping")
        return []
    created: list[dict] = []
    for consumer in consumers:
        for _ in range(random.randint(1, 3)):
            picked = random.sample(products, k=min(random.randint(1, 4), len(products)))
            items = [{"productId": p["id"], "quantity": random.choice([1, 2, 3, 5, 10])} for p in picked]
            r = consumer_post(base_url, "/api/order", consumer["token"], {
                "items": items,
                "destinationAddress": random.choice(DAKAR_ADDRESSES),
            })
            if r.status_code not in (200, 201):
                err(f"Order failed ({consumer['phoneNumber']}): {r.status_code} {r.text[:160]}")
                continue
            order = r.json()
            created.append({**order, "_consumer": consumer})
            ok(f"Order {order['orderId']}  {consumer['firstName']}  {len(items)} items  total={order.get('totalAmount')}")
    return created


def cancel_some_orders(orders: list[dict], base_url: str) -> set[str]:
    """Cancel ~10% of orders. Returns set of cancelled order IDs."""
    section("Cancelling ~10% of orders")
    to_cancel = random.sample(orders, k=max(1, len(orders) // 10))
    cancelled: set[str] = set()
    for order in to_cancel:
        consumer = order["_consumer"]
        r = requests.put(
            f"{base_url}/api/order/{order['orderId']}/cancel",
            headers={"Authorization": f"Bearer {consumer['token']}"},
            timeout=15,
        )
        if r.status_code in (200, 201):
            ok(f"Cancelled {order['orderId']}")
            cancelled.add(order["orderId"])
        else:
            warn(f"Could not cancel {order['orderId']}: {r.status_code} {r.text[:80]}")
    return cancelled


# ---------------------------------------------------------------------------
# Step 5 — Delivery status progression
# ---------------------------------------------------------------------------

def progress_deliveries(client: TeraClient, drivers: list[dict]) -> None:
    """
    Delivery state machine: PENDING → ASSIGNED → IN_TRANSIT → DELIVERED
      - 70% of PENDING deliveries get a driver assigned (driver info sent inline as body)
      - 80% of those advance to IN_TRANSIT
      - 50% of IN_TRANSIT advance to DELIVERED
    """
    section("Progressing deliveries  PENDING → ASSIGNED → IN_TRANSIT → DELIVERED")
    if not drivers:
        warn("No drivers in pool — skipping delivery progression.")
        return
    pending = fetch_all_pages(client, "/api/delivery", params={"status": "PENDING"})
    if not pending:
        warn("No PENDING deliveries found — order creation event may still be processing.")
        return
    ok(f"Found {len(pending)} PENDING deliveries")

    random.shuffle(pending)
    to_assign = pending[:int(len(pending) * 0.7)]
    assigned: list[dict] = []

    for i, d in enumerate(to_assign):
        driver = drivers[i % len(drivers)]
        r = client.patch(f"/api/delivery/admin/{d['id']}/assign", body=driver)
        if r.status_code in (200, 201):
            ok(f"Delivery {d['id']} → ASSIGNED  (driver: {driver['firstName']} {driver['lastName']})")
            assigned.append(d)
        else:
            err(f"ASSIGN failed for {d['id']}: {r.status_code} {r.text[:80]}")

    random.shuffle(assigned)
    to_transit = assigned[:int(len(assigned) * 0.8)]
    in_transit: list[dict] = []

    for d in to_transit:
        r = client.patch(f"/api/delivery/admin/{d['id']}/status", params={"status": "IN_TRANSIT"})
        if r.status_code in (200, 201):
            ok(f"Delivery {d['id']} → IN_TRANSIT")
            in_transit.append(d)
        else:
            err(f"IN_TRANSIT failed for {d['id']}: {r.status_code} {r.text[:80]}")

    for d in in_transit[:int(len(in_transit) * 0.5)]:
        r = client.patch(f"/api/delivery/admin/{d['id']}/status", params={"status": "DELIVERED"})
        if r.status_code in (200, 201):
            ok(f"Delivery {d['id']} → DELIVERED")
        else:
            err(f"DELIVERED failed for {d['id']}: {r.status_code} {r.text[:80]}")


# ---------------------------------------------------------------------------
# Step 6 — OUTBOUND requests (after stock exists)
# ---------------------------------------------------------------------------

def create_outbound_requests(
    client: TeraClient,
    consumers: list[dict],
    products: list[dict],
    warehouses: list[dict],
    base_url: str,
    count: int = 10,
) -> list[dict]:
    """
    OUTBOUND requests retrieve stock from a warehouse. Cycles through warehouses
    and products evenly so every warehouse gets approximately the same share.
    """
    section(f"Creating {count} OUTBOUND storage requests (round-robin across {len(warehouses)} warehouses)")
    created: list[dict] = []
    shuffled_warehouses = warehouses[:]
    shuffled_products = products[:]
    random.shuffle(shuffled_warehouses)
    random.shuffle(shuffled_products)
    for i in range(count):
        warehouse = shuffled_warehouses[i % len(shuffled_warehouses)]
        product   = shuffled_products[i % len(shuffled_products)]
        consumer  = consumers[i % len(consumers)]
        start_date, end_date = _storage_dates()
        r = consumer_post(base_url, "/api/storage", consumer["token"], {
            "productId": product["id"],
            "sourceWarehouseId": warehouse["warehouseId"],
            "quantity": random.choice([50, 100, 200, 300]),
            "type": "OUTBOUND",
            "startDate": start_date,
            "endDate": end_date,
            "delegatedSale": False,
        })
        if r.status_code not in (200, 201):
            err(f"OUTBOUND failed: {r.status_code} {r.text[:80]}")
            continue
        data = r.json()
        created.append(data)
        ok(f"OUTBOUND {data['quantity']} kg  {product['name']}  ←  {warehouse['name']}")
    return created


def process_outbound(client: TeraClient, outbound_reqs: list[dict]) -> None:
    """Approve half, reject half of OUTBOUND requests."""
    section(f"Processing {len(outbound_reqs)} OUTBOUND requests (approve ½, reject ½)")
    random.shuffle(outbound_reqs)
    mid = len(outbound_reqs) // 2
    for req in outbound_reqs[:mid]:
        r = client.post(f"/api/storage/admin/approve/{req['id']}")
        if r.status_code in (200, 201):
            ok(f"Approved OUTBOUND {req['id']}")
        else:
            err(f"Approve failed OUTBOUND {req['id']}: {r.status_code} {r.text[:80]}")
    for req in outbound_reqs[mid:]:
        r = client.post(f"/api/storage/admin/reject/{req['id']}")
        if r.status_code in (200, 201):
            ok(f"Rejected OUTBOUND {req['id']}")
        else:
            err(f"Reject failed {req['id']}: {r.status_code} {r.text[:80]}")


# ---------------------------------------------------------------------------
# State persistence
# ---------------------------------------------------------------------------

def build_warehouse_admin_summary(admins: list[dict], warehouses: list[dict]) -> list[dict]:
    """Returns admins enriched with the list of warehouses they manage."""
    admin_index = {a["id"]: a for a in admins}
    managed: dict[str, list[dict]] = {a["id"]: [] for a in admins}
    for w in warehouses:
        admin_id = w.get("adminId")
        if admin_id and admin_id in managed:
            managed[admin_id].append({
                "warehouseId": w["warehouseId"],
                "name": w["name"],
            })
    return [
        {
            "id": a["id"],
            "name": f"{a['firstName']} {a['lastName']}",
            "phoneNumber": a["phoneNumber"],
            "email": a.get("email", ""),
            "manages": managed[a["id"]],
        }
        for a in admins
    ]


def save_state(
    admins: list[dict],
    drivers: list[dict],
    consumers: list[dict],
    warehouses: list[dict],
    products: list[dict],
    base_url: str,
) -> None:
    state = {
        "base_url": base_url,
        "warehouse_admins": build_warehouse_admin_summary(admins, warehouses),
        "drivers": [
            {"name": f"{d['firstName']} {d['lastName']}", "phoneNumber": d["phoneNumber"]}
            for d in drivers
        ],
        "consumers": [
            {k: v for k, v in c.items() if k != "token"}
            for c in consumers
        ],
        "warehouses": [
            {"warehouseId": w["warehouseId"], "name": w["name"]}
            for w in warehouses
        ],
        "products": [
            {
                "id": p["id"],
                "name": p["name"],
                "dailyRate": p.get("dailyRate"),
                "perKgRate": p.get("perKgRate"),
                "tags": p.get("tags", []),
            }
            for p in products
        ],
    }
    try:
        STATE_FILE.write_text(json.dumps(state, indent=2, default=str))
    except Exception as e:
        warn(f"Could not save state: {e}")


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

def main() -> int:
    parser = argparse.ArgumentParser(description="Seed the Tera backend with comprehensive test data.")
    parser.add_argument("--base-url", default=DEFAULT_BASE_URL)
    parser.add_argument("--warehouse-admins", type=int, default=3, help="Number of warehouse admins")
    parser.add_argument("--drivers", type=int, default=4, help="Number of drivers")
    parser.add_argument("--consumers", type=int, default=10, help="Number of consumers")
    parser.add_argument("--seed", type=int, default=42, help="Random seed")
    parser.add_argument("--reset-state", action="store_true", help="Delete cached state before running")
    args = parser.parse_args()

    random.seed(args.seed)
    if args.reset_state and STATE_FILE.exists():
        STATE_FILE.unlink()

    print(f"Tera seeder → {args.base_url}")

    client = TeraClient(args.base_url)
    section("Authenticating as superadmin")
    try:
        client.login(SUPERADMIN_PHONE, SUPERADMIN_PASSWORD)
        ok("Superadmin logged in")
    except Exception as e:
        err(str(e))
        return 1

    used_phones: set[str] = {SUPERADMIN_PHONE}

    # ── 1. Users ────────────────────────────────────────────────────────────
    admins    = register_warehouse_admins(client, used_phones, args.warehouse_admins)
    consumers = register_consumers(client, used_phones, args.consumers)
    drivers   = _driver_pool(used_phones, args.drivers)

    # ── 2. Catalog & Warehouses ─────────────────────────────────────────────
    warehouses = create_warehouses(client, admins)
    products   = create_products(client)

    # ── 3. Stock: INBOUND (one per product × warehouse, ~40% delegated) ────
    inbound_reqs     = seed_inbound_stock(client, consumers, products, warehouses, args.base_url)
    approved_inbound = approve_all_inbound(client, inbound_reqs)

    section("Waiting 3s for stock-creation events to commit")
    time.sleep(3.0)

    # ── 4. Orders (triggers single- or multi-warehouse reservation + revenue)
    orders = create_orders(client, consumers, products, args.base_url)
    cancel_some_orders(orders, args.base_url)

    section("Waiting 5s for stock-reservation and revenue events to commit")
    time.sleep(5.0)

    # ── 5. Delivery progression ─────────────────────────────────────────────
    progress_deliveries(client, drivers)

    # ── 6. OUTBOUND requests ────────────────────────────────────────────────
    outbound_reqs = create_outbound_requests(client, consumers, products, warehouses, args.base_url, count=10)
    process_outbound(client, outbound_reqs)

    # ── 7. Storage billing (complete a fraction of approved INBOUNDs) ───────
    if approved_inbound:
        complete_some_inbound(client, approved_inbound, fraction=0.25)

    # ── Persist identifiers for manual testing ──────────────────────────────
    save_state(admins, drivers, consumers, warehouses, products, args.base_url)

    section("Done — database summary")
    delegated = sum(1 for r in inbound_reqs if r.get("delegatedSale"))
    print(f"  Warehouse admins   : {len(admins)}")
    print(f"  Driver pool        : {len(drivers)}  (info passed inline on delivery assign)")
    print(f"  Consumers          : {len(consumers)}")
    print(f"  Warehouses         : {len(warehouses)}")
    print(f"  Products           : {len(products)}  (each with dailyRate + perKgRate)")
    print(f"  INBOUND requests   : {len(inbound_reqs)}  ({len(products)}×{len(warehouses)}, all approved; {delegated} delegated)")
    print(f"  OUTBOUND requests  : {len(outbound_reqs)}  (½ approved, ½ rejected)")
    print(f"  Orders             : {len(orders)}  (~10% cancelled; delegated stock earns owner revenue)")
    print()
    print("  Sample credentials (password = 'Passw0rd!' for all):")
    for c in consumers[:3]:
        print(f"    {c['phoneNumber']}  {c['firstName']} {c['lastName']}  {c['email']}")
    print()
    print(f"  State written to {STATE_FILE}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
