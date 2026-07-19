class_name RewardScreen
extends Control

signal card_chosen(card_data: CardData)

const ICON_CHAR_START := Vector2(448, 504)
const ICON_MARK_START := Vector2(376, 591)
const ICON_STEP_X := 72.0
const NO_MARK_PROGRESS := [2, 5]
const MAX_PROGRESS := 6

@export var card_scene: PackedScene
@export var reward_options: Array[CardData] = []

@onready var _card_container: HBoxContainer = %CardChoices
@onready var _title_label: Label = %TitleLabel
@onready var _icon_char: Sprite2D = $IconChar
@onready var _icon_mark_template: Sprite2D = $IconMark

var _icon_marks: Array[Sprite2D] = []
var _progress: int = 0


func _ready() -> void:
	visible = false
	_icon_mark_template.visible = false
	_update_progress_icon()


# TODO: delete this, only for debugging
func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	if event.is_action_pressed("tweens_in"):
		set_progress(mini(_progress + 1, MAX_PROGRESS - 1))
		get_viewport().set_input_as_handled()


func show_choices(options: Array[CardData] = [], title: String = "Choose a card") -> void:
	var choices := options if not options.is_empty() else reward_options
	if choices.is_empty():
		return
	_title_label.text = title
	_update_progress_icon()
	_clear_cards()
	for card_data in choices:
		var card_visual := card_scene.instantiate() as CardVisual
		card_visual.reward_card = true
		card_visual.card_data = card_data
		card_visual.clicked_card.connect(_on_card_clicked)
		_card_container.add_child(card_visual)
	visible = true


func set_progress(progress: int) -> void:
	_progress = progress
	_icon_char.position = ICON_CHAR_START + Vector2(ICON_STEP_X * _progress, 0)
	_display_icon_marks(_progress)


func _display_icon_marks(progress: int) -> void:
	_clear_icon_marks()
	for i in range(progress + 1):
		if i in NO_MARK_PROGRESS:
			continue
		var mark := _icon_mark_template.duplicate() as Sprite2D
		mark.visible = true
		mark.position = ICON_MARK_START + Vector2(ICON_STEP_X * i, 0)
		add_child(mark)
		_icon_marks.append(mark)


func _clear_icon_marks() -> void:
	for mark in _icon_marks:
		mark.queue_free()
	_icon_marks.clear()


func _update_progress_icon() -> void:
	var progress := 0
	if LevelManager.current_level:
		progress = mini(LevelManager.levels.find(LevelManager.current_level), MAX_PROGRESS)
	set_progress(progress)


func _on_card_clicked(card: CardVisual) -> void:
	card_chosen.emit(card.card_data)
	visible = false
	_clear_cards()


func _clear_cards() -> void:
	for child in _card_container.get_children():
		child.queue_free()
