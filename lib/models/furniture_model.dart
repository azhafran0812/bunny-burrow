class FurnitureModel {
  final String id;
  final String name;
  int gridX;
  int gridY;
  final int width;
  final int height;
  final int passiveYield;

  FurnitureModel({
    required this.id,
    required this.name,
    required this.gridX,
    required this.gridY,
    required this.width,
    required this.height,
    required this.passiveYield,
  });

  // Convert to Map for clean Hive storage without complex TypeAdapters
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'gridX': gridX,
      'gridY': gridY,
      'width': width,
      'height': height,
      'passiveYield': passiveYield,
    };
  }

  factory FurnitureModel.fromMap(Map<dynamic, dynamic> map) {
    return FurnitureModel(
      id: map['id'] as String,
      name: map['name'] as String,
      gridX: map['gridX'] as int,
      gridY: map['gridY'] as int,
      width: map['width'] as int,
      height: map['height'] as int,
      passiveYield: map['passiveYield'] as int,
    );
  }
}
