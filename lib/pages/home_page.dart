import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expeness/logic/expenses.dart';
import 'package:expeness/logic/helper.dart';
import 'package:expeness/pages/total_cost.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:marquee_widget/marquee_widget.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _editMode = false;
  double _total = 0.0;
  Expenses? expenses = Expenses(null);

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
                        if (value != null)
                          {
                            setState(() {
                              expenses!
                                  .addExpense(value as Map<String, dynamic>);
                              _total = expenses!.defaultTotal;
                            })
                          }
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
                    .orderBy('amount', descending: true)
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
                                            if (value != null)
                                              {
                                                expenses!.updateExpense(value
                                                    as Map<String, dynamic>),
                                                _total = expenses!.defaultTotal,
                                                setState(() {})
                                              }
                                          });
                                },
                                child: const Text('Add an expense'),
                              ),
                            ],
                          ),
                        );
                      }
                      expenses?.loadSnapshot(snapshot);
                      _total = expenses!.defaultTotal;
                      return Padding(
                        padding: const EdgeInsets.only(left: 8, right: 8),
                        child: GridView.builder(
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            // depends on the screen size
                            crossAxisCount:
                                MediaQuery.of(context).size.width ~/ 190,
                            childAspectRatio: 0.83,
                            crossAxisSpacing: 8,
                          ),
                          itemCount: snapshot.data!.docs.length + 1,
                          itemBuilder: (BuildContext context, int index) {
                            if (index == snapshot.data!.docs.length) {
                              return Container(
                                margin: const EdgeInsets.only(top: 8),
                                decoration: BoxDecoration(
                                  color: Colors.transparent,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8))),
                                    backgroundColor: Colors.transparent,
                                    primary: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                    // onPrimary: Theme.of(context).colorScheme.primary,
                                    elevation: 0,
                                  ),
                                  onPressed: () {
                                    Navigator.pushNamed(context, '/expense',
                                            arguments: <String, dynamic>{})
                                        .then((value) => {
                                              if (value != null)
                                                {
                                                  expenses!.addExpense(value
                                                      as Map<String, dynamic>),
                                                  _total =
                                                      expenses!.defaultTotal,
                                                  setState(() {})
                                                }
                                            });
                                  },
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: const [
                                      Icon(Icons.add),
                                      SizedBox(height: 8),
                                      Text('Add an expense'),
                                    ],
                                  ),
                                ),
                              );
                            }
                            Map<String, dynamic>? expenseDict =
                                snapshot.data!.docs[index].data()
                                    as Map<String, dynamic>;
                            expenseDict['id'] = snapshot.data!.docs[index].id;

                            return Card(
                              margin: const EdgeInsets.only(top: 8),
                              clipBehavior: Clip.hardEdge,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  shape: const RoundedRectangleBorder(),
                                ),
                                onPressed: () {
                                  Navigator.pushNamed(context, '/expense',
                                          arguments: expenseDict)
                                      .then((value) => {
                                            if (value != null)
                                              {
                                                expenses!.updateExpense(value
                                                    as Map<String, dynamic>),
                                                _total = expenses!.defaultTotal,
                                                setState(() {})
                                              }
                                          });
                                },
                                child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        flex: 3,
                                        child: Center(
                                          child: Hero(
                                            tag: "${expenseDict['id']}-icon",
                                            child: Text(
                                              (expenseDict['icon'] ?? ' ')
                                                  .toString(),
                                              style: const TextStyle(
                                                  fontSize: 100),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                          flex: 2,
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                                bottom: 8, top: 8),
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceEvenly,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Marquee(
                                                  animationDuration:
                                                      Duration(seconds: 2),
                                                  backDuration:
                                                      Duration(seconds: 1),
                                                  pauseDuration:
                                                      Duration(seconds: 1),
                                                  child: Text(
                                                    expenseDict['title'] !=
                                                                null &&
                                                            expenseDict[
                                                                    'title'] !=
                                                                ''
                                                        ? expenseDict['title']
                                                            .toString()
                                                        : '',
                                                    style: const TextStyle(
                                                      fontSize: 20,
                                                    ),
                                                    overflow: TextOverflow.fade,
                                                    maxLines: 1,
                                                    softWrap: false,
                                                  ),
                                                ),
                                                Text(
                                                  expenseDict['amount'] !=
                                                              null &&
                                                          expenseDict[
                                                                  'amount'] !=
                                                              ''
                                                      ? "\$${Helper.toCurrencyFormat(expenseDict['amount'])}"
                                                      : '',
                                                  style: const TextStyle(
                                                      fontSize: 15),
                                                ),
                                              ],
                                            ),
                                          ))
                                    ]),
                              ),
                            );
                          },
                        ),
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
          Hero(
            tag: 'total-${expenses!.defaultTotalPeriod}',
            child: SizedBox(
              width: double.infinity,
              height: 100,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero,
                  ),
                ),
                onPressed: () {
                  // open bottom sheet, and read the value returned
                  showModalBottomSheet(
                    context: context,
                    enableDrag: true,
                    isScrollControlled: true,
                    builder: (context) {
                      return TotalCostPage(expenses: expenses!);
                    },
                  ).then((value) {
                    if (value != null) {
                      value = value as Expenses;
                      expenses!.defaultPeriodText = value.defaultPeriodText;
                      expenses!.defaultTotalPeriod = value.defaultTotalPeriod;
                      _total = expenses!.defaultTotal;
                      setState(() {});
                    }
                  });
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      '\$',
                      style: const TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w200,
                      ),
                    ),
                    SizedBox(width: 8),
                    Text(
                      Helper.toCurrencyFormat(_total),
                      style: const TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      ' / ${expenses!.defaultPeriodText}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w200,
                      ),
                    ),
                    Expanded(child: Container()),
                    Transform.rotate(
                      angle: -90 * 3.14159 / 180,
                      child: const Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 24,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
