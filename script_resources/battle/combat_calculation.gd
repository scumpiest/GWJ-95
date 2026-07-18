class_name CombatCalculation
extends RefCounted

static func apply_damage(
	attacker: Unit,
	defender: Unit,
	base_damage: int,
	pierce_block: bool
	) -> int:
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

		if damage > 0:
			defender.take_damage(damage)

		return damage
