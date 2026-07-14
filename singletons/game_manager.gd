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

@export var card_db: CardDB

var context: BattleContext
var phase: Phase = Phase.DRAW


func start_battle(battle_context: BattleContext) -> void:
	context = battle_context
	context.deck.shuffle()
	_emit_deck_counts()


func draw_cards(count: int) -> Array[CardData]:
	var drawn := context.deck.draw(count)
	deck_count_changed.emit(context.deck.cards.size())
	phase = Phase.PLAN
	return drawn


func end_player_turn(hand_cards: Array[CardData], cards_to_draw: int) -> Array[CardData]:
	for card_data in hand_cards:
		context.deck.add_to_discard_pile(card_data)

	if context.deck.cards.is_empty():
		context.deck.cards.assign(context.deck.discard_pile)
		context.deck.discard_pile.clear()

	discard_count_changed.emit(context.deck.discard_pile.size())
	context.deck.shuffle()
	context.current_turn += 1
	phase = Phase.CHAIN_RESOLVING
	return draw_cards(cards_to_draw)


func add_card_to_deck(card: CardData) -> void:
	context.deck.cards.append(card)
	deck_count_changed.emit(context.deck.cards.size())


func _emit_deck_counts() -> void:
	deck_count_changed.emit(context.deck.cards.size())
	discard_count_changed.emit(context.deck.discard_pile.size())
