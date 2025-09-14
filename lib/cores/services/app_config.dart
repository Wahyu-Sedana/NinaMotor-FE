import 'dart:io';

enum Environment { local, ngrok, production }

class AppConfig {
  static const Environment env = Environment.local;
  // static const Environment envNgrok = Environment.ngrok;
  // static const Environment envProduction = Environment.production;

  static String get baseURL {
    switch (env) {
      case Environment.local:
        if (Platform.isAndroid) {
          return "http://10.0.2.2:8000/api/";
        } else if (Platform.isIOS) {
          return "http://127.0.0.1:8000/api/";
        }
        return "http://127.0.0.1:8000/api/";
      case Environment.ngrok:
        return "https://composed-light-crayfish.ngrok-free.app/api/";
      case Environment.production:
        return "https://ninamotor.web.id/api/";
    }
  }

  static String get baseURLImage {
    switch (env) {
      case Environment.local:
        if (Platform.isAndroid) {
          return "http://10.0.2.2:8000/storage/";
        } else if (Platform.isIOS) {
          return "http://127.0.0.1:8000/storage/";
        }
        return "http://127.0.0.1:8000/storage/";
      case Environment.ngrok:
        return "https://composed-light-crayfish.ngrok-free.app/storage/";
      case Environment.production:
        return "https://ninamotor.web.id/storage/";
    }
  }

  static String get midtransURL {
    switch (env) {
      case Environment.local:
        if (Platform.isAndroid) {
          return "http://10.0.2.2:8000/api/midtrans/callback";
        } else if (Platform.isIOS) {
          return "http://127.0.0.1:8000/api/midtrans/callback";
        }
        return "http://127.0.0.1:8000/api/midtrans/callback";
      case Environment.ngrok:
        return "https://composed-light-crayfish.ngrok-free.app/api/midtrans/callback";
      case Environment.production:
        return "https://ninamotor.web.id/api/midtrans/callback";
    }
  }
}
