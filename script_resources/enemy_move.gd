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


func execute(context: BattleContext, enemy_data: EnemyResource = null) -> void:
	if context == null or context.enemy == null or context.player == null:
		return
	if context.enemy.health <= 0:
		return

	var turn: int = context.current_turn
	var damage_bonus: int = enemy_data.get_turn_damage_bonus(turn) if enemy_data else 0
	var block_bonus: int = enemy_data.get_turn_block_bonus(turn) if enemy_data else 0

	if gains_block():
		context.enemy.gain_block(block + block_bonus)

	if deals_damage():
		var hit_damage: int = damage + damage_bonus
		for _i in hit_count:
			if context.player.health <= 0:
				break
			CombatCalculation.apply_damage(context.enemy, context.player, hit_damage, false)

	for _i in apply_weakness:
		context.player.apply_status("weakness")
	for _i in apply_vulnerable:
		context.player.apply_status("vulnerable")
