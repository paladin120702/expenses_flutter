import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'components/transaction_form.dart';
import 'components/transaction_list.dart';
import 'models/transaction.dart';
import 'dart:math';
import 'components/chart.dart';

main() => runApp(ExpensesApp());

class ExpensesApp extends StatelessWidget {
  ExpensesApp({super.key});
  final ThemeData theme = ThemeData();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const MyHomePage(),
      theme: ThemeData(
        useMaterial3: false,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          titleTextStyle: TextStyle(
            fontFamily: 'OpenSans',
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blueAccent[700],
            foregroundColor: Colors.white,
            textStyle: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: Colors.blueAccent[700],
            backgroundColor: Colors.white,
            textStyle: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        primarySwatch: Colors.blue,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.white,
          secondary: Colors.blueAccent[700],
        ),
        fontFamily: 'Quicksand',
        textTheme: ThemeData.light().textTheme.copyWith(
              titleMedium: const TextStyle(
                fontFamily: 'OpenSans',
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final List<Transaction> _transactions = [];
  bool _showChart = false;

  @override
  void initState() {
    super.initState();
    loadList();
  }

  Future<void> loadList() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> listJson = prefs.getStringList('Transaction') ?? [];
    List<Transaction> loadedTransactions = listJson.map((transaction) {
      Map<String, dynamic> map =
          Map<String, dynamic>.from(jsonDecode(transaction));
      return Transaction.fromMap(map);
    }).toList();

    setState(() {
      _transactions.clear();
      _transactions.addAll(loadedTransactions);
    });
  }

  Future<void> salvelist() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> listJson = _transactions
        .map((transactions) => jsonEncode(transactions.toMap()))
        .toList();
    await prefs.setStringList('Transaction', listJson);
  }

  List<Transaction> get _recentTransactions {
    return _transactions.where((tr) {
      return tr.date.isAfter(
        DateTime.now().subtract(
          const Duration(days: 7),
        ),
      );
    }).toList();
  }

  _addTransaction(String title, double value, DateTime date) {
    final newTransaction = Transaction(
      id: Random().nextDouble().toString(),
      title: title,
      value: value,
      date: date,
    );

    setState(() {
      _transactions.add(newTransaction);
    });
    salvelist();
    Navigator.of(context).pop();
  }

  _deleteTransaction(String id) {
    setState(() {
      _transactions.removeWhere((tr) => tr.id == id);
    });
    salvelist();
  }

  _openTransactioFormModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return TransactionForm(_addTransaction);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    bool isLandscape = mediaQuery.orientation == Orientation.landscape;

    final appBar = AppBar(
      title: const Text('Personal Expenses'),
      actions: <Widget>[
        if (isLandscape == true)
          IconButton(
            icon: Icon(_showChart ? Icons.list : Icons.bar_chart_rounded),
            onPressed: () {
              setState(() {
                _showChart = !_showChart;
              });
            },
          ),
        IconButton(
          icon: const Icon(Icons.add),
          onPressed: () => _openTransactioFormModal(context),
        ),
      ],
    );

    final availableHeight = mediaQuery.size.height -
        appBar.preferredSize.height -
        mediaQuery.padding.top;

    return SafeArea(
      child: Scaffold(
        appBar: appBar,
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              if (_showChart || !isLandscape)
                Container(
                  height: availableHeight * (isLandscape ? 0.80 : 0.25),
                  child: Chart(_recentTransactions),
                ),
              if (!_showChart || !isLandscape)
                Container(
                  height: availableHeight * (isLandscape ? 1 : 0.75),
                  child: TransactionList(_transactions, _deleteTransaction),
                ),
            ],
          ),
        ),
        floatingActionButton: Platform.isIOS
            ? Container()
            : FloatingActionButton(
                child: const Icon(Icons.add),
                onPressed: () => _openTransactioFormModal(context),
              ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      ),
    );
  }
}
