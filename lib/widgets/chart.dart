import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart'; // Import for date formatting

class Chart extends StatefulWidget {
  final int indexx;
  Chart({Key? key, required this.indexx}) : super(key: key);

  @override
  State<Chart> createState() => _ChartState();
}

class _ChartState extends State<Chart> {
  late TooltipBehavior _tooltipBehavior;
  List<SalesData> _incomeData = []; // Initialize with empty list
  List<SalesData> _expenseData = []; // Initialize with empty list

  @override
  void initState() {
    print(widget.indexx);
    _tooltipBehavior = TooltipBehavior(enable: true);
    super.initState();
  }

// Function to get all the weeks in the year
  List<List<DateTime>> getWeeksInYear() {
    DateTime firstDate = getYearFirstDate();
    DateTime lastDate = getYearLastDate();
    List<List<DateTime>> weeksInYear = [];
    List<DateTime> currentWeek = [];

    // Loop through each day of the year
    for (int day = 0; day <= lastDate.difference(firstDate).inDays; day++) {
      DateTime currentDate = firstDate.add(Duration(days: day));

      // Check if it's the start of the week (Sunday)
      if (currentDate.weekday == DateTime.sunday && currentWeek.isNotEmpty) {
        weeksInYear.add(currentWeek); // Add the current week to the list
        currentWeek = []; // Start a new week
      }

      currentWeek.add(currentDate); // Add the current date to the week
    }

    // Add the last week if it has any dates
    if (currentWeek.isNotEmpty) {
      weeksInYear.add(currentWeek);
    }

    return weeksInYear;
  }

// Function to get all the weeks in the current month
  List<List<DateTime>> getWeeksInMonth() {
    DateTime firstDate = getMonthFirstDate();
    List<List<DateTime>> weeksInMonth = [];
    List<DateTime> currentWeek = [];

    // Loop through the days of the month
    for (int day = 0; day < DateTime(firstDate.year, firstDate.month + 1, 0).day; day++) {
      DateTime currentDate = firstDate.add(Duration(days: day));

      // Check if it's the start of the week (Sunday)
      if (currentDate.weekday == DateTime.sunday && currentWeek.isNotEmpty) {
        weeksInMonth.add(currentWeek); // Add the current week to the list
        currentWeek = []; // Start a new week
      }

      currentWeek.add(currentDate); // Add the current date to the week
    }

    // Add the last week if it has any dates
    if (currentWeek.isNotEmpty) {
      weeksInMonth.add(currentWeek);
    }

    return weeksInMonth;
  }

  List<DateTime> getDatesInWeek() {
    final startOfWeek = getWeekFirstDate();
    List<DateTime> datesInWeek = [];

    for (int i = 0; i < 7; i++) {
      datesInWeek.add(startOfWeek.add(Duration(days: i)));
    }

    return datesInWeek;
  }

  DateTime getWeekFirstDate() {
    final now = DateTime.now();
    return now.subtract(Duration(days: now.weekday % 7)); // Start from Sunday
  }

  DateTime getMonthFirstDate() {
    DateTime now = DateTime.now();
    return DateTime(now.year, now.month, 1);
  }

  DateTime getMonthLastDate() {
    DateTime now = DateTime.now();
    return DateTime(now.year, now.month + 1, 0); // Last day of current month
  }

  List<DateTime> getAllDatesInMonth() {
    DateTime now = DateTime.now();
    DateTime firstDate = DateTime(now.year, now.month, 1);
    DateTime lastDate = DateTime(now.year, now.month + 1, 0); // Last day of current month

    List<DateTime> allDates = [];

    for (int i = 0; i <= lastDate.day - firstDate.day; i++) {
      allDates.add(firstDate.add(Duration(days: i)));
    }

    return allDates;
  }

  DateTime getYearFirstDate() {
    DateTime now = DateTime.now();
    return DateTime(now.year, 1, 1); // January 1st of the current year
  }

// Function to get the last date of the current year
  DateTime getYearLastDate() {
    DateTime now = DateTime.now();
    return DateTime(now.year, 12, 31); // December 31st of the current year
  }

// Function to get ordinal suffix for week numbers
  String _getOrdinalSuffix(int number) {
    if (number % 10 == 1 && number % 100 != 11) {
      return "st";
    } else if (number % 10 == 2 && number % 100 != 12) {
      return "nd";
    } else if (number % 10 == 3 && number % 100 != 13) {
      return "rd";
    }
    return "th";
  }

  @override
  Widget build(BuildContext context) {
    if (widget.indexx == 0) {
      // Load week dates and data
      List<DateTime> weekDates = getDatesInWeek();
      List<String> formattedDates = weekDates
          .map((date) => DateFormat('EEE d').format(date)) // Format as "Sun 8", "Mon 9"
          .toList();

      // Sample income and expense data using the dynamic week days
      _incomeData = [
        SalesData(formattedDates[0], 0), // Sunday
        SalesData(formattedDates[1], 0), // Monday
        SalesData(formattedDates[2], 0), // Tuesday
        SalesData(formattedDates[3], 0), // Wednesday
        SalesData(formattedDates[4], 0), // Thursday
        SalesData(formattedDates[5], 0), // Friday
        SalesData(formattedDates[6], 50), // Saturday
      ];

      _expenseData = [
        SalesData(formattedDates[0], 0),
        SalesData(formattedDates[1], 0),
        SalesData(formattedDates[2], 0),
        SalesData(formattedDates[3], 0),
        SalesData(formattedDates[4], 0),
        SalesData(formattedDates[5], 0),
        SalesData(formattedDates[6], 100),
      ];
    } else if (widget.indexx == 1) {
      // Load week dates and data for the year
      List<List<DateTime>> weeksInYear = getWeeksInYear();

      // Sample income and expense data for each week
      _incomeData.clear();
      _expenseData.clear();

      for (int weekIndex = 0; weekIndex < weeksInYear.length && weekIndex < 52; weekIndex++) {
        String weekLabel = "${weekIndex + 1}${_getOrdinalSuffix(weekIndex + 1)} Week"; // "1st Week", "2nd Week", etc.

        // Assuming some sample income/expense values for each week
        _incomeData.add(SalesData(weekLabel, weekIndex == 0 ? 500 : 0)); // Sample income for the first week
        _expenseData.add(SalesData(weekLabel, weekIndex == 0 ? 200 : 0)); // Sample expense for the first week
      }
    } else if (widget.indexx == 2) {
      // Load month dates and data
      List<DateTime> allDatesInMonth = getAllDatesInMonth();

      // Clear previous data
      _incomeData.clear();
      _expenseData.clear();

      // Generate income and expense data for each date in the month
      for (DateTime date in allDatesInMonth) {
        String formattedDate = DateFormat('MMM d').format(date);

        // Sample income and expense values for each date (you can replace this with actual data)
        double incomeValue = (date.day * 50).toDouble(); // Example income data
        double expenseValue = (date.day * 30).toDouble(); // Example expense data

        // Add the formatted date and values to the data lists
        _incomeData.add(SalesData(formattedDate, incomeValue));
        _expenseData.add(SalesData(formattedDate, expenseValue));
      }
    } else if (widget.indexx == 3) {
      // Load year dates and data
      DateTime firstDateOfYear = getYearFirstDate();
      DateTime lastDateOfYear = getYearLastDate();

      // Format the dates as "MMM d" (e.g., "Jan 1", "Dec 31")
      String formattedFirstDate = DateFormat('MMM d').format(firstDateOfYear);
      String formattedLastDate = DateFormat('MMM d').format(lastDateOfYear);

      // Sample income and expense data for the year (e.g., first and last date)
      _incomeData = [
        SalesData(formattedFirstDate, 500), // Income on the first day of the year
        SalesData(formattedLastDate, 1000), // Income on the last day of the year
      ];

      _expenseData = [
        SalesData(formattedFirstDate, 200), // Expense on the first day of the year
        SalesData(formattedLastDate, 800), // Expense on the last day of the year
      ];
    }
    return Center(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9, // Ensure the chart has a proper width
        height: MediaQuery.of(context).size.height * 0.5, // Ensure the chart has a proper height
        child: SfCartesianChart(
          primaryXAxis: CategoryAxis(),
          legend: Legend(isVisible: true),
          tooltipBehavior: _tooltipBehavior,
          series: <ChartSeries<SalesData, String>>[
            // Series for Income
            LineSeries<SalesData, String>(
              name: 'Income',
              dataSource: _incomeData,
              xValueMapper: (SalesData sales, _) => sales.year,
              yValueMapper: (SalesData sales, _) => sales.sales,
              dataLabelSettings: DataLabelSettings(isVisible: true),
            ),
            // Series for Expenses
            LineSeries<SalesData, String>(
              name: 'Expenses',
              dataSource: _expenseData,
              xValueMapper: (SalesData sales, _) => sales.year,
              yValueMapper: (SalesData sales, _) => sales.sales,
              dataLabelSettings: DataLabelSettings(isVisible: true),
            ),
          ],
        ),
      ),
    );
  }
}

class SalesData {
  SalesData(this.year, this.sales);
  final String year; // Could rename 'year' to something like 'date' for clarity
  final double sales;
}
