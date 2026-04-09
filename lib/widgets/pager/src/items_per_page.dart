import 'package:flutter/material.dart';

class ItemsPerPage extends StatelessWidget {
  const ItemsPerPage({
    required this.currentItemsPerPageNotifier,
    required this.itemsPerPage,
    required this.onChanged,
    super.key,
    this.itemsPerPageText,
    this.itemsPerPageTextStyle,
    this.dropDownMenuItemTextStyle,
  });

  final ValueNotifier<int> currentItemsPerPageNotifier;
  final List<int> itemsPerPage;
  final Function(int) onChanged;
  final String? itemsPerPageText;
  final TextStyle? itemsPerPageTextStyle;
  final TextStyle? dropDownMenuItemTextStyle;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: currentItemsPerPageNotifier,
      builder: (context, currentItemsPerPage, child) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              itemsPerPageText ?? 'Items per page: ',
              style:
                  itemsPerPageTextStyle ??
                  const TextStyle(color: Colors.grey),
            ),
            const SizedBox(width: 16),
            DropdownButton<int>(
              value: currentItemsPerPage,
              focusColor: Colors.transparent,
              items: itemsPerPage.map((value) {
                return DropdownMenuItem<int>(
                  value: value,
                  child: Text(
                    value.toString(),
                    style:
                        dropDownMenuItemTextStyle ??
                        const TextStyle(fontSize: 14),
                  ),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  currentItemsPerPageNotifier.value = value;
                  onChanged(value);
                }
              },
            ),
          ],
        );
      },
    );
  }
}
