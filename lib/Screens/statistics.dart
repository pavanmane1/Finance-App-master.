import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/transactionsmodel.dart'; // Import your model
import '../widgets/chart.dart'; // Import your chart widget

class Statistics extends StatefulWidget {
  const Statistics({Key? key}) : super(key: key);

  @override
  State<Statistics> createState() => _StatisticsState();
}

ValueNotifier<int> kj = ValueNotifier(0);

class _StatisticsState extends State<Statistics> {
  List<String> day = ['Day', 'Week', 'Month', 'Year'];
  List<Transactionsmodel> expensesData = [];
  List<Transactionsmodel> incomeData = [];
  List<Transactionsmodel> expenseData = [];
  int index_color = 0;

  @override
  void initState() {
    super.initState();
    fetchExpensesData(); // Initial API call
  }

  Future<void> fetchExpensesData() async {
    DateTime startDate;
    DateTime endDate = DateTime.now();

    switch (index_color) {
      case 0: // Day
        startDate = DateTime.now();
        endDate = startDate;
        break;
      case 1: // Week
        startDate = getWeekFirstDate();
        endDate = getWeekLastDate();
        break;
      case 2: // Month
        startDate = getFirstDateOfMonth(endDate);
        endDate = getLastDateOfMonth(endDate);
        break;
      case 3: // Year
        startDate = getFirstDateOfYear(endDate);
        endDate = getLastDateOfYear(endDate);
        break;
      default:
        startDate = endDate;
    }

    try {
      expensesData = await fetchExpenses(startDate, endDate);
      filterData(); // Separate the data into income and expenses
      setState(() {}); // Update the UI with new data
    } catch (e) {
      print('Error fetching expenses: $e');
    }
  }

  Future<List<Transactionsmodel>> fetchExpenses(DateTime startDate, DateTime endDate) async {
    final url =
        'http://192.168.1.45:8081/api/expensetracking/transaction/range?user_id=1&startDate=${startDate.toIso8601String()}&endDate=${endDate.toIso8601String()}';
    // print(url.toString());
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((item) => Transactionsmodel.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load expenses');
    }
  }

  void filterData() {
    List<DateTime> weekDates = getDatesInWeek();
    for (var date in weekDates) {
      print(date.toIso8601String()); // Print each date in ISO 8601 format on a new line
    }
    // // Filtering income and expense data
    incomeData = expensesData.where((item) => item.category.trim() == 'Income').toList();
    expenseData = expensesData.where((item) => item.category.trim() == 'Expense').toList();
  }

  List<DateTime> getDatesInWeek() {
    final startOfWeek = getWeekFirstDate();
    final endOfWeek = getWeekLastDate();

    List<DateTime> datesInWeek = [];

    for (int i = 0; i < 7; i++) {
      datesInWeek.add(startOfWeek.add(Duration(days: i)));
    }

    return datesInWeek;
  }

  DateTime getWeekFirstDate() {
    final now = DateTime.now();
    // Calculate the start of the week (last Sunday)
    return now.subtract(Duration(days: now.weekday % 7)); // Sunday
  }

  DateTime getWeekLastDate() {
    final startOfWeek = getWeekFirstDate();
    // Calculate the end of the week (next Sunday)
    return startOfWeek.add(Duration(days: 6)); // Next Sunday
  }

  DateTime getFirstDateOfMonth(DateTime date) {
    return DateTime(date.year, date.month, 1); // First date of the month
  }

  DateTime getLastDateOfMonth(DateTime date) {
    int nextMonth = date.month == 12 ? 1 : date.month + 1; // Handle December
    int year = date.month == 12 ? date.year + 1 : date.year; // Increment year if December
    return DateTime(year, nextMonth, 0); // Last date of the month
  }

  DateTime getFirstDateOfYear(DateTime date) {
    return DateTime(date.year, 1, 1);
  }

  DateTime getLastDateOfYear(DateTime date) {
    return DateTime(date.year, 12, 31);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ValueListenableBuilder<int>(
        valueListenable: kj,
        builder: (BuildContext context, value, Widget? child) {
          return custom();
        },
      ),
    );
  }

  CustomScrollView custom() {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Column(
            children: [
              SizedBox(height: 20),
              Text(
                'Statistics',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ...List.generate(
                      day.length,
                      (index) {
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              index_color = index; // Update the selected time range
                              kj.value = index; // Trigger UI update through ValueNotifier
                              fetchExpensesData(); // Call the API once on selection
                            });
                          },
                          child: Container(
                            height: 40,
                            width: 80,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: index_color == index
                                  ? Color.fromARGB(255, 47, 125, 121) // Active state color
                                  : Colors.white, // Inactive state color
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              day[index],
                              style: TextStyle(
                                color: index_color == index
                                    ? Colors.white // Active text color
                                    : Colors.black, // Inactive text color
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              // Chart(
              //     incomeData: incomeData.map((e) {
              //       double amountValue = double.tryParse(e.amount) ?? 0.0; // Convert amount to double
              //       DateTime date = DateTime.parse(e.transactionDate); // Convert String to DateTime
              //       return SalesData(date, amountValue);
              //     }).toList(),
              //     expenseData: expenseData.map((e) {
              //       double amountValue = double.tryParse(e.amount) ?? 0.0; // Convert amount to double
              //       DateTime date = DateTime.parse(e.transactionDate); // Convert String to DateTime
              //       return SalesData(date, amountValue);
              //     }).toList(),
              //     timeFrame: day[index_color]),
              Chart(
                indexx: index_color,
              ),
              SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Top Spending',
                      style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              return ListTile(
                title: Text(
                  expensesData[index].categoryType,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(
                  'Date: ${expensesData[index].transactionDate}', // Display date here
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                trailing: Text(
                  expensesData[index].amount.toString(), // Ensure this is formatted correctly
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 19,
                    color: expensesData[index].category.trim() == 'Income' ? Colors.green : Colors.red,
                  ),
                ),
              );
            },
            childCount: expensesData.length,
          ),
        ),
      ],
    );
  }
}
