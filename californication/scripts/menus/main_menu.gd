extends Control

func _ready() -> void:
    $VBoxContainer/OpenWorld.pressed.connect(func(): SceneManager.goto("res://scenes/world/island.tscn"))
    $VBoxContainer/Missions.pressed.connect(func(): print("Missões"))
    $VBoxContainer/SelectChar.pressed.connect(func(): SceneManager.goto("res://scenes/menus/character_select.tscn"))
    $VBoxContainer/SaveGame.pressed.connect(func(): print("Salvar"))
    $HBoxContainer/Settings.pressed.connect(func(): print("Configurações"))
    $HBoxContainer/Achievements.pressed.connect(func(): print("Conquistas"))
