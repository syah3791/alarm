class ResponHistory{
  int? id;
  DateTime? dateStart;
  DateTime? dateRespon;
  int? diff;

  ResponHistory({this.id, this.dateStart, this.dateRespon, this.diff});

  factory ResponHistory.fromJson(Map<String, dynamic> json) => new ResponHistory(
    id: json["id"],
    dateStart: DateTime.parse(json["dateStart"]),
    dateRespon: DateTime.parse(json["dateRespon"]),
    diff: json["diff"],
  );
  Map<String, dynamic> toMap() => {
    "id": id,
    "dateStart": dateStart.toString(),
    "dateRespon": dateRespon.toString(),
    "diff": diff,
  };
}