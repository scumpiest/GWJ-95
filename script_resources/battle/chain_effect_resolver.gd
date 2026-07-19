class_name ChainEffectResolver
extends RefCounted


func resolve_chain(
		context: BattleContext,
		slots: Array[Slot],
		on_activate: Callable,
) -> void:
	run_pre_effects(context)
	await run_active_effects(context, slots, on_activate)


func run_pre_effects(context: BattleContext) -> void:
	for slot_state in context.chain_slot_states:
		if not slot_state.is_active():
			continue
		for effect in slot_state.card.effects:
			if effect.get_timing() == CardEffect.Timing.PRE:
				effect.resolve(context, slot_state)


func run_active_effects(context: BattleContext, slots: Array[Slot], on_activate: Callable) -> void:
	for i in context.chain_slot_states.size():
		if context.enemy.health <= 0:
			return

		var slot_state: ChainSlotState = context.chain_slot_states[i]
		if not slot_state.is_active() or slot_state.skip_activation:
			continue

		var slot: Slot = slots[i]
		var card: CardVisual = slot.get_card()
		if card == null:
			continue

		for activation in slot_state.activation_count:
			if context.enemy.health <= 0:
				return

			if on_activate.is_valid():
				await on_activate.call(slot, card)

			for effect in slot_state.card.effects:
				if effect.get_timing() == CardEffect.Timing.ACTIVE:
					effect.resolve(context, slot_state)
