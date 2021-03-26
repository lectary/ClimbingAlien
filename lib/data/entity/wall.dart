import 'package:climbing_alien/data/entity/base_object.dart';
import 'package:floor/floor.dart';

@Entity(tableName: 'walls')
class Wall extends BaseObject {
  String title;

  String? description;

  int? height;

  @ColumnInfo(name: 'image_path')
  String? imagePath;

  @ignore
  String? imagePathUpdated;

  Wall(this.title, {this.description, this.height, this.imagePath, this.imagePathUpdated, int? id, DateTime? modifiedAt, DateTime? createdAt})
      : super(id, modifiedAt, createdAt);

  Map<String, dynamic> toMap() {
    return {
      "title": title,
      "description": description,
      "height": height,
      "image_path": imagePath,
      "id": id,
      "modified_at": modifiedAt?.millisecondsSinceEpoch,
      "created_at": createdAt.millisecondsSinceEpoch,
    };
  }

  @override
  String toString() {
    return 'Wall{title: $title, description: $description, height: $height, imagePath: $imagePath}';
  }
}
