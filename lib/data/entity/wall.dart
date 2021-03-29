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

  bool isCustom;

  Wall({required this.title,
    this.description,
    this.height,
    this.location,
    this.file,
    this.fileUpdated,
    this.isCustom = true,
    int? id,
    DateTime? modifiedAt,
    DateTime? createdAt}) : super(id, modifiedAt, createdAt);

  Map<String, dynamic> toMap() {
    return {
      "title": title,
      "description": description,
      "height": height,
      "location": location,
      "file": file,
      "isCustom": isCustom,
      "id": id,
      "modified_at": modifiedAt?.millisecondsSinceEpoch,
      "created_at": createdAt.millisecondsSinceEpoch,
    };
  }

  factory Wall.fromJson(Map<String, dynamic> json) {
    return Wall(
      title: _titleFromJson(json['wall']),
      location: json['location'],
      file: json['file'],
    )..isCustom = false;
  }

  static String _titleFromJson(String string) {
    if (string.contains('.jpg')) {
      return string.substring(0, string.lastIndexOf('.jpg'));
    }
    if (string.contains('.png')) {
      return string.substring(0, string.lastIndexOf('.png'));
    }
    return string;
  }

  @override
  String toString() {
    return 'Wall{title: $title, description: $description, height: $height, location: $location, file: $file, fileUpdated: $fileUpdated}';
  }
}
