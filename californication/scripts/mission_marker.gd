extends Area3D
# Ícone de interação de uma missão no mundo aberto.

signal player_entered(id: int)
signal player_exited(id: int)

@export var mission_id := 1

@onready var label: Label3D = $Label

var t := 0.0


func _ready() -> void:
    label.text = str(mission_id)
    t = randf() * TAU
    body_entered.connect(_on_body_entered)
    body_exited.connect(_on_body_exited)


func _process(delta: float) -> void:
    t += delta * 2.0
    label.position.y = 9.0 + sin(t) * 0.3


func _on_body_entered(body: Node3D) -> void:
    if body is CharacterBody3D:
        player_entered.emit(mission_id)


func _on_body_exited(body: Node3D) -> void:
    if body is CharacterBody3D:
        player_exited.emit(mission_id)
