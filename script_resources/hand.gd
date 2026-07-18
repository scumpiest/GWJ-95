extends BoxContainer

##
@export var card_expansion_threshold: int = 5
@export var max_width_set: int
@export var duration_animation: float = 0.2

var tween: Tween

var expanding_enabled: bool = true

func _ready() -> void:
	self.add_theme_constant_override("separation", 12)
	self.child_order_changed.connect(_enable_disable_expanding)

func _enable_disable_expanding() -> void:
	animate_separation(self.get_theme_constant("separation"), calculate_separation_expanded(), self.custom_maximum_size.x, calculate_width(),  duration_animation)
	pass

func calculate_separation_expanded() -> int:
	var card_count = self.get_children().size()
	var calc: float = calculate_width() - (128 * card_count)
	if calc == 0:
		return 0
	return calc / (card_count - 1)

func calculate_width() -> int:
	var card_count = self.get_children().size()
	var calculated_size = (128 * card_count)
	calculated_size += pow(1.5, card_count) * 20
	if calculated_size >= max_width_set:
		return max_width_set
	else:
		return calculated_size

func animate_separation(from: float, to: float, fromWidth: float, toWidth: float, duration: float):
	if tween:
		tween.kill()

	tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.parallel().tween_method(
		func(value):
			self.custom_maximum_size.x = value
			pass,
		fromWidth,
		toWidth,
		duration
	).set_trans(Tween.TRANS_SINE)
	tween.parallel().tween_method(
		func(value):
			self.add_theme_constant_override("separation", int(value)),
		from,
		to,
		duration
	).set_trans(Tween.TRANS_SINE)
