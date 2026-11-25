extends Control

func _ready() -> void:
    $Logo.modulate.a = 0.0
    var t := create_tween()
    t.tween_property($Logo, "modulate:a", 1.0, 1.0)
    t.tween_interval(1.5)
    t.tween_property($Logo, "modulate:a", 0.0, 1.0)
    t.tween_callback(SceneManager.goto.bind("res://scenes/menus/title_screen.tscn"))
