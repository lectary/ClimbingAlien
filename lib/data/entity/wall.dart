import 'package:climbing_alien/data/entity/base_object.dart';
import 'package:floor/floor.dart';

@Entity(tableName: 'walls')
class Wall extends BaseObject {
  String title;

  String? description;

  int? height;

  String? location;

  String? file;

  @ignore
  String? fileUpdated;

  Wall(
      {required this.title,
      this.description,
      this.height,
      this.location,
      this.file,
      this.fileUpdated,
      int? id,
      DateTime? modifiedAt,
      DateTime? createdAt})
      : super(id, modifiedAt, createdAt);

  Map<String, dynamic> toMap() {
    return {
      "title": title,
      "description": description,
      "height": height,
      "location": location,
      "file": file,
      "id": id,
      "modified_at": modifiedAt?.millisecondsSinceEpoch,
      "created_at": createdAt.millisecondsSinceEpoch,
    };
  }

  factory Wall.fromJson(Map<String, dynamic> json) {
    return Wall(
      title: json['wall'],
      location: json['location'],
      file: json['file'],
    );
  }

  @override
  String toString() {
    return 'Wall{title: $title, description: $description, height: $height, location: $location, file: $file, fileUpdated: $fileUpdated}';
  }
}
