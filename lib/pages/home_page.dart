import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _editMode = false;
  double _total = 0.0;

  double _calculateTotalPerDay(List<Map<String, dynamic>> expenses) {
    double total = 0.0;
    for (var expense in expenses) {
      var temp = expense['amount'] / expense['period'];
      if (expense['tax'] != null && expense['tax']) {
        temp *= expense['taxAmount'] / 100 + 1;
      }
      total += temp;
    }
    _total = total;
    return total;
  }

  @override
  Widget build(BuildContext context) {
    // write expenses to firestore here, and the url is user.uid
    var user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.list),
          onPressed: () {
            setState(() {
              _editMode = !_editMode;
            });
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.pushNamed(
                      context, '/expense', arguments: <String, dynamic>{})
                  .then((value) => {
                        if (value != null) {setState(() {})}
                      });
              setState(() {
                _editMode = false;
              });
            },
          ),
        ],
        title: const Text('Expenses'),
        elevation: 1,
      ),
      body: Column(
        children: [
          Expanded(
            child: RefreshIndicator.adaptive(
              onRefresh: () async {
                // refresh the list of expenses
                setState(() {});
              },
              child: FutureBuilder<QuerySnapshot>(
                future: FirebaseFirestore.instance
                    .collection('users')
                    .doc(user!.uid)
                    .collection('expenses')
                    .get(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    if (snapshot.hasError) {
                      return Center(
                        child: Text('Error: ${snapshot.error}'),
                      );
                    }
                    if (snapshot.hasData) {
                      if (snapshot.data!.docs.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Text('No expenses found'),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.pushNamed(context, '/expense',
                                          arguments: <String, dynamic>{})
                                      .then((value) => {
                                            if (value != null) {setState(() {})}
                                          });
                                  setState(() {
                                    _editMode = false;
                                  });
                                },
                                child: const Text('Add an expense'),
                              ),
                            ],
                          ),
                        );
                      }
                      _calculateTotalPerDay(snapshot.data!.docs
                          .map((e) => e.data() as Map<String, dynamic>)
                          .toList());
                      return ListView.builder(
                        itemCount: snapshot.data!.docs.length,
                        itemBuilder: (BuildContext context, int index) {
                          Map<String, dynamic>? expenseDict =
                              snapshot.data!.docs[index].data()
                                  as Map<String, dynamic>;
                          expenseDict['id'] = snapshot.data!.docs[index].id;

                          return Dismissible(
                            key: Key(expenseDict['id'].toString()),
                            onDismissed: (direction) {
                              // remove the expense from firestore
                              FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(user.uid)
                                  .collection('expenses')
                                  .doc(expenseDict?['id'])
                                  .delete()
                                  .then((value) => {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            duration: Duration(seconds: 1),
                                            content: SizedBox(
                                              height: 40,
                                              child: Center(
                                                child: Text(
                                                    '${expenseDict?['title']} dismissed',
                                                    style: const TextStyle(
                                                        fontSize: 20)),
                                              ),
                                            ),
                                          ),
                                        ),
                                      })
                                  .then((value) => {setState(() {})});
                            },
                            direction: DismissDirection.endToStart,
                            background: Container(
                              color: Theme.of(context).colorScheme.error,
                              // Right
                              child: const Align(
                                alignment: Alignment.centerRight,
                                child: Padding(
                                  padding: EdgeInsets.all(16.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.delete,
                                        color: Colors.white,
                                      ),
                                      SizedBox(width: 2),
                                      // Text(
                                      //   'Delete',
                                      //   style: TextStyle(
                                      //       color: Colors.white, fontSize: 20),
                                      // ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors.transparent,
                                child: Text(
                                  (expenseDict['icon'] ?? ' ').toString(),
                                  style: const TextStyle(fontSize: 27),
                                ),
                              ),
                              title: expenseDict['title'] != null &&
                                      expenseDict['title'] != ''
                                  ? Text(expenseDict['title'].toString())
                                  : null,
                              subtitle: expenseDict['subtitle'] != null &&
                                      expenseDict['subtitle'] != ''
                                  ? Text(expenseDict['subtitle'].toString())
                                  : null,
                              trailing: expenseDict['amount'] != null &&
                                      expenseDict['amount'] != ''
                                  ? Text(
                                      '\$${expenseDict["amount"].toString()}',
                                      style: const TextStyle(fontSize: 15))
                                  : null,
                              // opne ExpensePage and pass the expense object
                              onTap: () {
                                Navigator.pushNamed(context, '/expense',
                                        arguments: expenseDict)
                                    .then((value) => {
                                          if (value != null)
                                            {
                                              setState(() {
                                                expenseDict = value
                                                    as Map<String, dynamic>?;
                                              })
                                            }
                                        });
                              },
                            ),
                          );
                        },
                      );
                    }
                  }
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                },
              ),
            ),
          ),
          SizedBox(
            width: double.infinity,
            height: 100,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.zero,
                ),
              ),
              onPressed: () {
                // open ExpensePage and pass the expense
              },
              child: Text(
                'Total: \$${_total.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
