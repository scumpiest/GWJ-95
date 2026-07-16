extends Node

enum Phase {
	DRAW,
	PLAN,
	CHAIN_RESOLVING,
	ENEMY_TURN,
	END_TURN,
}

signal deck_count_changed(count: int)
signal discard_count_changed(count: int)
signal phase_changed(phase: Phase)

@export var card_db: CardDB

var context: BattleContext
var phase: Phase = Phase.DRAW


func start_battle(battle_context: BattleContext) -> void:
	context = battle_context
	context.deck.shuffle()
	_emit_deck_counts()


func can_end_turn() -> bool:
	return phase == Phase.PLAN


func begin_chain_resolve() -> bool:
	if not can_end_turn():
		return false
	_set_phase(Phase.CHAIN_RESOLVING)
	return true


func end_player_turn(discarded: Array[CardData], cards_to_draw: int) -> Array[CardData]:
	_set_phase(Phase.ENEMY_TURN)
	# TODO: Implement enemy turn actions

	discard_cards(discarded)
	_reshuffle_deck()
	context.current_turn += 1

	_set_phase(Phase.DRAW)
	return draw_cards(cards_to_draw)


func draw_cards(count: int) -> Array[CardData]:
	var drawn := context.deck.draw(count)
	deck_count_changed.emit(context.deck.cards.size())
	_set_phase(Phase.PLAN)
	return drawn


func discard_cards(cards: Array[CardData]) -> void:
	for card in cards:
		context.deck.add_to_discard_pile(card)
	discard_count_changed.emit(context.deck.discard_pile.size())


func add_card_to_deck(card: CardData) -> void:
	context.deck.cards.append(card)
	deck_count_changed.emit(context.deck.cards.size())


func _reshuffle_deck() -> void:
	if not context.deck.cards.is_empty():
		return
	context.deck.cards.assign(context.deck.discard_pile)
	context.deck.discard_pile.clear()
	context.deck.shuffle()
	_emit_deck_counts()


func _set_phase(new_phase: Phase) -> void:
	phase = new_phase
	phase_changed.emit(phase)

func _emit_deck_counts() -> void:
	deck_count_changed.emit(context.deck.cards.size())
	discard_count_changed.emit(context.deck.discard_pile.size())
