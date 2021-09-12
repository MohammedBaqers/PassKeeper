import 'package:PassKeeper/temp.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:local_auth/local_auth.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: Temp(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List kyes = [''];
  Map data = {'البريد': 'الرمز'};
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  _incrementCounter() async {
    final SharedPreferences prefs = await _prefs;

    setState(() {
      if (accountcontroller.text != '' && passcontroller.text != '') {
        prefs.setString(accountcontroller.text, passcontroller.text);
      }
      kyes = prefs.getKeys().toList();
      data = {'البريد': 'الرمز'};
    });

    setData();
    accountcontroller.text = '';
    passcontroller.text = '';
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

  Future<void> _authenticate(var target) async {
    bool authenticated = false;
    try {
      authenticated = await auth.authenticateWithBiometrics(
          localizedReason: 'Scan your fingerprint to Show Password',
          useErrorDialogs: false,
          stickyAuth: true);
    } on PlatformException catch (e) {
      print(e);
    }
    if (!mounted) return;

    if (authenticated) {
      switch (target) {
        case 'showPass':
          setState(() {
            showPass = !showPass;
          });
          break;
        case 'delete':
          final SharedPreferences prefs = await _prefs;

          prefs.remove(accountcontroller.text);
          kyes.remove(accountcontroller.text);
          accountcontroller.text = '';
          data.remove(accountcontroller.text);
          _incrementCounter();
          break;
        case 'show':
          setState(() {
            if (!show) {
              hieght = 0;
              show = !show;
            } else {
              hieght = 200;
              show = !show;
            }
          });
          break;
        default:
      }
    } else {
      print('notAuth');
    }
  }

  _getAuth(var target) async {
    await _checkBiometrics();
    await _getAvailableBiometrics();
    _canCheckBiometrics && _availableBiometrics.length != 0
        ? _authenticate(target)
        : print('cand');
  }

  @override
  void initState() {
    super.initState();
    init();
    setData();
  }

  init() async {
    final SharedPreferences prefs = await _prefs;
    setState(() {
      kyes = prefs.getKeys().toList();
    });
  }

  setData() async {
    final SharedPreferences prefs = await _prefs;
    for (var item in kyes) {
      setState(() {
        data[item] = prefs.getString(item);
      });
      print(data);
    }
  }

  double hieght = 0;
  bool show = true;
  bool showPass = true;

  TextEditingController accountcontroller = TextEditingController();
  TextEditingController passcontroller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        leading: IconButton(
            icon: Icon(
              !showPass ? Icons.visibility : Icons.visibility_off,
              color: Colors.black,
            ),
            onPressed: () {
              if (showPass) {
                FocusScope.of(context).unfocus();
                _getAuth('showPass');
              } else {
                setState(() {
                  showPass = !showPass;
                });
                print(showPass);
              }
            }),
        actions: [
          IconButton(
            icon: Icon(
              !show ? Icons.lock_open_outlined : Icons.lock_outline_rounded,
              color: Colors.black,
            ),
            onPressed: () async {
              FocusScope.of(context).unfocus();
              if (show) {
                _getAuth('show');
              } else {
                setState(() {
                  if (!show) {
                    hieght = 0;
                    show = !show;
                  } else {
                    hieght = 200;
                    show = !show;
                  }
                });
              }
            },
          ),
          IconButton(
            icon: Icon(
              Icons.delete,
              color: Colors.red,
            ),
            onPressed: () async {
              FocusScope.of(context).unfocus();
              _getAuth('delete');
            },
          ),
          Icon(
            Icons.ac_unit,
            color: Theme.of(context).primaryColor,
          )
        ],
        title: Text(widget.title),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: AnimatedContainer(
              curve: Curves.linear,
              height: hieght,
              duration: const Duration(seconds: 1),
              child: ListView(children: [
                TextFormField(
                  controller: accountcontroller,
                  decoration: InputDecoration(
                      prefixIcon: Icon(
                        Icons.account_box,
                        color: Colors.blue,
                      ),
                      focusedBorder: OutlineInputBorder(
                          //with click in textfield
                          borderSide: BorderSide(
                            color: Colors.blue,
                            width: 2.0,
                          ),
                          borderRadius: BorderRadius.circular(20)),
                      enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.black,
                            width: 2.0,
                          ),
                          borderRadius: BorderRadius.circular(20)),
                      filled: true, //for enemation

                      labelText: 'acount',
                      labelStyle: GoogleFonts.cairo(fontSize: 14)),
                ),
                SizedBox(
                  height: 20,
                ),
                TextFormField(
                  controller: passcontroller,
                  decoration: InputDecoration(
                    prefixIcon: Icon(
                      Icons.lock,
                      color: Colors.blue,
                    ),

                    focusedBorder: OutlineInputBorder(
                        //with click in textfield
                        borderSide: BorderSide(
                          color: Colors.blue,
                          width: 2.0,
                        ),
                        borderRadius: BorderRadius.circular(20)),
                    enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.black,
                          width: 2.0,
                        ),
                        borderRadius: BorderRadius.circular(20)),
                    filled: true, //for enemation

                    labelText: 'Enter your password',
                    labelStyle: GoogleFonts.cairo(fontSize: 14),
                  ),
                ),
              ]),
            ),
          ),
          AnimatedContainer(
            curve: Curves.linear,
            padding: EdgeInsets.only(top: hieght, bottom: 70),
            duration: const Duration(seconds: 1),
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: GestureDetector(
                  onTap: () {
                    FocusScope.of(context).unfocus();
                  },
                  child: DataTable(
                    dataRowHeight: 80,
                    columnSpacing: 150,
                    headingRowColor: MaterialStateColor.resolveWith(
                        (states) => Colors.black),
                    columns: [
                      DataColumn(
                        label: Text(
                          'Email',
                          style: GoogleFonts.cairo(
                              fontSize: 14, color: Colors.white),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      DataColumn(
                          label: Text(
                        'Pass',
                        style: GoogleFonts.cairo(
                            fontSize: 14, color: Colors.white),
                        textAlign: TextAlign.center,
                      )),
                    ],
                    rows: [
                      for (var i = 1; i < data.length; i++)
                        DataRow(
                          cells: [
                            DataCell(
                              copy(
                                data.keys.elementAt(i).toString(),
                              ),
                            ),
                            DataCell(!showPass
                                ? copy(data[data.keys.elementAt(i).toString()]
                                    .toString())
                                : copy('******************')),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          FocusScope.of(context).unfocus();
          _incrementCounter();
        },
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  copy(text) {
    return new GestureDetector(
      child: new Text(
        text,
        style: GoogleFonts.cairo(fontSize: 16, color: Colors.black),
        textAlign: TextAlign.center,
      ),
      onTap: () {
        FocusScope.of(context).unfocus();
        Clipboard.setData(new ClipboardData(text: text));
      },
    );
  }
}
