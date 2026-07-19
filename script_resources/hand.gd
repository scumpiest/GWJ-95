extends BoxContainer

const CARD_WIDTH := 128

@export var card_expansion_threshold: int = 5
@export var max_width_set: int
@export var duration_animation: float = 0.2

var tween: Tween


func _ready() -> void:
	custom_minimum_size = Vector2(0, 180)
	custom_maximum_size = Vector2(max_width_set, 180)
	size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	size_flags_vertical = Control.SIZE_SHRINK_CENTER
	alignment = BoxContainer.ALIGNMENT_CENTER
	add_theme_constant_override("separation", 12)
	child_order_changed.connect(_on_hand_changed)


func _on_hand_changed() -> void:
	animate_separation(
		get_theme_constant("separation"),
		calculate_separation_expanded(),
		custom_maximum_size.x,
		calculate_width(),
		duration_animation,
	)


func calculate_separation_expanded() -> int:
	var card_count := get_children().size()
	if card_count <= 1:
		return 0

	var calc: float = calculate_width() - (CARD_WIDTH * card_count)
	if calc == 0:
		return 0
	return int(calc / float(card_count - 1))


func calculate_width() -> int:
	var card_count := get_children().size()
	if card_count == 0:
		return 0

	var calculated_size: float = CARD_WIDTH * card_count
	calculated_size += pow(1.5, card_count) * 20.0
	if calculated_size >= max_width_set:
		return max_width_set
	return int(calculated_size)


func animate_separation(
	from: float,
	to: float,
	from_width: float,
	to_width: float,
	duration: float,
) -> void:
	if tween:
		tween.kill()

	tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.parallel().tween_method(
		func(value: float) -> void:
			custom_minimum_size.x = value
			custom_maximum_size.x = value,
		from_width,
		to_width,
		duration,
	).set_trans(Tween.TRANS_SINE)
	tween.parallel().tween_method(
		func(value: float) -> void:
			add_theme_constant_override("separation", int(value)),
		from,
		to,
		duration,
	).set_trans(Tween.TRANS_SINE)
