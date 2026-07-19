class_name DamageEffect
extends CardEffect

enum Target {
	ENEMY,
	BOTH,
}

@export var target: Target = Target.ENEMY
@export var pierce_block: bool = false
@export var pierce_if_next_is_color: Array[CardEnums.CardColor] = []
@export var use_last_block_spent: bool = false

# Override the compute_value method to return the last block spent if use_last_block_spent is true.
func compute_value(context: BattleContext, slot: ChainSlotState) -> int:
	if use_last_block_spent:
		return slot.last_block_spent
	return super.compute_value(context, slot)

func resolve(
		context: BattleContext,
		slot: ChainSlotState,
) -> void:
	slot.last_damage_dealt = 0

	var damage: int = compute_value(context, slot)
	if damage <= 0:
		return

	var attacker: Unit = context.player
	var defender: Unit = context.enemy

	if not pierce_if_next_is_color.is_empty():
		var next_color = context.get_next_slot_color(slot.slot_index)
		if next_color in pierce_if_next_is_color:
			pierce_block = true

	AudioManager.play_player_attack()
	match target:
		Target.ENEMY:
			slot.last_damage_dealt = CombatCalculation.apply_damage(
					attacker, defender, damage, pierce_block
			)
		Target.BOTH:
			slot.last_damage_dealt = CombatCalculation.apply_damage(
					attacker, defender, damage, pierce_block
			)
			CombatCalculation.apply_damage(attacker, attacker, damage, pierce_block)
	