class Asset {
  String id;
  String? locationId;
  String name;
  String? parentId;
  String? sensorType;
  String? status;

  String? gatewayId;
  String? sensorId;

  bool expanded = false;

  Iterable<Asset> assets = const Iterable.empty();

  Asset(this.id, this.locationId, this.name, this.status,
      {this.parentId, this.sensorId, this.sensorType, this.gatewayId});

  Asset.fromJson(Map<String, dynamic> json)
      : name = json['name'] as String,
        id = json['id'] as String,
        locationId = json['locationId'] as String?,
        status = json['status'] as String?,
        parentId = json['parentId'] as String?,
        sensorType = json['sensorType'] as String?,
        gatewayId = json['gatewayId'] as String?,
        sensorId = json['sensorId'] as String?;

  Map<String, dynamic> toJson() => {
        'name': name,
        'id': id,
      };
}
