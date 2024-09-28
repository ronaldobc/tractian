class Companie {
  String id;
  String name;

  Companie(this.id, this.name);

  Companie.fromJson(Map<String, dynamic> json)
      : name = json['name'] as String,
        id = json['id'] as String;

  Map<String, dynamic> toJson() => {
        'name': name,
        'id': id,
      };
}
