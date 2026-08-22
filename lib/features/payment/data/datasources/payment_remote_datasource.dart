import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:tera/features/payment/data/models/initiate_payment_request_model.dart';
import 'package:tera/features/payment/data/models/payment_model.dart';
import 'package:tera/features/payment/domain/entities/payment_reference_type.dart';

abstract class PaymentRemoteDataSource {
  Future<PaymentModel> getByReference(
    String referenceId,
    PaymentReferenceType referenceType,
  );
  Future<PaymentModel> getPaymentById(String id);
  Future<PaymentModel> initiatePayment(InitiatePaymentRequestModel request);
}

@LazySingleton(as: PaymentRemoteDataSource)
class PaymentRemoteDataSourceImpl implements PaymentRemoteDataSource {
  const PaymentRemoteDataSourceImpl(this._dio);
  final Dio _dio;

  @override
  Future<PaymentModel> getByReference(
    String referenceId,
    PaymentReferenceType referenceType,
  ) async {
    final res = await _dio.get<Map<String, dynamic>>(
      '/api/payment/by-reference/$referenceId',
      queryParameters: {'type': referenceType.toApiString()},
    );
    return PaymentModel.fromJson(res.data!);
  }

  @override
  Future<PaymentModel> getPaymentById(String id) async {
    final res = await _dio.get<Map<String, dynamic>>('/api/payment/$id');
    return PaymentModel.fromJson(res.data!);
  }

  @override
  Future<PaymentModel> initiatePayment(
    InitiatePaymentRequestModel request,
  ) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/api/payment/initiate',
      data: request.toJson(),
    );
    return PaymentModel.fromJson(res.data!);
  }
}
