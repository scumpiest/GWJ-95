class_name ModifyBlockEffect
extends CardEffect

enum Mode { ADD_PERCENT, SCALE_TO }

@export var mode: Mode = Mode.ADD_PERCENT
@export var percent: float = 0.5
@export var require_no_adjacent_color: bool = false
@export var require_not_last: bool = false


func resolve(
	context: BattleContext,
	slot: ChainSlotState,
) -> void:
	slot.last_block_spent = 0

	# conditions check for G4
	if require_not_last and context.is_last_in_chain(slot.slot_index):
		slot.skip_activation = true
		return
	if require_no_adjacent_color and context.count_adjacent_same_color(slot.slot_index, condition_color) > 0:
		slot.skip_activation = true
		return

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