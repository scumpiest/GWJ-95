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
signal enemy_intent_changed(move: EnemyMove)

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
	_resolve_enemy_turn()

	discard_cards(discarded)
	context.current_turn += 1

	if context.enemy != null and context.enemy.health > 0 and context.player.health > 0:
		roll_enemy_intent()

	_set_phase(Phase.DRAW)
	return draw_cards(cards_to_draw)


func _resolve_enemy_turn() -> void:
	if context == null or context.enemy == null or context.enemy.health <= 0:
		return

	if context.enemy_intent != null:
		context.enemy_intent.execute(context, context.enemy_data)


func roll_enemy_intent() -> EnemyMove:
	if context == null:
		return null
	var move := context.roll_enemy_intent()
	enemy_intent_changed.emit(move)
	print("Enemy intent: ", move)
	return move


func draw_cards(count: int) -> Array[CardData]:
	var drawn := context.deck.draw(count)
	_emit_deck_counts()
	_set_phase(Phase.PLAN)
	LevelManager.send_task_event(BattleTask.EventType.TURN_END, null)
	return drawn


func discard_cards(cards: Array[CardData]) -> void:
	for card in cards:
		context.deck.add_to_discard_pile(card)
	discard_count_changed.emit(context.deck.discard_pile.size())


func add_card_to_deck(card: CardData) -> void:
	context.deck.cards.append(card)
	deck_count_changed.emit(context.deck.cards.size())


func _set_phase(new_phase: Phase) -> void:
	phase = new_phase
	phase_changed.emit(phase)

func _emit_deck_counts() -> void:
	deck_count_changed.emit(context.deck.cards.size())
	discard_count_changed.emit(context.deck.discard_pile.size())
