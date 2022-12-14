import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'catcherror_platform_interface.dart';

class Catcherror {
  static init(
    Function mainAppCall, {
    String? postRequestUrl,
    Map<String, String>? headers,
    Function(Object, StackTrace)? onErrorCallBack,
    Function(Object, StackTrace)? onHttpRequestFailedCallback,
  }) {
    runZonedGuarded(() {
      WidgetsFlutterBinding.ensureInitialized();
      //runApp(MyApp()) can be passed here
      mainAppCall();
    }, (error, stackTrace) {
      //For logging the error in debug
      log("Unhandled Native Exception.", error: error, stackTrace: stackTrace);
      //Handling HTTP post request
      if (postRequestUrl != null) {
        //Runs the http request in another zone to capture the error where url provided is inappropriate.
        runZonedGuarded(() {
          http.post(Uri.parse(postRequestUrl),
              body: {
                'error': error.toString(),
                'stackTrace': stackTrace.toString()
              },
              headers: headers);
        }, ((error, stack) {
          log("Exception in HTTP Post Request. Please re-verify the url provided",
              error: error, stackTrace: stack);
          if (onHttpRequestFailedCallback != null) {
            onHttpRequestFailedCallback(error, stack);
          }
        }));
      }
      //If any additional callback to be added on error, can be used for showing Toast Message or Dialog.
      if (onErrorCallBack != null) {
        onErrorCallBack(error, stackTrace);
      }
    });
  }

  Future<bool> checkVowel(String alphabet) {
    return CatcherrorPlatform.instance.checkVowel(alphabet);
  }
}
