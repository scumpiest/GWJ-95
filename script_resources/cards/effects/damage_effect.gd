class_name DamageEffect
extends CardEffect

enum Target {
	ENEMY,
	BOTH,
}

@export var target: Target = Target.ENEMY
@export var pierce_block: bool = false


func resolve(
		context: BattleContext,
		slot: ChainSlotState,
		resolver: ChainEffectResolver,
) -> void:
	var damage: int = compute_value(context, slot)
	if damage <= 0:
		return

	var attacker: Unit = context.player
	var defender: Unit = context.enemy
	var total_damage_dealt: int = 0

	match target:
		Target.ENEMY:
			total_damage_dealt = CombatCalculation.apply_damage(attacker, defender, damage, pierce_block)
		Target.BOTH:
			total_damage_dealt = CombatCalculation.apply_damage(attacker, defender, damage, pierce_block)
			total_damage_dealt += CombatCalculation.apply_damage(attacker, attacker, damage, pierce_block)

	print("DamageEffect: Total damage dealt: %s" % total_damage_dealt)
	# TODO: actually apply the damage to the unit