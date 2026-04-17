import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Colors; // For some subtle colors
import '../countries.dart';
import '../country.dart';
import '../utils/utils.dart';
import '../utils/typedefs.dart';

class CountryGroupedCupertinoDialog extends StatefulWidget {
  const CountryGroupedCupertinoDialog({
    required this.onValuePicked,
    super.key,
    this.itemFilter,
    this.sortComparator,
    this.priorityList,
    this.itemBuilder,
    this.headerBuilder,
    this.isSearchable = true,
    this.searchPlaceholder = 'Search',
    this.searchEmptyView,
    this.searchFilter,
    this.title,
    this.backgroundColor,
    this.priorityHeaderLabel = 'Suggested',
  });

  final ValueChanged<Country> onValuePicked;
  final ItemFilter? itemFilter;
  final Comparator<Country>? sortComparator;
  final List<Country>? priorityList;
  final Widget Function(Country country, bool isSelected)? itemBuilder;
  final Widget Function(String continent)? headerBuilder;
  final bool isSearchable;
  final String searchPlaceholder;
  final Widget? searchEmptyView;
  final SearchFilter? searchFilter;
  final Widget? title;
  final Color? backgroundColor;
  final String priorityHeaderLabel;

  @override
  State<CountryGroupedCupertinoDialog> createState() =>
      _CountryGroupedCupertinoDialogState();
}

class _CountryGroupedCupertinoDialogState extends State<CountryGroupedCupertinoDialog> {
  late List<Country> _allCountries;
  late List<Country> _filteredCountries;
  Map<String, List<Country>> _groupedCountries = {};
  List<dynamic> _flatList = [];

  @override
  void initState() {
    super.initState();
    _allCountries = countryList.where(widget.itemFilter ?? acceptAllCountries).toList();

    if (widget.sortComparator != null) {
      _allCountries.sort(widget.sortComparator);
    }

    if (widget.priorityList != null) {
      for (Country country in widget.priorityList!) {
        _allCountries.removeWhere((Country c) => country.isoCode == c.isoCode);
      }
      _allCountries.insertAll(0, widget.priorityList!);
    }

    _filteredCountries = _allCountries;
    _updateLists();
  }

  void _updateLists() {
    _flatList = [];
    
    // 1. Identify priority matches
    List<Country> priorityMatches = [];
    if (widget.priorityList != null && widget.priorityList!.isNotEmpty) {
      priorityMatches = widget.priorityList!.where((country) {
        return _filteredCountries.any((c) => c.isoCode == country.isoCode);
      }).toList();
    }

    if (priorityMatches.isNotEmpty) {
      _flatList.add(widget.priorityHeaderLabel);
      _flatList.addAll(priorityMatches);
    }

    // 2. Group the rest of the countries, excluding those already in priority
    final nonPriorityCountries = _filteredCountries.where((c) {
      return !priorityMatches.any((p) => p.isoCode == c.isoCode);
    }).toList();

    _groupedCountries = CountryPickerUtils.groupCountries(nonPriorityCountries);
    
    final keys = _groupedCountries.keys.toList()..sort();
    for (var key in keys) {
      _flatList.add(key); // Header
      _flatList.addAll(_groupedCountries[key]!); // Countries
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: widget.backgroundColor ?? CupertinoColors.systemBackground,
      navigationBar: CupertinoNavigationBar(
        middle: widget.title ?? const Text('Select Country'),
        previousPageTitle: 'Back',
      ),
      child: SafeArea(
        child: Column(
          children: [
            if (widget.isSearchable)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: CupertinoSearchTextField(
                  placeholder: widget.searchPlaceholder,
                  onChanged: (String value) {
                    setState(() {
                      _filteredCountries = _allCountries
                          .where(
                            (Country country) => widget.searchFilter == null
                                ? country.name.toLowerCase().contains(value.toLowerCase()) ||
                                    country.phoneCode.startsWith(value.toLowerCase()) ||
                                    country.isoCode.toLowerCase().startsWith(value.toLowerCase())
                                : widget.searchFilter!(country, value),
                          )
                          .toList();
                      _updateLists();
                    });
                  },
                ),
              ),
            Expanded(
              child: _flatList.isNotEmpty
                  ? ListView.builder(
                      itemCount: _flatList.length,
                      itemBuilder: (context, index) {
                        final item = _flatList[index];
                        if (item is String) {
                          return widget.headerBuilder != null
                              ? widget.headerBuilder!(item)
                              : _buildDefaultHeader(item);
                        } else {
                          final country = item as Country;
                          return GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () {
                              widget.onValuePicked(country);
                              Navigator.pop(context);
                            },
                            child: widget.itemBuilder != null
                                ? widget.itemBuilder!(country, false)
                                : _buildDefaultItem(country),
                          );
                        }
                      },
                    )
                  : widget.searchEmptyView ??
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(20.0),
                          child: Text('No country found.'),
                        ),
                      ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDefaultHeader(String continent) {
    return Container(
      width: double.infinity,
      color: CupertinoColors.systemGroupedBackground,
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Text(
        continent.toUpperCase(),
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: CupertinoColors.secondaryLabel,
          letterSpacing: -0.1,
        ),
      ),
    );
  }

  Widget _buildDefaultItem(Country country) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: CupertinoColors.separator,
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: <Widget>[
          CountryPickerUtils.getDefaultFlagImage(country),
          const SizedBox(width: 16.0),
          Text(
            '+${country.phoneCode}',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: CupertinoColors.label,
            ),
          ),
          const SizedBox(width: 16.0),
          Expanded(
            child: Text(
              country.name,
              style: const TextStyle(
                fontSize: 17,
                color: CupertinoColors.label,
              ),
            ),
          ),
          const Icon(
            CupertinoIcons.chevron_right,
            size: 16,
            color: CupertinoColors.placeholderText,
          ),
        ],
      ),
    );
  }
}
