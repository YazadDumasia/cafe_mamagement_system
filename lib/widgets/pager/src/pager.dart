/*
A pagination widget that uses ValueNotifier for reactive state management.

Example usage:
```dart
ValueNotifier<int> currentPageNotifier = ValueNotifier<int>(1);
ValueNotifier<int> currentItemsPerPageNotifier = ValueNotifier<int>(10);

///currentItemsPerPageNotifier.value = value;
/// onChanged(value);
Pager(
  totalPages: 10,
  onPageChanged: (page) {
    print('Page changed to $page');
  },
  onItemsPerPageChanged: (items) {
    print('Items per page changed to $items');
  },
  itemsPerPageList: [5, 10, 20],
  currentPageNotifier: currentPageNotifier,
  currentItemsPerPageNotifierParam: currentItemsPerPageNotifier,
  showItemsPerPage: true,
)
```
*/
import 'package:flutter/material.dart';

class Pager extends StatelessWidget {
  Pager({
    required this.totalPages,
    required this.onPageChanged,
    required this.onItemsPerPageChanged,
    required List<int>? itemsPerPageListParam,
    required this.currentPageNotifier,
    ValueNotifier<int>? currentItemsPerPageNotifierParam,
    super.key,
    this.showItemsPerPage = false,
    this.pagesView = 3,
    this.numberButtonSelectedColor = Colors.blue,
    this.numberTextSelectedColor = Colors.white,
    this.numberTextUnselectedColor = Colors.black,
    this.pageChangeIconColor = Colors.grey,
    this.itemsPerPageText,
    this.itemsPerPageTextStyle,
    this.dropDownMenuItemTextStyle,
    this.itemsPerPageAlignment = Alignment.center,
  }) : currentItemsPerPageNotifier = currentItemsPerPageNotifierParam,
       itemsPerPageList = itemsPerPageListParam ?? <int>[] {
    assert(
      totalPages > 0 && pagesView > 0,
      'Fatal Error: Make sure the totalPages and pagesView fields are greater than zero.',
    );
    if (showItemsPerPage) {
      assert(
        currentItemsPerPageNotifierParam != null &&
            itemsPerPageListParam != null &&
            itemsPerPageListParam.isNotEmpty,
        'Fatal error: OnItemsPerPageChanged must be implemented or itemsPerPageList is null or empty.',
      );
    }
  }

  final int totalPages;
  final Function(int) onPageChanged;
  final bool showItemsPerPage;
  final List<int> itemsPerPageList;
  final Function(int?) onItemsPerPageChanged;
  final ValueNotifier<int> currentPageNotifier;
  final ValueNotifier<int>? currentItemsPerPageNotifier;
  final int pagesView;
  final Color numberButtonSelectedColor;
  final Color numberTextUnselectedColor;
  final Color numberTextSelectedColor;
  final Color pageChangeIconColor;
  final String? itemsPerPageText;
  final TextStyle? itemsPerPageTextStyle;
  final TextStyle? dropDownMenuItemTextStyle;
  final Alignment itemsPerPageAlignment;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: currentPageNotifier,
      builder: (context, currentPage, child) {
        int effectivePagesView = totalPages < pagesView
            ? totalPages
            : pagesView;
        int getPageEnd(int currentPage) =>
            currentPage + effectivePagesView > totalPages
            ? totalPages + 1
            : currentPage + effectivePagesView;
        int getPageStart(int pageEnd, int currentPage) =>
            pageEnd == totalPages + 1
            ? pageEnd - effectivePagesView
            : currentPage;
        int pageEnd = getPageEnd(currentPage);
        int pageStart = getPageStart(pageEnd, currentPage);
        return SizedBox(
          width: MediaQuery.of(context).size.width,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              SizedBox(
                width: MediaQuery.of(context).size.width,
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    IconButton(
                      tooltip: 'First Page',
                      onPressed: currentPage > 1
                          ? () {
                              currentPageNotifier.value = 1;
                              onPageChanged(1);
                            }
                          : null,
                      splashRadius: 25,
                      icon: Icon(Icons.first_page, color: pageChangeIconColor),
                    ),
                    IconButton(
                      tooltip: 'Previous',
                      onPressed: currentPage > 1
                          ? () {
                              int newPage = currentPage - 1;
                              currentPageNotifier.value = newPage;
                              onPageChanged(newPage);
                            }
                          : null,
                      splashRadius: 25,
                      icon: Icon(
                        Icons.chevron_left,
                        color: pageChangeIconColor,
                      ),
                    ),
                    Flexible(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          for (int i = pageStart; i < pageEnd; i++)
                            TextButton(
                              onPressed: () {
                                currentPageNotifier.value = i;
                                onPageChanged(i);
                              },
                              style: ElevatedButton.styleFrom(
                                shape: const CircleBorder(),
                                backgroundColor: currentPage == i
                                    ? numberButtonSelectedColor
                                    : null,
                              ),
                              child: Text(
                                '$i',
                                style: TextStyle(
                                  color: currentPage == i
                                      ? numberTextSelectedColor
                                      : numberTextUnselectedColor,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip: 'Next Page',
                      onPressed: currentPage < totalPages
                          ? () {
                              int newPage = currentPage + 1;
                              currentPageNotifier.value = newPage;
                              onPageChanged(newPage);
                            }
                          : null,
                      splashRadius: 25,
                      icon: Icon(
                        Icons.chevron_right,
                        color: pageChangeIconColor,
                      ),
                    ),
                    IconButton(
                      tooltip: 'Last Page',
                      onPressed: currentPage < totalPages
                          ? () {
                              currentPageNotifier.value = totalPages;
                              onPageChanged(totalPages);
                            }
                          : null,
                      splashRadius: 25,
                      icon: Icon(Icons.last_page, color: pageChangeIconColor),
                    ),
                  ],
                ),
              ),
              if (showItemsPerPage)
                Align(
                  alignment: itemsPerPageAlignment,
                  child: Padding(
                    padding: const EdgeInsets.only(
                      left: 10,
                      right: 10,
                      bottom: 10,
                    ),
                    child: ItemsPerPage(
                      currentItemsPerPageNotifier: currentItemsPerPageNotifier!,
                      itemsPerPage: itemsPerPageList,
                      onChanged: onItemsPerPageChanged,
                      itemsPerPageText: itemsPerPageText,
                      itemsPerPageTextStyle: itemsPerPageTextStyle,
                      dropDownMenuItemTextStyle: dropDownMenuItemTextStyle,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

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
  final List<int>? itemsPerPage;
  final void Function(int?) onChanged;
  final String? itemsPerPageText;
  final TextStyle? itemsPerPageTextStyle;
  final TextStyle? dropDownMenuItemTextStyle;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: currentItemsPerPageNotifier,
      builder: (context, currentItemsPerPage, child) {
        return DropdownButton<int>(
          value: currentItemsPerPage,
          onChanged: onChanged,
          items: itemsPerPage?.map((int value) {
            return DropdownMenuItem<int>(
              value: value,
              child: Text(
                itemsPerPageText != null
                    ? '$itemsPerPageText $value'
                    : '$value',
                style: dropDownMenuItemTextStyle,
              ),
            );
          }).toList(),
          style: itemsPerPageTextStyle,
        );
      },
    );
  }
}
