import 'package:floor/floor.dart';

class BaseObject {
  @PrimaryKey(autoGenerate: true)
  int id;

  @ColumnInfo(name: 'modified_at')
  DateTime modifiedAt;

  @ColumnInfo(name: 'created_at', nullable: false)
  DateTime createdAt;

  BaseObject(this.id, this.modifiedAt, DateTime createdAt) : this.createdAt = createdAt ?? DateTime.now();
}
