import 'package:tractian/models/asset.dart';

class Location {
  String id;
  String name;
  String? parentId;
  Iterable<Location> locations = const Iterable.empty();
  Iterable<Asset> assets = const Iterable.empty();
  bool expanded = false;

  Location(this.id, this.name, this.parentId);

  Location.fromJson(Map<String, dynamic> json)
      : name = json['name'] as String,
        id = json['id'] as String,
        parentId = json['parentId'] as String?;

  Map<String, dynamic> toJson() => {
        'name': name,
        'id': id,
        'parentId': parentId,
      };
}
