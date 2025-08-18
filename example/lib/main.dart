import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'widgets/sample_widget.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  runApp(
    EasyLocalization(
      supportedLocales: [Locale('en'), Locale('es')],
      path: 'assets/languages',
      fallbackLocale: Locale('en'),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      title: 'Easy Localization Demo App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: MyHomePage(title: 'Easy Localization Test'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  // Test: Array with hardcoded strings - READY FOR LOCALIZATION!
  final List<String> actionButtons = [
    'Save Document',
    'Load Document',
    'Delete Document'
  ];

  // Test: Map with hardcoded strings - READY FOR LOCALIZATION!
  final Map<String, String> messages = {
    'success': 'Operation completed successfully!',
    'error': 'Something went wrong, please try again',
    'warning': 'Please be careful with this action',
    'info': 'Here is some helpful information',
  };

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pressed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 20),

            // Test: Display array items - THESE WILL BE LOCALIZED!
            const Text('Action Buttons:',
                style: TextStyle(fontWeight: FontWeight.bold)),
            Column(
              children: actionButtons
                  .map((action) => Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: ElevatedButton(
                          onPressed: () =>
                              _showMessage(messages['success'] ?? 'Done'),
                          child: Text(action),
                        ),
                      ))
                  .toList(),
            ),

            const SizedBox(height: 20),
            const SampleWidget(),
            const SizedBox(height: 20),

            const Text('Welcome to easy_localization with assets/languages!'),

            // Test: Constructor with hardcoded string - READY FOR LOCALIZATION!
            Container(
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.blue),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'This text will be converted to LocaleKeys.thisText.tr()',
                style: TextStyle(fontStyle: FontStyle.italic),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment Counter',
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        action: SnackBarAction(
          label: 'Close',
          onPressed: () {},
        ),
      ),
    );
  }
}
