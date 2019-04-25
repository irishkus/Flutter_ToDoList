import 'dart:convert';

Client clientFromJson(String str) {
  final jsonData = json.decode(str);
  return Client.fromMap(jsonData);
}

String clientToJson(Client data) {
  final dyn = data.toMap();
  return json.encode(dyn);
}

class Client {
  int id;
  String toDo;
  int done;

  Client({
    this.id,
    this.toDo,
    this.done,
  });

  factory Client.fromMap(Map<String, dynamic> json) => new Client(
    id: json["id"],
    toDo: json["toDo"],
    done: json["done"],
  );

  Map<String, dynamic> toMap() => {
    "id": id,
    "toDo": toDo,
    "done": done,
  };
}
