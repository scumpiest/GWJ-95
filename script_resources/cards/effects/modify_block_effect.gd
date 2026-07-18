class_name ModifyBlockEffect
extends CardEffect

enum Mode { ADD_PERCENT, SCALE_TO }

@export var mode: Mode = Mode.ADD_PERCENT
@export var percent: float = 0.5


func resolve(
	context: BattleContext,
	slot: ChainSlotState,
) -> void:
	slot.last_block_spent = 0

	var player: Unit = context.player
	var current_block: int = player.block

	if current_block <= 0:
		return

	match mode:
		Mode.ADD_PERCENT:
			var gained: int = int(floor(current_block * percent))
			if gained > 0:
				player.gain_block(gained)
		Mode.SCALE_TO:
			var remaining: int = int(floor(current_block * percent))
			var taken: int = current_block - remaining
			if taken > 0:
				player.lose_block(taken)
			slot.last_block_spent = taken