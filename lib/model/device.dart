class Device {
  String? name;
  num? id;
  String? blueprintId;
  String? token;
  String? type;
  String? status;
  num? lastOnline;

  Device(
      {this.name,
      this.id,
      this.blueprintId,
      this.token,
      this.type,
      this.status,
      this.lastOnline});

  factory Device.fromJson(Map<String, dynamic> json) => Device(
        name: json["name"],
        id: json["id"],
        blueprintId: json["blueprint_id"],
        token: json["token"],
        type: json["type"],
        status: json["status"],
        lastOnline: json["lastOnline"],
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "id": id,
        "blueprint_id": blueprintId,
        "token": token,
        "type": type,
        "status": status,
        "lastOnline": lastOnline,
      };
}
