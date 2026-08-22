# Mobile App ↔ Payments & Disbursements Integration Guide

This guide describes how the **TERA mobile app** integrates with the backend's
payment system. The backend uses **NabooPay** as the payment gateway for two
distinct flows:

| Flow | Direction | Who | Endpoints |
|------|-----------|-----|-----------|
| **Collections** (Payments) | Money **in** | Customers paying for orders / storage | `/api/payment/**` |
| **Disbursements** (Payouts) | Money **out** | Sellers & admins withdrawing funds | `/api/wallet/**` |

Currency throughout is **XOF** (West African CFA franc). Amounts are sent and
returned as plain numbers (e.g. `5000` = 5 000 XOF). NabooPay supports **Wave**
and **Orange Money**.

---

## 0. Prerequisites

- **Base URL**: same host as the rest of the API (e.g. `https://api.tera.app`).
- **Auth**: every endpoint below requires `Authorization: Bearer <accessToken>`
  **except** `POST /api/payment/webhook` (server-to-server only — the app never
  calls it).
- **Feature flag**: payment endpoints only exist when the backend runs with
  `PAYMENT_ENABLED=true`. If payments are disabled the routes return `404` —
  guard the wallet/checkout UI on a capability check or build flag.
- All request/response bodies are JSON.

---

## 1. Collections — paying for an order

### 1.1 The happy path (no extra call needed to *start* a payment)

When a customer places an order (or a storage request completes), the backend
**automatically creates a NabooPay checkout** for it. The app does **not** need
to call an "initiate payment" endpoint for normal orders — it just needs to
**fetch the checkout URL** and open it.

```
Customer confirms order
        │
        ▼
POST /api/order ...                    (existing order endpoint)
        │  backend fires PaymentRequestedEvent → creates NabooPay checkout
        ▼
GET /api/payment/by-reference/{orderId}?type=ORDER
        │  → { checkoutUrl, status: "PENDING", ... }
        ▼
Open checkoutUrl in a WebView / browser
        │  customer pays with Wave / Orange Money on NabooPay's hosted page
        ▼
NabooPay redirects to success-url / error-url  (deep link back into the app)
        │
        ▼
GET /api/payment/{paymentId}           (confirm final status — source of truth)
```

> ⚠️ The checkout is created **asynchronously** after the order transaction
> commits. Immediately after creating the order the `checkoutUrl` may not be
> ready yet. **Poll** `by-reference` a few times (e.g. every 1s, up to ~5
> attempts) until `checkoutUrl` is non-null, or show a "preparing payment…"
> state.

### 1.2 Fetch the checkout for a reference

```http
GET /api/payment/by-reference/{referenceId}?type=ORDER
Authorization: Bearer <token>
```

`type` is `ORDER` (default) or `STORAGE_REQUEST`.

**Response `200`** — `PaymentResponse`:

```json
{
  "paymentId": "8f1c…",
  "referenceId": "a3d2…",
  "referenceType": "ORDER",
  "amount": 5000,
  "currency": "XOF",
  "status": "PENDING",
  "checkoutUrl": "https://pay.naboopay.com/checkout/xyz",
  "operator": null,
  "phoneNumber": null,
  "userId": "c91b…",
  "createdAt": "2026-06-19T10:15:00",
  "updatedAt": "2026-06-19T10:15:00"
}
```

Open `checkoutUrl`. The customer selects Wave or Orange Money **on NabooPay's
page**, so the app does not collect card/wallet details itself.

### 1.3 Manually (re)initiate a payment — fallback only

Use this only if auto-initiation failed (e.g. `by-reference` keeps returning no
`checkoutUrl`, or you need to re-create an expired checkout).

```http
POST /api/payment/initiate
Authorization: Bearer <token>
Content-Type: application/json

{
  "referenceId": "a3d2…",
  "referenceType": "ORDER",        // or "STORAGE_REQUEST"
  "amount": 5000,
  "description": "Order #1234"
}
```

**Response `201`** — same `PaymentResponse` shape, with a fresh `checkoutUrl`.

### 1.4 Check a payment's status

```http
GET /api/payment/{paymentId}
Authorization: Bearer <token>
```

Returns the `PaymentResponse`. **`status` is the field that matters.**

| `status` | Meaning | App action |
|----------|---------|-----------|
| `PENDING` | Checkout created, not paid yet | Keep waiting / let user retry |
| `PAID` | Payment succeeded | Show success, advance order |
| `PAID_AND_BLOCKED` | Paid, held by NabooPay escrow | Treat as paid for UX |
| `CANCELLED` | Customer cancelled | Offer retry |
| `REFUNDED` | Refunded | Show refunded state |
| `FAILED` | Payment/processing failed | Offer retry |

> **Source of truth:** the backend confirms payments via a NabooPay **webhook**
> (server-side, HMAC-verified). The app should treat its own WebView "success"
> redirect as *optimistic* and confirm by polling `GET /api/payment/{id}` until
> the status is terminal (`PAID` / `CANCELLED` / `FAILED` / `REFUNDED`).

### 1.5 Returning to the app after the hosted page

NabooPay redirects to a success URL or error URL after the customer finishes.
Those URLs are configured **server-side** via env (`NABOOPAY_SUCCESS_URL`,
`NABOOPAY_ERROR_URL`). For the mobile app, set these to the app's **deep link**
(e.g. `teraapp://payment/success` / `teraapp://payment/error`) so NabooPay sends
the customer back into the app. On that deep link, fetch the latest status
(§1.4) before showing the result.

If deep links aren't wired yet, fall back to **polling** `GET /api/payment/{id}`
while the WebView is open and close it once the status is terminal.

---

## 2. Disbursements — wallet & withdrawals

Sellers withdraw their **earnings**; platform admins withdraw **platform
profit**. The app calls the **same endpoints** for both — the backend resolves
which "account" the caller draws from based on their role:

| Caller role | Withdraws from | `source` in balance |
|-------------|----------------|---------------------|
| `CONSUMER` / `PRODUCER` (sellers) | their sales earnings | `SELLER_EARNINGS` |
| `ADMIN` / `SUPERADMIN` | platform accrued profit | `PLATFORM_PROFIT` |
| anything else | nothing (not permitted) | `UNAVAILABLE` |

### 2.1 Show the withdrawable balance

```http
GET /api/wallet/balance
Authorization: Bearer <token>
```

**Response `200`** — `BalanceResponse`:

```json
{ "available": 12500, "currency": "XOF", "source": "SELLER_EARNINGS" }
```

If `source` is `UNAVAILABLE`, hide the withdraw button (`available` will be `0`).

### 2.2 Request a withdrawal (payout)

```http
POST /api/wallet/withdraw
Authorization: Bearer <token>
Content-Type: application/json

{
  "amount": 10000,
  "method": "wave",                  // "wave" or "orange_money"
  "recipientFirstName": "Awa",
  "recipientLastName": "Diop",
  "recipientPhone": "+221770000000"
}
```

- `amount` — minimum **11 XOF**, must not exceed the available balance.
- `method` — send the lowercase slug `"wave"` or `"orange_money"`.
- Recipient fields are required (the mobile-money account that receives funds).

**Response `201`** — `PayoutResponse`:

```json
{
  "id": "44ab…",
  "requestedByUserId": "c91b…",
  "type": "SELLER_EARNINGS",
  "amount": 10000,
  "currency": "XOF",
  "method": "wave",
  "recipientName": "Awa Diop",
  "recipientPhone": "+221770000000",
  "status": "COMPLETED",
  "gatewayReference": "NBP-…",
  "reason": "TERA earnings withdrawal",
  "createdAt": "2026-06-19T10:20:00"
}
```

| `status` | Meaning |
|----------|---------|
| `COMPLETED` | NabooPay processed the payout |
| `PENDING` | Accepted but under NabooPay manual review (e.g. large amount) |
| `FAILED` | Rejected — the debit was rolled back, balance is unchanged |

> The debit and the payout share one transaction: if NabooPay rejects the
> payout, the user's balance is **not** reduced. The balance returned by §2.1
> after a `FAILED` payout is unchanged.

### 2.3 Payout history

```http
GET /api/wallet/payouts
Authorization: Bearer <token>
```

Returns a list of `PayoutResponse` (most relevant for the caller). Use it for a
"withdrawal history" screen.

### 2.4 Error responses (withdrawals)

The body is a plain text message suitable to surface to the user.

| HTTP | When | Suggested UX |
|------|------|--------------|
| `400 Bad Request` | Amount ≤ 0, below minimum, or above balance | Inline validation error |
| `403 Forbidden` | Role not permitted to withdraw | Hide/disable the feature |
| `409 Conflict` | Payout rate-limited (too many requests) | "Try again shortly" |
| `502 Bad Gateway` | NabooPay/gateway error | "Service unavailable, retry later" |
| `404 Not Found` | Payments feature disabled on the server | Hide the feature |

---

## 3. Admin finance overview (admin app only)

```http
GET /api/admin/finance/overview
Authorization: Bearer <admin token>      // ADMIN or SUPERADMIN
```

**Response `200`** — `FinanceOverviewResponse`:

```json
{
  "accountBalance": 1500000,       // live NabooPay cash (null if unreadable)
  "totalUserLiabilities": 900000,  // funds owed to sellers
  "availableProfit": 300000,       // platform profit currently withdrawable
  "accumulatedProfit": 450000,     // total profit earned to date
  "withdrawnProfit": 150000,       // profit already paid out
  "currency": "XOF"
}
```

`accountBalance` may be `null` if NabooPay's balance API is momentarily
unreachable — render a placeholder rather than `0`.

---

## 4. Quick reference

### Endpoints

| Method | Path | Auth | Purpose |
|--------|------|------|---------|
| `GET`  | `/api/payment/by-reference/{referenceId}?type=ORDER` | Bearer | Get checkout URL + status for an order/storage ref |
| `GET`  | `/api/payment/{paymentId}` | Bearer | Poll a payment's status |
| `POST` | `/api/payment/initiate` | Bearer | Manually (re)create a checkout |
| `POST` | `/api/payment/webhook` | none (server only) | NabooPay → backend; **app never calls this** |
| `GET`  | `/api/wallet/balance` | Bearer | Withdrawable balance |
| `POST` | `/api/wallet/withdraw` | Bearer | Request a payout |
| `GET`  | `/api/wallet/payouts` | Bearer | Payout history |
| `GET`  | `/api/admin/finance/overview` | Bearer (ADMIN) | Platform finance overview |

### Enums

- **PaymentStatus**: `PENDING`, `PAID`, `PAID_AND_BLOCKED`, `REFUNDED`, `CANCELLED`, `FAILED`
- **PaymentReferenceType**: `ORDER`, `STORAGE_REQUEST`
- **PaymentOperator / method**: `wave`, `orange_money` (lowercase slugs in JSON)
- **PayoutStatus**: `PENDING`, `COMPLETED`, `FAILED`
- **PayoutType**: `SELLER_EARNINGS`, `PLATFORM_PROFIT`

### Mobile implementation checklist

- [ ] Open `checkoutUrl` in an in-app WebView (or external browser) — do **not**
  build a custom card/wallet form.
- [ ] Poll `by-reference` until `checkoutUrl` is ready after order creation.
- [ ] Confirm final state via `GET /api/payment/{id}` — don't trust the WebView
  redirect alone.
- [ ] Wire `NABOOPAY_SUCCESS_URL` / `NABOOPAY_ERROR_URL` (server env) to the
  app's deep-link scheme so the customer returns into the app.
- [ ] Format amounts as XOF integers (no decimals in practice).
- [ ] Gate wallet/checkout UI on `PAYMENT_ENABLED` (treat `404` as "disabled").
- [ ] Surface withdrawal error bodies (`400/403/409/502`) to the user verbatim
  or with friendly mappings.
