import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';

class ExpensePage extends StatefulWidget {
  const ExpensePage({super.key});

  static const route = '/expense';

  @override
  State<ExpensePage> createState() => _ExpensePageState();
}

class _ExpensePageState extends State<ExpensePage> {
  final _amountController = TextEditingController();
  final _titleController = TextEditingController();
  final _taxController = TextEditingController();
  late final randomIcon = randomIconGenerator();

  String randomIconGenerator() {
    var random = Random();
    var emojiCodePoint = 0x1F300 + random.nextInt(0x1F3F0 - 0x1F300);
    return String.fromCharCode(emojiCodePoint);
  }

  @override
  Widget build(BuildContext context) {
    final expense =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;

    // if expense has no icon, set it to a random icon
    if (expense['icon'] == null || expense['icon'] == "") {
      expense['icon'] = randomIcon;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text((expense['title'] ?? '').toString()),
      ),
      // editable name, amount, period
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            bottom: 100,
            child: SingleChildScrollView(
              clipBehavior: Clip.none,
              child: Column(
                children: [
                  // textboxes
                  Padding(
                    padding: const EdgeInsets.all(8),
                    // icon and title textboxes in a row, both modifiable
                    child: Row(
                      children: [
                        // icon
                        Container(
                          height: 60,
                          width: 60,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: IconButton(
                            icon: Text(
                                (expense['icon'] ?? randomIcon).toString(),
                                style: const TextStyle(fontSize: 27)),
                            onPressed: () async {
                              // showModalBottomSheet to show the emoji picker
                              await showModalBottomSheet(
                                context: context,
                                backgroundColor:
                                    Theme.of(context).colorScheme.background,
                                // isScrollControlled: true,
                                builder: (context) {
                                  return DraggableScrollableSheet(
                                    expand: false, // Set this to true if you want the sheet to be expandable
                                    initialChildSize: 0.9, // Set the initial height of the sheet
                                    maxChildSize: 0.9, // Set the maximum height of the sheet
                                    builder: (context, scrollController) {
                                      return Container(
                                        color: Theme.of(context).colorScheme.background,
                                        child: SafeArea(
                                          child: EmojiPicker(
                                            config: Config(
                                              height: 200,
                                              bottomActionBarConfig: BottomActionBarConfig(
                                                backgroundColor: Theme.of(context).colorScheme.background,
                                                buttonColor: Theme.of(context).colorScheme.background,
                                                showBackspaceButton: true,
                                                buttonIconColor: Theme.of(context).colorScheme.primary,
                                              ),
                                              emojiViewConfig: EmojiViewConfig(
                                                backgroundColor: Theme.of(context).colorScheme.background,
                                                buttonMode: ButtonMode.CUPERTINO,
                                              ),
                                              categoryViewConfig: CategoryViewConfig(
                                                backgroundColor: Theme.of(context).colorScheme.background,
                                                iconColorSelected: Theme.of(context).colorScheme.primary,
                                                indicatorColor: Theme.of(context).colorScheme.primary,
                                                tabBarHeight: 50,
                                              ),
                                            ),
                                            onEmojiSelected: (category, emoji) {
                                              Navigator.of(context).pop(emoji.emoji);
                                            },
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                },
                              ).then((value) => {
                                    if (value != null)
                                      {
                                        setState(() {
                                          expense['icon'] = value;
                                        })
                                      }
                                  });
                            },
                          ),
                        ),
                        SizedBox(width: 8),
                        // title
                        Expanded(
                          child: TextField(
                            decoration: const InputDecoration(
                              labelText: 'Title',
                            ),
                            controller: _titleController
                              ..text = (expense['title'] ?? '').toString(),
                            onChanged: (value) {
                              setState(() {
                                expense['title'] = value;
                                // put cursor at the end
                                _titleController.selection =
                                    TextSelection.fromPosition(TextPosition(
                                        offset: _titleController.text.length));
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  // amount
                  Padding(
                    padding: const EdgeInsets.all(8),
                    // only number keyboard is allowed ,and only numbers are allowed, if non-numeric value is entered, it is ignored
                    child: TextField(
                        decoration: const InputDecoration(
                          labelText: 'Amount',
                        ),
                        controller: _amountController
                          ..text = (expense['amount'] ?? '').toString(),
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        onChanged: (value) {
                          var isDouble = double.tryParse(value);
                          var parsable = isDouble != null;
                          if (_amountController.text.isNotEmpty && parsable) {
                            expense['amount'] = double.parse(value);
                          } else {
                            expense['amount'] = 0;
                            _amountController.text = '';
                          }
                        }),
                  ),
                  // choose billing period, it is 2x2 grid of buttons, daily, weekly, monthly, yearly. when pressed, it sets the period in the expense object, and updates the UI. it also becomes the selected button
                  SizedBox(height: 18),
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Row(
                      children: [
                        // daily
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                expense['period'] = 1;
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              primary: expense['period'] == 1
                                  ? Theme.of(context).colorScheme.primary
                                  : null,
                              foregroundColor: expense['period'] == 1
                                  ? Theme.of(context).colorScheme.onPrimary
                                  : null,
                            ),
                            child: const Text('Daily'),
                          ),
                        ),
                        SizedBox(width: 8),
                        // weekly
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                expense['period'] = 7;
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              primary: expense['period'] == 7
                                  ? Theme.of(context).colorScheme.primary
                                  : null,
                              foregroundColor: expense['period'] == 7
                                  ? Theme.of(context).colorScheme.onPrimary
                                  : null,
                            ),
                            child: const Text('Weekly'),
                          ),
                        ),
                        // monthly
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Row(
                      children: [
                        // monthly
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                expense['period'] = 365 / 12;
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              primary: expense['period'] == 365 / 12
                                  ? Theme.of(context).colorScheme.primary
                                  : null,
                              foregroundColor: expense['period'] == 365 / 12
                                  ? Theme.of(context).colorScheme.onPrimary
                                  : null,
                            ),
                            child: const Text('Monthly'),
                          ),
                        ),
                        SizedBox(width: 8),
                        // yearly
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                expense['period'] = 365;
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              primary: expense['period'] == 365
                                  ? Theme.of(context).colorScheme.primary
                                  : null,
                              foregroundColor: expense['period'] == 365
                                  ? Theme.of(context).colorScheme.onPrimary
                                  : null,
                            ),
                            child: const Text('Yearly'),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Add Tax
                  SizedBox(height: 18),
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Add Tax
                        Checkbox(
                            value: expense['tax'] ?? false,
                            onChanged: (value) {
                              setState(() {
                                expense['tax'] = value;
                              });
                            }),
                        SizedBox(width: 8),
                        // Tax amount
                        Expanded(
                          child: TextField(
                              enabled: expense['tax'] ?? false,
                              decoration: const InputDecoration(
                                labelText: 'Tax Percentage',
                              ),
                              controller: _taxController
                                ..text =
                                    (expense['taxAmount'] ?? '').toString(),
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                      decimal: true),
                              onChanged: (value) {
                                var isDouble = double.tryParse(value);
                                var parsable = isDouble != null;
                                if (_taxController.text.isNotEmpty &&
                                    parsable) {
                                  expense['taxAmount'] = double.parse(value);
                                } else {
                                  expense['taxAmount'] = 0;
                                  _taxController.text = '';
                                }
                              }),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // save button
          Positioned(
            bottom: 0,
            width: MediaQuery.of(context).size.width,
            height: 100,
            child: SizedBox(
              width: double.infinity,
              height: 100,
              child: ElevatedButton(
                // no round corners
                style: ElevatedButton.styleFrom(
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero,
                  ),
                  shadowColor: Colors.transparent,
                ),
                onPressed: () {
                  // check if amount is valid and set it in the expense object
                  var isDouble = double.tryParse(_amountController.text);
                  var parsable = isDouble != null;
                  if (_amountController.text.isNotEmpty && parsable) {
                    expense['amount'] = double.parse(_amountController.text);
                  } else {
                    // invalid amount snack bar
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        duration: Duration(seconds: 1),
                        content: SizedBox(
                          height: 40,
                          child: Center(
                            child: Text('Invalid amount',
                                style: TextStyle(fontSize: 20)),
                          ),
                        ),
                      ),
                    );
                    return;
                  }

                  // if anything changed, save the expense object to the database
                  if (expense['icon'] == null ||
                      expense['icon'] == "" ||
                      expense['title'] == null ||
                      expense['title'] == "" ||
                      expense['amount'] == null ||
                      expense['amount'] == 0 ||
                      expense['period'] == null ||
                      expense['period'] == 0 ||
                      (expense['tax'] != null &&
                          expense['tax'] &&
                          (expense['taxAmount'] == null ||
                              expense['taxAmount'] == 0))) {
                    // please fill in all fields snack bar
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        duration: Duration(seconds: 1),
                        content: SizedBox(
                            height: 40,
                            child: Center(
                                child: Text('Please fill in all fields',
                                    style: TextStyle(fontSize: 20)))),
                      ),
                    );
                    return;
                  }

                  // save the expense object to the database
                  var userID = FirebaseAuth.instance.currentUser!.uid;
                  FirebaseFirestore.instance
                      .collection('users')
                      .doc(userID)
                      .collection('expenses')
                      .doc(expense['id'])
                      .set(expense);
                  Navigator.of(context).pop(expense);
                },
                child: const Text(
                  'Save',
                  style: TextStyle(fontSize: 20),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
