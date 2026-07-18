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
) -> void:
	var damage: int = compute_value(context, slot)
	if damage <= 0:
		return

	var attacker: Unit = context.player
	var defender: Unit = context.enemy

	match target:
		Target.ENEMY:
			CombatCalculation.apply_damage(attacker, defender, damage, pierce_block)
		Target.BOTH:
			CombatCalculation.apply_damage(attacker, defender, damage, pierce_block)
			CombatCalculation.apply_damage(attacker, attacker, damage, pierce_block)
	