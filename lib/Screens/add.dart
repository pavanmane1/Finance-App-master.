import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AddScreen extends StatefulWidget {
  const AddScreen({super.key});

  @override
  State<AddScreen> createState() => _AddScreenState();
}

class _AddScreenState extends State<AddScreen> {
  DateTime date = DateTime.now();
  String? selectedItem; // Selected category
  String? selectedItemType; // Selected type
  final TextEditingController explanationController = TextEditingController();
  final TextEditingController amountController = TextEditingController();

  List<Map<String, dynamic>> categories = []; // Store categories with types
  final List<String> itemTypeOptions = ['Income', 'Expense'];
  final List<String> _itemei = ['Income', "Expense"];
  String? selctedItemi;

  @override
  void initState() {
    super.initState();
    fetchCategories(); // Fetch categories when the screen loads
  }

  // Function to fetch categories from the API
  Future<void> fetchCategories() async {
    final url = 'http://192.168.1.45:8081/api/expensetracking/categories'; // Replace with your API URL
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        setState(() {
          // Store categories with their types
          categories = data.map((category) {
            return {
              'category_id': category['category_id'],
              'category_name': category['category_name'],
              'types': category['types'], // Store the types directly
            };
          }).toList();
        });
      } else {
        print('Failed to load categories');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  // Function to create a new transaction
  bool isLoading = false; // Add a state to track the loading status

  // Function to create a new transaction
  Future<void> createTransaction() async {
    setState(() {
      isLoading = true; // Start the loading indicator
    });

    final url = 'http://192.168.1.45:8081/api/expensetracking/transactions'; // Replace with your API URL
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'user_id': 1, // Replace with the actual user ID
          'category_id': categories.firstWhere((cat) => cat['category_name'] == selectedItem)['category_id'],
          'amount': double.tryParse(amountController.text) ?? 0,
          'transaction_date': date.toIso8601String(),
          'description': explanationController.text,
          'category_type': selectedItemType // Type of the transaction (Income/Expense)
        }),
      );
      print(jsonEncode({
        'user_id': 'your_user_id', // Replace with the actual user ID
        'category_id': categories.firstWhere((cat) => cat['category_name'] == selectedItem)['category_id'],
        'amount': double.tryParse(amountController.text) ?? 0,
        'transaction_date': date.toIso8601String(),
        'description': explanationController.text,
        'category_type': selectedItemType // Type of the transaction (Income/Expense)
      }));
      setState(() {
        isLoading = false; // Stop the loading indicator
      });

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Show success Snackbar
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Transaction created successfully!'),
          backgroundColor: Colors.green, // Green for success
        ));
        // Navigator.of(context).pop(); // Optionally pop back to the previous screen
      } else {
        // Show failure Snackbar
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Failed to create transaction: ${response.body}'),
          backgroundColor: Colors.red, // Red for failure
        ));
      }
    } catch (e) {
      setState(() {
        isLoading = false; // Stop the loading indicator
      });

      // Show error Snackbar
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error: $e'),
        backgroundColor: Colors.red, // Red for failure
      ));
    }
  }

  GestureDetector saveButton() {
    return GestureDetector(
      onTap: () async {
        // Validate inputs before making the API call
        if (selectedItem == null || selectedItemType == null || amountController.text.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Please fill in all fields.'),
            backgroundColor: Colors.red,
          ));
          return;
        }
        await createTransaction(); // Call the createTransaction function
      },
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: Color(0xff368983),
        ),
        width: 120,
        height: 50,
        child: isLoading
            ? CircularProgressIndicator(color: Colors.white) // Show loading indicator if `isLoading` is true
            : Text(
                'Save',
                style: TextStyle(
                  fontFamily: 'f',
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  fontSize: 17,
                ),
              ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: SafeArea(
        child: Stack(
          alignment: AlignmentDirectional.center,
          children: [
            background_container(context),
            Positioned(
              top: 120,
              child: mainContainer(),
            ),
          ],
        ),
      ),
    );
  }

  Container mainContainer() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white,
      ),
      height: 550,
      width: 340,
      child: Column(
        children: [
          SizedBox(height: 30),
          nameDropdown(),
          SizedBox(height: 30),
          explanationField(),
          SizedBox(height: 30),
          amountField(),
          SizedBox(height: 30),
          typeDropdown(),
          SizedBox(height: 30),
          How(),
          SizedBox(height: 30),
          dateSelector(),
          Spacer(),
          saveButton(),
          SizedBox(height: 25),
        ],
      ),
    );
  }

  // GestureDetector saveButton() {
  //   return GestureDetector(
  //     onTap: () async {
  //       // Validate inputs before making the API call
  //       if (selectedItem == null || selectedItemType == null || amountController.text.isEmpty) {
  //         ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please fill in all fields.')));
  //         return;
  //       }
  //       await createTransaction(); // Call the createTransaction function
  //     },
  //     child: Container(
  //       alignment: Alignment.center,
  //       decoration: BoxDecoration(
  //         borderRadius: BorderRadius.circular(15),
  //         color: Color(0xff368983),
  //       ),
  //       width: 120,
  //       height: 50,
  //       child: Text(
  //         'Save',
  //         style: TextStyle(
  //           fontFamily: 'f',
  //           fontWeight: FontWeight.w600,
  //           color: Colors.white,
  //           fontSize: 17,
  //         ),
  //       ),
  //     ),
  //   );
  // }

  Padding How() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 15),
        width: 300,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            width: 2,
            color: Color(0xffC5C5C5),
          ),
        ),
        child: DropdownButton<String>(
          value: selctedItemi,
          onChanged: ((value) {
            setState(() {
              selctedItemi = value!;
            });
          }),
          items: _itemei
              .map((e) => DropdownMenuItem(
                    child: Container(
                      alignment: Alignment.center,
                      child: Row(
                        children: [
                          Text(
                            e,
                            style: TextStyle(fontSize: 18),
                          )
                        ],
                      ),
                    ),
                    value: e,
                  ))
              .toList(),
          selectedItemBuilder: (BuildContext context) => _itemei
              .map((e) => Row(
                    children: [Text(e)],
                  ))
              .toList(),
          hint: Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Text(
              'Mode',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          dropdownColor: Colors.white,
          isExpanded: true,
          underline: Container(),
        ),
      ),
    );
  }

  Widget dateSelector() {
    return Container(
      alignment: Alignment.bottomLeft,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10), border: Border.all(width: 2, color: Color(0xffC5C5C5))),
      width: 300,
      child: TextButton(
        onPressed: () async {
          DateTime? newDate = await showDatePicker(
            context: context,
            initialDate: date,
            firstDate: DateTime(2020),
            lastDate: DateTime(2100),
          );
          if (newDate == null) return; // Check for null
          setState(() {
            date = newDate;
          });
        },
        child: Text(
          'Date: ${date.year} / ${date.day} / ${date.month}',
          style: TextStyle(fontSize: 15, color: Colors.black),
        ),
      ),
    );
  }

  Padding typeDropdown() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 15),
        width: 300,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(width: 2, color: Color(0xffC5C5C5)),
        ),
        child: DropdownButton<String>(
          value: selectedItemType,
          onChanged: (value) {
            setState(() {
              selectedItemType = value;
            });
          },
          items: selectedItem != null
              ? (categories.firstWhere((cat) => cat['category_name'] == selectedItem)['types'] as List<dynamic>)
                  .map<String>((type) => type as String) // Cast each item to String
                  .map((type) => DropdownMenuItem<String>(
                        child: Text(type, style: TextStyle(fontSize: 18)),
                        value: type,
                      ))
                  .toList()
              : [], // Return empty if no category is selected
          hint: Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Text(
              'Type',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          isExpanded: true,
          underline: Container(),
        ),
      ),
    );
  }

  Padding amountField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: TextField(
        keyboardType: TextInputType.number,
        controller: amountController,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
          labelText: 'Amount',
          labelStyle: TextStyle(fontSize: 17, color: Colors.grey.shade500),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10), borderSide: BorderSide(width: 2, color: Color(0xffC5C5C5))),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10), borderSide: BorderSide(width: 2, color: Color(0xff368983))),
        ),
      ),
    );
  }

  Padding explanationField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: TextField(
        controller: explanationController,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
          labelText: 'Explanation',
          labelStyle: TextStyle(fontSize: 17, color: Colors.grey.shade500),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10), borderSide: BorderSide(width: 2, color: Color(0xffC5C5C5))),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10), borderSide: BorderSide(width: 2, color: Color(0xff368983))),
        ),
      ),
    );
  }

  Padding nameDropdown() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 15),
        width: 300,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(width: 2, color: Color(0xffC5C5C5)),
        ),
        child: DropdownButton<String>(
          value: selectedItem,
          onChanged: (value) {
            setState(() {
              selectedItem = value;
              selectedItemType = null; // Reset selected type when category changes
            });
          },
          items: categories
              .map<DropdownMenuItem<String>>((category) => DropdownMenuItem<String>(
                    child: Text(category['category_name'], style: TextStyle(fontSize: 18)),
                    value: category['category_name'] as String, // Ensure the value is a String
                  ))
              .toList(),
          hint: Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Text(
              'Name',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          isExpanded: true,
          underline: Container(),
        ),
      ),
    );
  }

  Column background_container(BuildContext context) {
    return Column(
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
          child: Column(
            children: [
              SizedBox(height: 40),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                      child: Icon(Icons.arrow_back, color: Colors.white),
                    ),
                    Text(
                      'Add Expenses',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.white),
                    ),
                    Icon(
                      Icons.attach_file_outlined,
                      color: Colors.white,
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ],
    );
  }
}
