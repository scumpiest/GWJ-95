extends Resource
class_name Level

enum LevelType { GAME, BOSS, SHOP }

@export var type: LevelType = LevelType.GAME
@export var enemy_scene: PackedScene
@export var enemy_data: EnemyResource
