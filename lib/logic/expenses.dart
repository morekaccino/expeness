import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Expenses {
  final List<Map<String, dynamic>> expenses = [];
  var defaultTotalPeriod = 1;
  var defaultPeriodText = 'day';
  final currency = '\$';

  Expenses(snapshot) {
    if (snapshot != null) {
      loadSnapshot(snapshot);
    }
  }

  void loadSnapshot(snapshot) {
    expenses.clear();
    for (var expense in snapshot.data!.docs ?? []) {
      final expenseId = expense.id;
      final expenseData = expense.data() as Map<String, dynamic>;
      expenseData['id'] = expenseId;
      expenses.add(expenseData);
    }
  }

  void addExpense(Map<String, dynamic> expense) {
    expenses.add(expense);
  }

  void removeExpense(String id) {
    // find the index of the expense with the given id
    final index = expenses.indexWhere((expense) => expense['id'] == id);
    // remove the expense from the list if it exists
    if (index != -1) {
      expenses.removeAt(index);
    }
  }

  void removeAllExpenses() {
    expenses.clear();
  }

  void updateExpense(Map<String, dynamic> expense) {
    // find the index of the expense with the given id
    final index = expenses.indexWhere((e) => e['id'] == expense['id']);
    // update the expense if it exists
    if (index != -1) {
      expenses[index] = expense;
    }
    // if the expense does not exist, add it
    else {
      addExpense(expense);
    }
  }

  double get totalDaily {
    double total = 0.0;
    if (expenses.isEmpty) {
      return total;
    }
    for (var expense in expenses) {
      try {
        var temp = expense['amount'] / expense['period'];
        if (expense['tax'] != null && expense['tax']) {
          temp *= expense['taxAmount'] / 100 + 1;
        }
        total += temp;
      }
      catch (e) {
        print('Error: $e');
      }
    }
    return total;
  }

  double get totalYearly {
    return totalDaily * 365;
  }

  double get totalMonthly {
    return totalDaily * 30;
  }

  double get totalBiWeekly {
    return totalWeekly * 2;
  }

  double get totalWeekly {
    return totalDaily * 7;
  }

  double get defaultTotal {
    return totalDaily * defaultTotalPeriod;
  }

  String get defaultPeriod {
    return defaultPeriodText;
  }

}