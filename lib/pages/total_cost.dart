import 'package:expeness/logic/expenses.dart';
import 'package:expeness/logic/helper.dart';
import 'package:flutter/material.dart';

class TotalCostPage extends StatefulWidget {
  TotalCostPage({super.key, required this.expenses}) : super();

  Expenses expenses;
  final data = [
    {'defaultTotalPeriod': 1, 'defaultPeriodText': 'day'},
    {'defaultTotalPeriod': 7, 'defaultPeriodText': 'week'},
    {'defaultTotalPeriod': 14, 'defaultPeriodText': 'bi-week'},
    {'defaultTotalPeriod': 30, 'defaultPeriodText': 'month'},
    {'defaultTotalPeriod': 365, 'defaultPeriodText': 'year'},
  ];

  @override
  State<TotalCostPage> createState() => _TotalCostPageState();
}

class _TotalCostPageState extends State<TotalCostPage> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        width: double.infinity,
        // enough height to show the content
        height: 540,
        padding: const EdgeInsets.only(top: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final item in widget.data)
              SizedBox(
                width: double.infinity,
                height: 100,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero,
                    ),
                    primary: widget.expenses.defaultTotalPeriod ==
                            item['defaultTotalPeriod']
                        ? Theme.of(context).colorScheme.primary
                        : null,
                    foregroundColor: widget.expenses.defaultTotalPeriod ==
                            item['defaultTotalPeriod']
                        ? Theme.of(context).colorScheme.onPrimary
                        : null,
                  ),
                  onPressed: () {
                    widget.expenses.defaultTotalPeriod =
                        item['defaultTotalPeriod'] as int;
                    widget.expenses.defaultPeriodText =
                        item['defaultPeriodText'] as String;
                    setState(() {});
                    Navigator.pop(context, widget.expenses);
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        widget.expenses.currency,
                        style: const TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w200,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        Helper.toCurrencyFormat(widget.expenses.totalDaily *
                            (item['defaultTotalPeriod'] as int)),
                        style: const TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Expanded(child: Container()),
                      Text(
                        item['defaultPeriodText'] as String,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w200,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
