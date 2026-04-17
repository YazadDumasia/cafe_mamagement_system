import '../countries.dart';
import '../country.dart';
import 'package:flutter/widgets.dart';

class CountryPickerUtils {
  static Country getSampleModel() {
    return Country(
      isoCode: 'AF',
      phoneCode: '93',
      name: 'Afghanistan',
      iso3Code: 'AFG',
      minLength: 9,
      maxLength: 9,
      currencySymbol: '؋',
      continent: 'Asia',
    );
  }

  static List<Country>? getALLList() {
    final List<Country> sortedList = countryList;
    sortedList.sort(
      (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
    );
    return sortedList;
  }

  static Country getCountryByIso3Code(String iso3Code) {
    try {
      return countryList.firstWhere(
        (country) => country.iso3Code.toLowerCase() == iso3Code.toLowerCase(),
      );
    } catch (error) {
      throw Exception(
        'The initialValue provided is not a supported iso 3 code!',
      );
    }
  }

  static Country getCountryByIsoCode(String isoCode) {
    try {
      return countryList.firstWhere(
        (country) => country.isoCode.toLowerCase() == isoCode.toLowerCase(),
      );
    } catch (error) {
      throw Exception('The initialValue provided is not a supported iso code!');
    }
  }

  static Country getCountryByName(String name) {
    try {
      return countryList.firstWhere(
        (country) => country.name.toLowerCase() == name.toLowerCase(),
      );
    } catch (error) {
      throw Exception('The initialValue provided is not a supported name!');
    }
  }

  static String getFlagImageAssetPath(String isoCode) {
    return 'assets/images/flags/flag_${isoCode.toLowerCase()}.png';
  }

  static Widget getDefaultFlagImage(Country country) {
    return Image.asset(
      CountryPickerUtils.getFlagImageAssetPath(country.isoCode),
      height: 20.0,
      width: 30.0,
      fit: BoxFit.fill,
    );
  }

  static Country getCountryByPhoneCode(String phoneCode) {
    try {
      return countryList.firstWhere(
        (country) => country.phoneCode.toLowerCase() == phoneCode.toLowerCase(),
      );
    } catch (error) {
      throw Exception(
        'The initialValue provided is not a supported phone code!',
      );
    }
  }

  static Country getCountryByCurrencySymbol(String currencySymbol) {
    try {
      return countryList.firstWhere(
        (country) => country.currencySymbol == currencySymbol,
      );
    } catch (error) {
      throw Exception(
        'The initialValue provided is not a supported phone code!',
      );
    }
  }

  static List<Country>? getAllCountriesByMinLength(int minLength) {
    try {
      return countryList
          .where((country) => country.minLength == minLength)
          .toList();
    } catch (error) {
      throw Exception(
        'The initialValue provided is not a supported phone code!',
      );
    }
  }

  static List<Country>? getAllCountriesByMaxLength(int maxLength) {
    try {
      return countryList
          .where((country) => country.maxLength == maxLength)
          .toList();
    } catch (error) {
      throw Exception(
        'The initialValue provided is not a supported phone code!',
      );
    }
  }

  static List<Country>? getAllCountriesBycontinent(String continent) {
    try {
      return countryList
          .where((final Country country) => country.continent == continent)
          .toList();
    } catch (error) {
      throw Exception(
        'The initialValue provided is not a supported phone code!',
      );
    }
  }

  static Map<String, List<Country>> groupCountries(List<Country> countryList) {
    final Map<String, List<Country>> countriesByContinent = {};
    for (var country in countryList) {
      final continent = country.continent ?? 'Unknown';
      countriesByContinent.putIfAbsent(continent, () => []);
      countriesByContinent[continent]!.add(country);
    }
    return countriesByContinent;
  }
}
