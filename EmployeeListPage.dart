
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:interview_test/screens/add_page.dart';
import 'package:http/http.dart' as http;
import 'package:interview_test/services/Employee_service.dart';
import 'package:interview_test/util/snackbar_helper.dart';
import 'package:interview_test/widget/Employee_card.dart';

class EmployeeListPage extends StatefulWidget {
  const EmployeeListPage({Key? key}) : super(key: key);

  @override
  State<EmployeeListPage> createState() => _EmployeeListPageState();
}

class _EmployeeListPageState extends State<EmployeeListPage> {
  List items = [];
  bool isLoading = true;
  late TextEditingController searchController;

  @override
  void initState() {
    super.initState();
    searchController = TextEditingController();
    items = [];
    fetchEmployee();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Employee List"),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(8),
            child: TextField(
              controller: searchController,
              onChanged: onSearchTextChanged,
              decoration: InputDecoration(
                hintText: 'Search...',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            child: Visibility(
              visible: isLoading,
              child: Center(child: CircularProgressIndicator()),
              replacement: RefreshIndicator(
                onRefresh: fetchEmployee,
                child: Visibility(
                  visible: items.isNotEmpty,
                  replacement: Center(
                    child: Text(
                      'No Employees ',
                      style: Theme.of(context).textTheme.headline3,
                    ),
                  ),
                  child: ListView.builder(
                    itemCount: items.length,
                    padding: EdgeInsets.all(12),
                    itemBuilder: (context, index) {
                      final item = items[index] as Map;
                      final id = item['_id'] as String;
                      return TodoCard(
                        index: index,
                        item: item,
                        deleteById: deleteById,
                        navigateEdit: navigateToEditPage,
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: navigateToAddPage,
        label: Text(
          "Add Employee",
          style: TextStyle(fontSize: 14),
        ),
      ),
    );
  }

  void onSearchTextChanged(String text) {
    final searchText = text.toLowerCase();

    if (searchText.isNotEmpty) {
      setState(() {
        items = items.where((item) {
          final empNo = item['empNo'].toString().toLowerCase();
          final empName = item['empName'].toString().toLowerCase();

          bool containsAllLetters = true;
          for (int i = 0; i < searchText.length; i++) {
            final letter = searchText[i];
            if (!title.contains(letter) && !description.contains(letter)) {
              containsAllLetters = false;
              break;
            }
          }

          return containsAllLetters;
        }).toList();
      });
    } else {
      setState(() {
        items = List.from(items);
      });
      fetchEmployee();
    }
  }

  Future<void> navigateToEditPage(Map item) async {
    final route = MaterialPageRoute(
      builder: (context) => AddEmployeePage(Employee: item),
    );
    await Navigator.push(context, route);
    setState(() {
      isLoading = true;
    });
    fetchEmployee();
  }

  Future<void> navigateToAddPage() async {
    final route = MaterialPageRoute(
      builder: (context) => AddEmployeePage(),
    );
    await Navigator.push(context, route);
    setState(() {
      isLoading = true;
    });
  }

  Future<void> deleteById(String id) async {
    final isSuccess = await EmployeeService.deleteById(id);
    if (isSuccess) {
      //remove item from the list
      final filtered = items.where((element) => element['_id'] != id).toList();
      setState(() {
        items = filtered;
      });
    } else {
      //Show error
      showErrorMessage(context, message: 'Delete Failed');
    }
  }

  Future<void> fetchEmployee() async {
    final response = await EmployeeService.fetchEmployees();

    if (response != null) {
      setState(() {
        items = response;
      });
    } else {
      showErrorMessage(context, message: 'Something went wrong');
    }

    setState(() {
      isLoading = false;
    });
  }
}
