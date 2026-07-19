extends Node

# ─────── Constants ────────────────────────────────────────
const BUS_MUSIC := "Music"
const BUS_SFX := "SFX"
const SFX_POOL_SIZE := 8
const MUSIC_FADE_DURATION := 0.6
const MUSIC_SILENT_VOLUME_DB := -80.0

# ─────── SFX Variables ────────────────────────────────────────
@export var sfx_card_click: AudioStream = preload("res://assets/sfx/Card Click SFX.ogg")
@export var sfx_card_hover: AudioStream = preload("res://assets/sfx/Card Hover SFX.ogg")
@export var sfx_card_placed: AudioStream = preload("res://assets/sfx/Card Placed SFX.ogg")
@export var sfx_card_swapped: AudioStream = preload("res://assets/sfx/Card Swapped SFX.ogg")
@export var sfx_card_draw: AudioStream = preload("res://assets/sfx/Card Draw SFX.ogg")
@export var sfx_card_discard: AudioStream = preload("res://assets/sfx/Card Discard SFX.ogg")
@export var sfx_card_trigger: AudioStream = preload("res://assets/sfx/Card Trigger SFX.ogg")
@export var sfx_card_deck_shuffle: AudioStream = preload("res://assets/sfx/Card Deck Shuffle SFX.ogg")
@export var sfx_ui_click: AudioStream = preload("res://assets/sfx/UI Click SFX.ogg")
@export var sfx_ui_hover: AudioStream = preload("res://assets/sfx/UI Hover SFX.ogg")
@export var sfx_shop_buy_item: AudioStream = preload("res://assets/sfx/Shop Buy Item SFX.ogg")
@export var sfx_shop_no_money: AudioStream = preload("res://assets/sfx/Shop No Money SFX.ogg")
@export var sfx_shop_money_gained: AudioStream = preload("res://assets/sfx/Shop Money Gained SFX.ogg")
@export var sfx_player_attack: AudioStream = preload("res://assets/sfx/Player Attack SFX.ogg")
@export var sfx_player_shield_activate: AudioStream = preload("res://assets/sfx/Player Shield Activate SFX.ogg")
@export var sfx_player_shield_block: AudioStream = preload("res://assets/sfx/Player Shield Block SFX.ogg")
@export var sfx_player_shield_break: AudioStream = preload("res://assets/sfx/Player Shield Break SFX.ogg")
@export var sfx_player_status_boost: AudioStream = preload("res://assets/sfx/Player Status Boost SFX.ogg")
@export var sfx_task_succeed: AudioStream = preload("res://assets/sfx/Task Succeed SFX.ogg")
@export var sfx_task_completed: AudioStream = preload("res://assets/sfx/Task Completed SFX.ogg")
@export var sfx_enemy_dies: AudioStream = preload("res://assets/sfx/Enemy Dies SFX.ogg")
@export var sfx_enemy_ground_hit: AudioStream = preload("res://assets/sfx/Enemy Ground Hit SFX.ogg")
@export var sfx_win_song: AudioStream = preload("res://assets/sfx/Game Card Win Song.ogg")
@export var sfx_lose_song: AudioStream = preload("res://assets/sfx/Game Card Lose Song.ogg")

# ─────── Music Variables ────────────────────────────────────────
@export var music_menu: AudioStream = preload("res://assets/musics/Game Card Main Menu.ogg")
@export var music_gameplay: AudioStream = preload("res://assets/musics/Game Card Gameplay.ogg")
@export var music_shop: AudioStream = preload("res://assets/musics/Game Card Shop.ogg")
@export var music_boss: AudioStream = preload("res://assets/musics/GameCard Boss.ogg")


var _sfx_players: Array[AudioStreamPlayer] = []
var _next_sfx_player_index: int = 0

var _music_player_a: AudioStreamPlayer
var _music_player_b: AudioStreamPlayer
var _active_music_player: AudioStreamPlayer
var _music_tween: Tween


func _ready() -> void:
	_setup_sfx_pool()
	_setup_music_players()
	_enable_music_looping()


func _setup_sfx_pool() -> void:
	for i in SFX_POOL_SIZE:
		var player := AudioStreamPlayer.new()
		player.bus = BUS_SFX
		add_child(player)
		_sfx_players.append(player)


func _setup_music_players() -> void:
	_music_player_a = AudioStreamPlayer.new()
	_music_player_a.bus = BUS_MUSIC
	add_child(_music_player_a)

	_music_player_b = AudioStreamPlayer.new()
	_music_player_b.bus = BUS_MUSIC
	add_child(_music_player_b)

	_active_music_player = _music_player_a


func _enable_music_looping() -> void:
	for stream in [music_menu, music_gameplay, music_shop, music_boss]:
		if stream and "loop" in stream:
			stream.loop = true


# ─────── SFX ────────────────────────────────────────
func play_sfx(stream: AudioStream, volume_db: float = 0.0, pitch_scale: float = 1.0) -> void:
	if stream == null or _sfx_players.is_empty():
		return
	var player := _sfx_players[_next_sfx_player_index]
	_next_sfx_player_index = (_next_sfx_player_index + 1) % _sfx_players.size()
	player.stream = stream
	player.volume_db = volume_db
	player.pitch_scale = pitch_scale
	player.play()


func play_card_click() -> void:
	play_sfx(sfx_card_click)


func play_card_hover() -> void:
	play_sfx(sfx_card_hover)


func play_card_placed() -> void:
	play_sfx(sfx_card_placed)


func play_card_swapped() -> void:
	play_sfx(sfx_card_swapped)


func play_card_draw() -> void:
	play_sfx(sfx_card_draw)


func play_card_discard() -> void:
	play_sfx(sfx_card_discard)


func play_card_trigger() -> void:
	play_sfx(sfx_card_trigger)


func play_card_deck_shuffle() -> void:
	play_sfx(sfx_card_deck_shuffle)


func play_ui_click() -> void:
	play_sfx(sfx_ui_click)


func play_ui_hover() -> void:
	play_sfx(sfx_ui_hover)


func play_shop_buy_item() -> void:
	play_sfx(sfx_shop_buy_item)


func play_shop_no_money() -> void:
	play_sfx(sfx_shop_no_money)


func play_shop_money_gained() -> void:
	play_sfx(sfx_shop_money_gained)


func play_player_attack() -> void:
	play_sfx(sfx_player_attack)


func play_player_shield_activate() -> void:
	play_sfx(sfx_player_shield_activate)


func play_player_shield_block() -> void:
	play_sfx(sfx_player_shield_block)


func play_player_shield_break() -> void:
	play_sfx(sfx_player_shield_break)


func play_player_status_boost() -> void:
	play_sfx(sfx_player_status_boost)


func play_task_succeed() -> void:
	play_sfx(sfx_task_succeed)


func play_task_completed() -> void:
	play_sfx(sfx_task_completed)


func play_enemy_dies() -> void:
	play_sfx(sfx_enemy_dies)


func play_enemy_ground_hit() -> void:
	play_sfx(sfx_enemy_ground_hit)


func play_win_song() -> void:
	play_sfx(sfx_win_song)


func play_lose_song() -> void:
	play_sfx(sfx_lose_song)


# ─────── Music ────────────────────────────────────────
func play_music(stream: AudioStream, fade_duration: float = MUSIC_FADE_DURATION) -> void:
	if stream == null:
		return
	if _active_music_player.stream == stream and _active_music_player.playing:
		return

	var incoming := _music_player_b if _active_music_player == _music_player_a else _music_player_a
	var outgoing := _active_music_player

	incoming.stream = stream
	incoming.volume_db = MUSIC_SILENT_VOLUME_DB
	incoming.play()

	if _music_tween:
		_music_tween.kill()
	_music_tween = create_tween()
	_music_tween.set_parallel(true)
	_music_tween.tween_property(incoming, "volume_db", 0.0, fade_duration)
	if outgoing.playing:
		_music_tween.tween_property(outgoing, "volume_db", MUSIC_SILENT_VOLUME_DB, fade_duration)
		_music_tween.chain().tween_callback(outgoing.stop)

	_active_music_player = incoming


func play_menu_music() -> void:
	play_music(music_menu)


func play_music_for_level(level_type: Level.LevelType) -> void:
	match level_type:
		Level.LevelType.SHOP:
			play_music(music_shop)
		Level.LevelType.BOSS:
			play_music(music_boss)
		_:
			play_music(music_gameplay)


func stop_music(fade_duration: float = MUSIC_FADE_DURATION) -> void:
	if not _active_music_player.playing:
		return
	if _music_tween:
		_music_tween.kill()
	_music_tween = create_tween()
	_music_tween.tween_property(
			_active_music_player,
			"volume_db",
			MUSIC_SILENT_VOLUME_DB,
			fade_duration,
	)
	_music_tween.tween_callback(_active_music_player.stop)


# ─────── Volume ────────────────────────────────────────
func set_music_volume(linear: float) -> void:
	_set_bus_volume(BUS_MUSIC, linear)


func set_sfx_volume(linear: float) -> void:
	_set_bus_volume(BUS_SFX, linear)


func _set_bus_volume(bus_name: String, linear: float) -> void:
	var bus_index := AudioServer.get_bus_index(bus_name)
	if bus_index == -1:
		return
	AudioServer.set_bus_volume_db(bus_index, linear_to_db(clamp(linear, 0.0, 1.0)))
