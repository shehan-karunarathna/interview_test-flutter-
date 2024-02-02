

import 'package:flutter/material.dart';

class Employee_edit_and_delete extends StatelessWidget {
  final int index;
  final Map item;
  final Function(Map) navigateEdit;
  final Function(String) deleteById;

  const Employee_edit_and_delete({
    super.key,
    required this.index,
    required this.item,
    required this.navigateEdit,
    required this.deleteById,
  });

  @override
  Widget build(BuildContext context) {
    final id = item['_id'] as String;
    return Employee(
      child: ListTile(
        leading: CircleAvatar(child: Text('${index + 1}')),
        title: Text(item['empNo']),
       
        trailing: PopupMenuButton(onSelected: (value) {
          if (value == 'edit') {
            //open edit page
            navigateEdit(item);
          } else if (value == 'delete') {
            //open delete and remove the item
            deleteById(id);
          }
        }, itemBuilder: (context) {
          return [
            PopupMenuItem(
              child: Text('Edit'),
              value: 'edit',
            ),
            PopupMenuItem(
              child: Text('Delete'),
              value: 'delete',
            ),
          ];
        }),
      ),
    );
  }
}
