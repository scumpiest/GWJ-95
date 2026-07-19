class_name CombatCalculation
extends RefCounted


static func apply_damage(
		attacker: Unit,
		defender: Unit,
		base_damage: int,
		pierce_block: bool,
) -> int:
	if defender.health <= 0:
		return 0

	var damage = base_damage + attacker.statuses["strength"]
	if attacker.statuses["weakness"] > 0:
		damage = int(floor(damage * 0.75))
	if defender.statuses["vulnerable"] > 0:
		damage = int(floor(damage * 1.5))
	if damage <= 0:
		return 0

	if defender.block > 0 and not pierce_block:
		var absorbed_damage = mini(defender.block, damage)
		defender.lose_block(absorbed_damage)
		damage -= absorbed_damage
		if absorbed_damage > 0 and _is_player(defender):
			AudioManager.play_player_shield_block()
			if defender.block <= 0:
				AudioManager.play_player_shield_break()

	if damage > 0:
		defender.take_damage(damage)

	return damage


static func _is_player(unit: Unit) -> bool:
	return GameManager.context != null and unit == GameManager.context.player
