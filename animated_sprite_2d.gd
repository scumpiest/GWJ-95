extends AnimatedSprite2D

@onready var timer: Timer = $"../Timer"

func _ready() -> void:
	timer.start()

func _on_timer_timeout() -> void:
	self.play("default")
