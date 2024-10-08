import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class Chart extends StatefulWidget {
  final int indexx;
  Chart({Key? key, required this.indexx}) : super(key: key);

  @override
  State<Chart> createState() => _ChartState();
}

class _ChartState extends State<Chart> {
  late TooltipBehavior _tooltipBehavior;

  @override
  void initState() {
    _tooltipBehavior = TooltipBehavior(enable: true);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        child: SfCartesianChart(
          // Initialize category axis
          primaryXAxis: CategoryAxis(),
          legend: Legend(isVisible: true),
          tooltipBehavior: _tooltipBehavior,
          series: <ChartSeries<SalesData, String>>[
            // Series for Income
            LineSeries<SalesData, String>(
              name: 'Income',
              dataSource: <SalesData>[
                SalesData('Jan', 5000),
                SalesData('Feb', 400),
                SalesData('Mar', 60),
                SalesData('Apr', 70),
                SalesData('May', 80),
              ],
              xValueMapper: (SalesData sales, _) => sales.year,
              yValueMapper: (SalesData sales, _) => sales.sales,
              dataLabelSettings: DataLabelSettings(isVisible: true),
            ),
            // Series for Expenses
            LineSeries<SalesData, String>(
              name: 'Expenses',
              dataSource: <SalesData>[
                SalesData('Jan', 0),
                SalesData('Feb', 28),
                SalesData('Mar', 3500),
                SalesData('Apr', 32),
                SalesData('May', 40),
              ],
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
  final String year;
  final double sales;
}
