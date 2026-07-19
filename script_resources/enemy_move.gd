class_name EnemyMove
extends Resource

@export var damage: int = 0
@export var hit_count: int = 1
@export var block: int = 0
@export var apply_weakness: int = 0
@export var apply_vulnerable: int = 0
@export var weight: float = 1.0


func deals_damage() -> bool:
	return damage > 0 and hit_count > 0


func gains_block() -> bool:
	return block > 0


func applies_status() -> bool:
	return apply_weakness > 0 or apply_vulnerable > 0
