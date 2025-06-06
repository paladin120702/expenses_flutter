import 'package:expenses/models/transaction.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TransactionList extends StatelessWidget {
  final List<Transaction> transactions;
  final void Function(String) onRemove;
  const TransactionList(this.transactions, this.onRemove, {super.key});

  @override
  Widget build(BuildContext context) {
    return transactions.isEmpty
        ? LayoutBuilder(builder: (ctx, constraints) {
            return Column(
              children: [
                SizedBox(
                  height: constraints.maxHeight * 0.07,
                ),
                Container(
                  height: constraints.maxHeight * 0.15,
                  child: const Text(
                    'No transaction registered!',
                  ),
                ),
                SizedBox(
                  height: constraints.maxHeight * 0.01,
                ),
                Container(
                  height: constraints.maxHeight * 0.60,
                  child: Image.asset(
                    'assets/images/waiting.png',
                    fit: BoxFit.cover,
                  ),
                ),
              ],
            );
          })
        : ListView.builder(
            itemCount: transactions.length,
            itemBuilder: (ctx, index) {
              final tr = transactions[index];
              return Card(
                elevation: 5,
                margin: const EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 5,
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    radius: 30,
                    child: Padding(
                      padding: const EdgeInsets.all(6),
                      child: FittedBox(
                        child: Text('\$${tr.value}'),
                      ),
                    ),
                  ),
                  title: Text(
                    tr.title,
                  ),
                  subtitle: Text(
                    DateFormat('MMM d y').format(tr.date),
                  ),
                  trailing: MediaQuery.of(context).size.width > 500
                      ? TextButton.icon(
                          onPressed: () => onRemove(tr.id),
                          label: const Text('Delete'),
                          style: TextButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.red,
                          ),
                        )
                      : IconButton(
                          onPressed: () => onRemove(tr.id),
                          icon: const Icon(Icons.delete),
                          color: Colors.red,
                        ),
                ),
              );
            },
          );
  }
}
