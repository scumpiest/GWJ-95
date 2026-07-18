class_name DamageEffect
extends CardEffect

enum Target {
	ENEMY,
	BOTH,
}

@export var target: Target = Target.ENEMY
@export var pierce_block: bool = false
@export var pierce_if_next_is_color: Array[CardEnums.CardColor] = []

func resolve(
		context: BattleContext,
		slot: ChainSlotState,
) -> void:
	var damage: int = compute_value(context, slot)
	if damage <= 0:
		return

	var attacker: Unit = context.player
	var defender: Unit = context.enemy

	if not pierce_if_next_is_color.is_empty():
		var next_color = context.get_next_slot_color(slot.slot_index)
		if next_color in pierce_if_next_is_color:
			pierce_block = true

	match target:
		Target.ENEMY:
			CombatCalculation.apply_damage(attacker, defender, damage, pierce_block)
		Target.BOTH:
			CombatCalculation.apply_damage(attacker, defender, damage, pierce_block)
			CombatCalculation.apply_damage(attacker, attacker, damage, pierce_block)
	