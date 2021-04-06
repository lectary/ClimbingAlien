import 'package:climbing_alien/data/entity/base_object.dart';
import 'package:floor/floor.dart';

enum WallStatus { notPersisted, downloading, persisted, removed, updateAvailable }

@Entity(tableName: 'walls')
class Wall extends BaseObject {
  String title;

  String? description;

  String? location;

  String? file;

  @ignore
  String? fileUpdated;

  String? thumbnail;

  /// Used for showing corresponding status information and providing further actions in the wall management list
  @ignore
  WallStatus status = WallStatus.notPersisted;

  /// Used as indicator that this wall is based on a local image
  bool isCustom;

  Wall(
      {required this.title,
      this.description,
      this.location,
      this.file,
      this.fileUpdated,
      this.thumbnail,
      this.isCustom = true,
      int? id,
      DateTime? modifiedAt,
      DateTime? createdAt})
      : super(id, modifiedAt, createdAt);

  Map<String, dynamic> toMap() {
    return {
      "title": title,
      "description": description,
      "location": location,
      "file": file,
      "thumbnail": thumbnail,
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
      thumbnail: json['thumbnail'],
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
    return 'Wall{title: $title, description: $description, location: $location, file: $file, thumbnail: $thumbnail, fileUpdated: $fileUpdated, wallStatus: $status, isCustom: $isCustom}';
  }
}
