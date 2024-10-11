import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:managment/data/model/add_date.dart'; // Adjust this import based on your data model
import 'package:managment/models/transactionsmodel.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<Transactionsmodel> transactions = []; // List to hold transactions

  @override
  void initState() {
    super.initState();
    fetchTransactions();
  }

// List of days of the week
  List<String> day = [
    'Sunday',
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
  ];

  Future<void> fetchTransactions() async {
    final response = await http.get(Uri.parse('http://192.168.1.45:8081/api/expensetracking/transactions/1'));

    if (response.statusCode == 200 || response.statusCode == 201) {
      final List<dynamic> jsonResponse = json.decode(response.body);

      // Assuming the response is a list of transactions
      setState(() {
        transactions = jsonResponse.map((transaction) => Transactionsmodel.fromJson(transaction)).toList();
      });
    } else {
      throw Exception('Failed to load transactions');
    }
  }

  // Controller for budget input
  final TextEditingController _budgetController = TextEditingController();
  double? budgetAmount;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: SizedBox(height: 350, child: _head()),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Transactions History',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 19,
                        color: Colors.black,
                      ),
                    ),
                    PopupMenuButton<String>(
                      icon: Icon(
                        Icons.more_horiz_sharp,
                        color: const Color.fromARGB(255, 49, 49, 49),
                      ),
                      onSelected: (value) {
                        // Handle the selected option
                        if (value == 'see_all') {
                          // Implement your logic for "See All"
                          print("See All selected");
                        } else if (value == 'see_month') {
                          // Implement your logic for "See Month"
                          print("See Month selected");
                        }
                      },
                      itemBuilder: (BuildContext context) {
                        return [
                          const PopupMenuItem<String>(
                            value: 'see_all',
                            child: Text('See All'),
                          ),
                          const PopupMenuItem<String>(
                            value: 'see_month',
                            child: Text('See Month'),
                          ),
                        ];
                      },
                    ),
                  ],
                ),
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  return getList(transactions[index], index);
                },
                childCount: transactions.length,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmationDialog(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Item'),
          content: Text('Are you sure you want to delete this item?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  transactions.removeAt(index); // Remove the item
                });
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  Widget getList(Transactionsmodel transaction, int index) {
    return Dismissible(
        key: UniqueKey(),
        onDismissed: (direction) {
          _showDeleteConfirmationDialog(index);
        },
        child: get(transaction) ?? Container());
  }

  ListTile get(Transactionsmodel transaction) {
    DateTime dateTime = DateTime.parse(transaction.transactionDate);

    return ListTile(
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(5),
        child: Icon(
          Icons.shopping_cart, // Use an appropriate icon
          size: 40,
          color: Colors.grey, // Set color as needed
        ),
      ),
      title: Text(
        transaction.categoryType,
        style: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        '${day[dateTime.weekday - 1]}  ${dateTime.year}-${dateTime.month}-${dateTime.day}',
        style: TextStyle(
          fontWeight: FontWeight.w600,
        ),
      ),
      trailing: Text(
        transaction.amount,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 19,
          color: transaction.category.trim() == 'Income' ? Colors.green : Colors.red,
        ),
      ),
    );
  }

  Widget _head() {
    final currentTime = DateTime.now();
    String greeting = 'Good afternoon';

    if (currentTime.hour < 12) {
      greeting = 'Good morning';
    } else if (currentTime.hour >= 18) {
      greeting = 'Good night';
    }

    return Stack(
      children: [
        Column(
          children: [
            Container(
              width: double.infinity,
              height: 240,
              decoration: BoxDecoration(
                color: Color(0xff368983),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Stack(
                children: [
                  Positioned(
                      top: 35,
                      left: 285,
                      child: Row(
                        children: [
                          Text(
                            'Notify',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w300,
                              color: Colors.white,
                            ),
                          ),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(7),
                            child: IconButton(
                              icon: Icon(
                                Icons.notification_add_outlined,
                                size: 30,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                _showBudgetPopup();
                              },
                            ),
                          ),
                        ],
                      )),
                  Padding(
                    padding: const EdgeInsets.only(top: 35, left: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          greeting,
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 18,
                            color: Color.fromARGB(255, 224, 223, 223),
                          ),
                        ),
                        Text(
                          'Pavan',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 22,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        Positioned(
          top: 140,
          left: 37,
          child: Container(
            height: 170,
            width: 320,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color.fromARGB(255, 43, 109, 104), Color(0xff214547)],
              ),
              boxShadow: [
                BoxShadow(
                  color: Color.fromRGBO(47, 125, 121, 0.3),
                  offset: Offset(0, 6),
                  blurRadius: 12,
                  spreadRadius: 6,
                ),
              ],
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              children: [
                SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total Balance',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'Budget',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 7),
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 15),
                      child: Row(
                        children: [
                          Text(
                            '\₹ ${total()}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 120),
                    Padding(
                      padding: const EdgeInsets.only(left: 15),
                      child: Row(
                        children: [
                          Text(
                            '\₹ ${total()}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 25),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 13,
                            backgroundColor: Color.fromARGB(255, 85, 145, 141),
                            child: Icon(
                              Icons.arrow_downward_sharp,
                              color: Colors.white,
                              size: 19,
                            ),
                          ),
                          SizedBox(width: 7),
                          Text(
                            'Income',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                              color: Color.fromARGB(255, 216, 216, 216),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 13,
                            backgroundColor: Color.fromARGB(255, 85, 145, 141),
                            child: Icon(
                              Icons.arrow_upward,
                              color: Colors.white,
                              size: 19,
                            ),
                          ),
                          SizedBox(width: 7),
                          Text(
                            'Expenses',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                              color: Color.fromARGB(255, 216, 216, 216),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 6),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '\₹ ${income()}',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 17,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        '\₹ -${expenses()}',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 17,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  double total() {
    return transactions.fold(0.0, (sum, transaction) {
      String trimmedCategory = transaction.category.trim(); // Trim whitespace from category

      if (trimmedCategory == "Income") {
        return sum + double.parse(transaction.amount); // Add income
      } else if (trimmedCategory == "Expense") {
        return sum - double.parse(transaction.amount); // Subtract expense
      }
      return sum;
    });
  }

  double income() {
    return transactions.fold(0.0, (sum, transaction) {
      String trimmedCategory = transaction.category.trim(); // Trim whitespace from category

      if (trimmedCategory == "Income") {
        return sum + double.parse(transaction.amount); // Add only income transactions
      }
      return sum;
    });
  }

  double expenses() {
    return transactions.fold(0.0, (sum, transaction) {
      // Trim whitespaces from category string before comparison
      bool isCheck = transaction.category.trim() == "Expense";
      if (isCheck) {
        print(transaction.category + " +++++++++++++");
        return sum + double.parse(transaction.amount); // Add only expense transactions
      }
      return sum;
    });
  }

  void _showBudgetPopup() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Set Budget'),
          content: TextField(
            controller: _budgetController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(hintText: "Enter budget amount"),
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  budgetAmount = double.tryParse(_budgetController.text);
                });
                _budgetController.clear();
                Navigator.of(context).pop();
              },
              child: Text('Set'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }
}
