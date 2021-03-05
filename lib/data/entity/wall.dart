import 'package:climbing_alien/data/entity/base_object.dart';
import 'package:floor/floor.dart';

@Entity(tableName: 'walls')
class Wall extends BaseObject {
  String title;

  String description;

  int height;

  @ColumnInfo(name: 'image_path')
  String imagePath;

  Wall(this.title, {this.description, this.height, this.imagePath, int id, DateTime modifiedAt, DateTime createdAt})
      : super(id, modifiedAt, createdAt);

  @override
  String toString() {
    return 'Wall{title: $title, description: $description, height: $height, imagePath: $imagePath}';
  }
}
