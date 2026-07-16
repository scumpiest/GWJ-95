class_name DamageEffect
extends CardEffect

enum Target { ENEMY, PLAYER, BOTH }

@export var target: Target = Target.ENEMY
@export var pierce_block: bool = false

func resolve(
	_context: BattleContext,
	_slot: ChainSlotState,
	_resolver: ChainEffectResolver,
) -> void:
	pass
