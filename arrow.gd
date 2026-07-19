extends AnimatedSprite2D

var tween: Tween

func _ready() -> void:
	self.play("default")
	self.set_visible(false)
	
	
func fill_1_slot():
	
	self.set_visible(true)
	self.set_rotation_degrees(-153.4)
	self.set_global_position(Vector2(321, 423))
	
	
	if tween and tween.is_running():
		tween.kill()
	
	tween = create_tween()
	
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_SPRING)
	
	tween.tween_property(self, "global_position", Vector2(304, 210), 0.5)
	tween.parallel().tween_property(self, "rotation_degrees", -39, 0.5)
	
	tween.set_trans(Tween.TRANS_LINEAR)
	tween.parallel().tween_property(self, "visible", false, 0.2).set_delay(0.8)


func switch_cards():
	
	self.set_visible(true)
	self.set_rotation_degrees(324.2)
	self.set_global_position(Vector2(658, 210))
	
	
	if tween and tween.is_running():
		tween.kill()
	
	tween = create_tween()
	
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_SPRING)
	
	tween.tween_property(self, "global_position", Vector2(540, 210), 0.5)
	
	tween.set_trans(Tween.TRANS_LINEAR)
	tween.parallel().tween_property(self, "visible", false, 0.2).set_delay(0.8)

func highlight_end_turn():
	self.set_visible(true)
	self.set_rotation_degrees(142)
	self.set_global_position(Vector2(1017, 411))
