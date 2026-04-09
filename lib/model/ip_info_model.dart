class IpInfoModel {
  String? status;
  String? message;
  String? continent;
  String? continentCode;
  String? country;
  String? countryCode;
  String? region;
  String? regionName;
  String? city;
  String? district;
  String? zip;
  double? lat;
  double? lon;
  String? timezone;
  int? offset;
  String? currency;
  String? isp;
  String? org;
  String? as;
  String? asname;
  String? reverse;
  bool? mobile;
  bool? proxy;
  bool? hosting;
  String? query;
  String? publicIp4;
  String? publicIp6;

  IpInfoModel({
    this.status,
    this.message,
    this.continent,
    this.continentCode,
    this.country,
    this.countryCode,
    this.region,
    this.regionName,
    this.city,
    this.district,
    this.zip,
    this.lat,
    this.lon,
    this.timezone,
    this.offset,
    this.currency,
    this.isp,
    this.org,
    this.as,
    this.asname,
    this.reverse,
    this.mobile,
    this.proxy,
    this.hosting,
    this.query,
    this.publicIp4,
    this.publicIp6,
  });

  factory IpInfoModel.fromJson(Map<String, dynamic> json) {
    return IpInfoModel(
      status: json['status'],
      message: json['message'],
      continent: json['continent'],
      continentCode: json['continentCode'],
      country: json['country'],
      countryCode: json['countryCode'],
      region: json['region'],
      regionName: json['regionName'],
      city: json['city'],
      district: json['district'],
      zip: json['zip'],
      lat: (json['lat'] as num?)?.toDouble(),
      lon: (json['lon'] as num?)?.toDouble(),
      timezone: json['timezone'],
      offset: json['offset'],
      currency: json['currency'],
      isp: json['isp'],
      org: json['org'],
      as: json['as'],
      asname: json['asname'],
      reverse: json['reverse'],
      mobile: json['mobile'],
      proxy: json['proxy'],
      hosting: json['hosting'],
      query: json['query'],
      publicIp4: json['publicIp4'],
      publicIp6: json['publicIp6'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['message'] = message;
    data['continent'] = continent;
    data['continentCode'] = continentCode;
    data['country'] = country;
    data['countryCode'] = countryCode;
    data['region'] = region;
    data['regionName'] = regionName;
    data['city'] = city;
    data['district'] = district;
    data['zip'] = zip;
    data['lat'] = lat;
    data['lon'] = lon;
    data['timezone'] = timezone;
    data['offset'] = offset;
    data['currency'] = currency;
    data['isp'] = isp;
    data['org'] = org;
    data['as'] = as;
    data['asname'] = asname;
    data['reverse'] = reverse;
    data['mobile'] = mobile;
    data['proxy'] = proxy;
    data['hosting'] = hosting;
    data['query'] = query;
    data['publicIp4'] = publicIp4;
    data['publicIp6'] = publicIp6;
    return data;
  }

  IpInfoModel copyWith({
    String? status,
    String? message,
    String? continent,
    String? continentCode,
    String? country,
    String? countryCode,
    String? region,
    String? regionName,
    String? city,
    String? district,
    String? zip,
    double? lat,
    double? lon,
    String? timezone,
    int? offset,
    String? currency,
    String? isp,
    String? org,
    String? as,
    String? asname,
    String? reverse,
    bool? mobile,
    bool? proxy,
    bool? hosting,
    String? query,
    String? publicIp4,
    String? publicIp6,
  }) {
    return IpInfoModel(
      status: status ?? this.status,
      message: message ?? this.message,
      continent: continent ?? this.continent,
      continentCode: continentCode ?? this.continentCode,
      country: country ?? this.country,
      countryCode: countryCode ?? this.countryCode,
      region: region ?? this.region,
      regionName: regionName ?? this.regionName,
      city: city ?? this.city,
      district: district ?? this.district,
      zip: zip ?? this.zip,
      lat: lat ?? this.lat,
      lon: lon ?? this.lon,
      timezone: timezone ?? this.timezone,
      offset: offset ?? this.offset,
      currency: currency ?? this.currency,
      isp: isp ?? this.isp,
      org: org ?? this.org,
      as: as ?? this.as,
      asname: asname ?? this.asname,
      reverse: reverse ?? this.reverse,
      mobile: mobile ?? this.mobile,
      proxy: proxy ?? this.proxy,
      hosting: hosting ?? this.hosting,
      query: query ?? this.query,
      publicIp4: publicIp4 ?? this.publicIp4,
      publicIp6: publicIp6 ?? this.publicIp6,
    );
  }

  @override
  String toString() {
    return 'IpInfoModel(status: $status, message: $message, continent: $continent, continentCode: $continentCode, country: $country, countryCode: $countryCode, region: $region, regionName: $regionName, city: $city, district: $district, zip: $zip, lat: $lat, lon: $lon, timezone: $timezone, offset: $offset, currency: $currency, isp: $isp, org: $org, as: $as, asname: $asname, reverse: $reverse, mobile: $mobile, proxy: $proxy, hosting: $hosting, query: $query, publicIp4: $publicIp4, publicIp6: $publicIp6)';
  }
}
