import 'package:frontend/cores/utils/helper.dart';
import 'package:midtrans_sdk/midtrans_sdk.dart';

class MidtransHelper {
  static final String MIDTRANS_CLIENT_KEY = "SB-Mid-client-IJo864mljN4-TBwb";
  static final String MIDTRANS_MERCHANT_BASE_URL =
      "https://composed-light-crayfish.ngrok-free.app/";

  static MidtransSDK? _midtrans;

  static Future<void> initSDK() async {
    _midtrans = await MidtransSDK.init(
      config: MidtransConfig(
        clientKey: MIDTRANS_CLIENT_KEY,
        merchantBaseUrl: MIDTRANS_MERCHANT_BASE_URL,
        enableLog: true,
      ),
    );
    _midtrans!.setTransactionFinishedCallback((result) {
      logger('Midtrans result: ${result.toJson()}');
    });
  }

  static Future<void> startPayment(String snapToken) async {
    await _midtrans?.startPaymentUiFlow(token: snapToken);
  }
}
