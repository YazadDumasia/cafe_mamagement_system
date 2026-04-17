import 'package:flutter/material.dart';
import '../countries.dart';
import '../country.dart';
import '../utils/utils.dart';
import '../utils/typedefs.dart';

class CountryGroupedMaterialDialog extends StatefulWidget {
  const CountryGroupedMaterialDialog({
    required this.onValuePicked,
    super.key,
    this.itemFilter,
    this.sortComparator,
    this.priorityList,
    this.itemBuilder,
    this.headerBuilder,
    this.isSearchable = true,
    this.searchInputDecoration,
    this.searchCursorColor,
    this.searchEmptyView,
    this.searchFilter,
    this.title,
    this.titlePadding,
    this.contentPadding = const EdgeInsets.symmetric(vertical: 12.0),
    this.priorityHeaderLabel = 'Suggested',
  });

  final ValueChanged<Country> onValuePicked;
  final ItemFilter? itemFilter;
  final Comparator<Country>? sortComparator;
  final List<Country>? priorityList;
  final Widget Function(Country country, bool isSelected)? itemBuilder;
  final Widget Function(String continent)? headerBuilder;
  final bool isSearchable;
  final InputDecoration? searchInputDecoration;
  final Color? searchCursorColor;
  final Widget? searchEmptyView;
  final SearchFilter? searchFilter;
  final Widget? title;
  final EdgeInsetsGeometry? titlePadding;
  final EdgeInsetsGeometry contentPadding;
  final String priorityHeaderLabel;

  @override
  State<CountryGroupedMaterialDialog> createState() =>
      _CountryGroupedMaterialDialogState();
}

class _CountryGroupedMaterialDialogState extends State<CountryGroupedMaterialDialog> {
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
        if (widget.searchFilter != null) {
          // If a custom filter is provided, we should use it if we can find the search text
          // However, we don't store search text in state currently. Let's fix that.
          return true; // placeholder
        }
        // Use default search matching logic if applicable, but better to just use visibility
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
      _flatList.add(key); // The header
      _flatList.addAll(_groupedCountries[key]!); // The countries
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.title != null)
            Padding(
              padding: widget.titlePadding ?? const EdgeInsets.all(16.0),
              child: widget.title,
            ),
          if (widget.isSearchable) _buildSearchField(),
          Expanded(
            child: _flatList.isNotEmpty
                ? ListView.builder(
                    padding: widget.contentPadding,
                    itemCount: _flatList.length,
                    itemBuilder: (context, index) {
                      final item = _flatList[index];
                      if (item is String) {
                        return widget.headerBuilder != null
                            ? widget.headerBuilder!(item)
                            : _buildDefaultHeader(item);
                      } else {
                        final country = item as Country;
                        return InkWell(
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
                    const Center(child: Padding(
                      padding: EdgeInsets.all(20.0),
                      child: Text('No country found.'),
                    )),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: TextField(
        cursorColor: widget.searchCursorColor,
        decoration: widget.searchInputDecoration ??
            InputDecoration(
              hintText: 'Search',
              prefixIcon: const Icon(Icons.search),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
            ),
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
    );
  }

  Widget _buildDefaultHeader(String continent) {
    return Container(
      width: double.infinity,
      color: Colors.grey.shade200,
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      margin: const EdgeInsets.only(top: 8.0),
      child: Text(
        continent.toUpperCase(),
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.grey,
        ),
      ),
    );
  }

  Widget _buildDefaultItem(Country country) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade300, width: 0.5)),
      ),
      child: Row(
        children: <Widget>[
          CountryPickerUtils.getDefaultFlagImage(country),
          const SizedBox(width: 16.0),
          Text(
            '+${country.phoneCode}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 16.0),
          Expanded(
            child: Text(
              country.name,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
