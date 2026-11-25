extends Control

func _ready() -> void:
    $VBoxContainer/NewGame.pressed.connect(_on_new_game)
    $VBoxContainer/LoadGame.pressed.connect(_on_load_game)

func _on_new_game() -> void:
    SceneManager.goto("res://scenes/menus/main_menu.tscn")

func _on_load_game() -> void:
    print("Load Game: será implementado na Etapa 9")
