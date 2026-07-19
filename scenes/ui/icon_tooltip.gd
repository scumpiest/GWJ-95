class_name IconTooltip
extends PanelContainer

const ICON_DIR := "res://assets/sprites/icons/"
const ICON_TOOLTIPS := {
	"damage": "Damage",
	"block": "Block",
	"vulnerability": "Vulnerable: Takes more damage",
	"weakness": "Weakness: Deals less damage",
	"strength": "Strength: Deals more damage",
	"protection": "Protection: Gains more block",
	"redcassette": "Red cassette",
	"greencassette": "Green cassette",
	"purplecassette": "Purple cassette",
	"icon_ramp_up": ("Attacks deal more damage and defense gives more block with every turn"),
	"icon_improvisation": (
		"Every turn, 1-3 slots become colored with a random color. " + "Any cassette in that slot switches its color to the slot's one"
	),
	"icon_purple_vulnerability": ("Receives twice as much damage from Purple Cassettes"),
	"icon_red_vulnerability": ("Receives twice as much damage from Red Cassettes"),
}

@onready var icon: TextureRect = $HBox/Icon
@onready var label: Label = $HBox/Label


func _ready() -> void:
	visible = false
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_process(false)
	add_to_group("icon_tooltip")


func show_for(key: String) -> void:
	var text: String = ICON_TOOLTIPS.get(key, "")
	if text.is_empty():
		return
	icon.texture = load(ICON_DIR + key + ".png") as Texture2D
	label.text = text
	visible = true
	reset_size()
	set_process(true)
	_follow_mouse()


func hide_tooltip() -> void:
	visible = false
	set_process(false)


func _process(_delta: float) -> void:
	_follow_mouse()


func _follow_mouse() -> void:
	global_position = get_global_mouse_position() + Vector2(12, 12)
	global_position = get_global_mouse_position() + Vector2(12, 12)
