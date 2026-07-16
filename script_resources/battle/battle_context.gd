class_name BattleContext
extends RefCounted

var player: Unit
var enemy: Unit
var current_turn: int
var is_player_turn: bool
var is_battle_over: bool
var player_won: bool

var chain_slot_states: Array[ChainSlotState] = []

var deck: DeckData


func _init(p_player: Unit, p_enemy: Unit, p_deck: DeckData, chain_size: int = 5) -> void:
	player = p_player
	enemy = p_enemy
	deck = p_deck
	current_turn = 1
	is_player_turn = true
	is_battle_over = false
	player_won = false

	chain_slot_states.clear()
	chain_slot_states.resize(chain_size)
	for i in chain_size:
		var slot_state := ChainSlotState.new()
		slot_state.slot_index = i
		chain_slot_states[i] = slot_state


func count_color_in_chain(color: CardEnums.CardColor) -> int:
	var count: int = 0
	for slot_state in chain_slot_states:
		if slot_state.is_active() and slot_state.card_color == color:
			count += 1
	return count


func count_adjacent_same_color(slot_index: int) -> int:
	if not _is_valid_slot_index(slot_index):
		return 0

	var slot_state := chain_slot_states[slot_index]
	if not slot_state.is_active():
		return 0

	var color := slot_state.card_color
	var count: int = 0

	if get_next_slot_color(slot_index) == color:
		count += 1

	if get_previous_slot_color(slot_index) == color:
		count += 1

	return count


func get_previous_slot_color(slot_index: int) -> Variant:
	if slot_index <= 0 or not _is_valid_slot_index(slot_index):
		return null

	var prev := chain_slot_states[slot_index - 1]
	if not prev.is_active():
		return null

	return prev.card_color


func get_next_slot_color(slot_index: int) -> Variant:
	if not _is_valid_slot_index(slot_index) or slot_index >= chain_slot_states.size() - 1:
		return null

	var next := chain_slot_states[slot_index + 1]
	if not next.is_active():
		return null

	return next.card_color


func is_first_in_chain(slot_index: int) -> bool:
	if not _is_valid_slot_index(slot_index) or not chain_slot_states[slot_index].is_active():
		return false

	for i in slot_index:
		if chain_slot_states[i].is_active():
			return false

	return true


func is_last_in_chain(slot_index: int) -> bool:
	if not _is_valid_slot_index(slot_index) or not chain_slot_states[slot_index].is_active():
		return false

	for i in range(slot_index + 1, chain_slot_states.size()):
		if chain_slot_states[i].is_active():
			return false

	return true


func get_active_slot_indices() -> Array[int]:
	var indices: Array[int] = []
	for i in chain_slot_states.size():
		if chain_slot_states[i].is_active():
			indices.append(i)
	return indices


func get_slot_state(index: int) -> ChainSlotState:
	if not _is_valid_slot_index(index):
		return null
	return chain_slot_states[index]


func _is_valid_slot_index(slot_index: int) -> bool:
	return slot_index >= 0 and slot_index < chain_slot_states.size()
