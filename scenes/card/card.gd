class_name Card
extends Node2D

@onready var drag_and_drop: DragAndDrop = $DragAndDrop

func _ready() -> void:
	drag_and_drop.drag_started.connect(on_drag_started)
	drag_and_drop.drag_canceled.connect(on_drag_canceled)

func reset_after_dragging(starting_position: Vector2) -> void:
	global_position = starting_position

func on_drag_started() -> void:
	print("drag started")

func on_drag_canceled(starting_position: Vector2) -> void:
	reset_after_dragging(starting_position)