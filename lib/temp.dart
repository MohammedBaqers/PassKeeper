import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

import 'main.dart';

class Temp extends StatefulWidget {
  @override
  _TempState createState() => _TempState();
}

class _TempState extends State<Temp> {
  @override
  void initState() {
    super.initState();
    _getAuth();
  }

  final LocalAuthentication auth = LocalAuthentication();
  bool showpass = true, fingerPrintAuth;
  bool _canCheckBiometrics;
  List<BiometricType> _availableBiometrics;
  Future<void> _checkBiometrics() async {
    bool canCheckBiometrics;
    try {
      canCheckBiometrics = await auth.canCheckBiometrics;
    } on PlatformException catch (e) {
      print(e);
    }
    if (!mounted) return;

    setState(() {
      _canCheckBiometrics = canCheckBiometrics;
    });
  }

  Future<void> _getAvailableBiometrics() async {
    List<BiometricType> availableBiometrics;
    try {
      availableBiometrics = await auth.getAvailableBiometrics();
    } on PlatformException catch (e) {
      print(e);
    }
    if (!mounted) return;

    setState(() {
      _availableBiometrics = availableBiometrics;
    });
  }

  Future<void> _authenticate() async {
    bool authenticated = false;
    try {
      authenticated = await auth.authenticateWithBiometrics(
          localizedReason: 'Scan your fingerprint to Unluck App',
          useErrorDialogs: false,
          stickyAuth: true);
    } on PlatformException catch (e) {
      print(e);
    }
    if (!mounted) return;

    if (authenticated) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
            builder: (context) => MyHomePage(title: 'PassKeeper')),
        (Route<dynamic> route) => false,
      );
    } else {
      exit(0);
    }
  }

  _getAuth() async {
    await _checkBiometrics();
    await _getAvailableBiometrics();
    _canCheckBiometrics && _availableBiometrics.length != 0
        ? _authenticate()
        : print('cand');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold();
  }
}
