extends Resource
class_name EnemyResource

@export var id: int
@export var name: String
@export_multiline var description: String
@export var image: Texture2D
@export var health: int
@export var max_health: int
@export var block: int = 0
@export var moves: Array[EnemyMove] = []

@export var damage_per_turn: int = 0
@export var block_per_turn: int = 0
@export var purple_damage_multiplier: float = 1.0
@export var red_damage_multiplier: float = 1.0
@export var color_slots_min: int = 0
@export var color_slots_max: int = 0


func get_move(index: int) -> EnemyMove:
	if index < 0 or index >= moves.size():
		return null
	return moves[index]


func roll_move() -> EnemyMove:
	if moves.is_empty():
		return null

	var total_weight: float = 0.0
	for move: EnemyMove in moves:
		total_weight += maxf(move.weight, 0.0)

	if total_weight <= 0.0:
		return moves[0]

	var roll: float = randf() * total_weight
	var accumulator: float = 0.0
	for move: EnemyMove in moves:
		accumulator += maxf(move.weight, 0.0)
		if roll <= accumulator:
			return move
	return moves[moves.size() - 1]


func get_turn_damage_bonus(turn: int) -> int:
	return damage_per_turn * maxi(turn - 1, 0)


func get_turn_block_bonus(turn: int) -> int:
	return block_per_turn * maxi(turn - 1, 0)


func has_scaling_passive() -> bool:
	return damage_per_turn > 0 or block_per_turn > 0


func has_purple_vulnerability() -> bool:
	return not is_equal_approx(purple_damage_multiplier, 1.0)


func has_red_vulnerability() -> bool:
	return not is_equal_approx(red_damage_multiplier, 1.0)


func has_slot_color_passive() -> bool:
	return color_slots_max > 0


func roll_colored_slot_count() -> int:
	if not has_slot_color_passive():
		return 0
	var min_slots: int = mini(color_slots_min, color_slots_max)
	var max_slots: int = maxi(color_slots_min, color_slots_max)
	return randi_range(min_slots, max_slots)
