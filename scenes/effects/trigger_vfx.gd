class_name TriggerVfx
extends Node2D

const BUFF_STATUSES := ["protection", "strength"]
const DEBUFF_STATUSES := ["weakness", "vulnerable"]
const HIT := "hit"
const DEFEAT := "defeat"

@onready var _sprite: SpineSprite = $SpineSprite


func _ready() -> void:
	_sprite.animation_ended.connect(_on_animation_ended)


func play(animation_name: String) -> void:
	var skeleton_data := _sprite.skeleton_data_res
	if skeleton_data == null or not skeleton_data.find_animation(animation_name):
		queue_free()
		return
	_sprite.get_animation_state().set_animation(animation_name, false, 0)


# Maps a status key (as used by Unit.statuses) to the buff/debuff trigger
# animation that should play when that status is applied.
static func animation_for_status(status: String) -> String:
	if status in BUFF_STATUSES:
		return "buff"
	if status in DEBUFF_STATUSES:
		return "debuff"
	return ""


static func animation_for_cassette_color(color: CardEnums.CardColor) -> String:
	match color:
		CardEnums.CardColor.RED:
			return "cassette_activation_red"
		CardEnums.CardColor.GREEN:
			return "cassette_activation_green"
		CardEnums.CardColor.PURPLE:
			return "cassette_activation_purple"
		_:
			return ""


# Uses load() rather than preload() to avoid a circular reference, since this
# scene's own script is the one making the call.
static func spawn(
	parent: Node,
	animation_name: String,
	local_position: Vector2 = Vector2.ZERO,
	vfx_z_index: int = 0,
) -> TriggerVfx:
	if animation_name.is_empty():
		return null

	var scene := load("res://scenes/effects/trigger_vfx.tscn") as PackedScene
	var vfx := scene.instantiate() as TriggerVfx
	parent.add_child(vfx)
	vfx.position = local_position
	vfx.z_index = vfx_z_index
	vfx.play(animation_name)
	return vfx


func _on_animation_ended(
	_sprite_param: SpineSprite, _state: SpineAnimationState, _entry: SpineTrackEntry
) -> void:
	queue_free()
