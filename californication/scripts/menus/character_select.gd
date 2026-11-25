extends Control

const STAT_NAMES := {
    "speed": "Velocidade",
    "resilience": "Resistência",
    "agility": "Agilidade",
    "driving": "Direção",
}

var cards := []  # lista de {panel, button}


func _ready() -> void:
    var root := VBoxContainer.new()
    root.set_anchors_preset(Control.PRESET_FULL_RECT)
    root.alignment = BoxContainer.ALIGNMENT_CENTER
    root.add_theme_constant_override("separation", 24)
    add_child(root)

    var title := Label.new()
    title.text = "SELECT CHARACTER"
    title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    title.add_theme_font_size_override("font_size", 40)
    root.add_child(title)

    var row := HBoxContainer.new()
    row.alignment = BoxContainer.ALIGNMENT_CENTER
    row.add_theme_constant_override("separation", 32)
    root.add_child(row)

    for i in GameState.characters.size():
        row.add_child(_make_card(i))

    var back := Button.new()
    back.text = "Voltar"
    back.custom_minimum_size = Vector2(200, 50)
    back.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
    back.pressed.connect(func(): SceneManager.goto("res://scenes/menus/main_menu.tscn"))
    root.add_child(back)

    _refresh()


func _make_card(i: int) -> PanelContainer:
    var data: Dictionary = GameState.characters[i]

    var panel := PanelContainer.new()
    var margin := MarginContainer.new()
    for side in ["left", "right", "top", "bottom"]:
        margin.add_theme_constant_override("margin_" + side, 16)
    panel.add_child(margin)

    var box := VBoxContainer.new()
    box.add_theme_constant_override("separation", 10)
    margin.add_child(box)

    var swatch := ColorRect.new()
    swatch.custom_minimum_size = Vector2(180, 180)
    swatch.color = data["color"]
    box.add_child(swatch)

    var name_label := Label.new()
    name_label.text = data["name"]
    name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    name_label.add_theme_font_size_override("font_size", 24)
    box.add_child(name_label)

    for key in STAT_NAMES:
        var line := HBoxContainer.new()
        var lbl := Label.new()
        lbl.text = STAT_NAMES[key]
        lbl.custom_minimum_size = Vector2(110, 0)
        line.add_child(lbl)
        var bar := ProgressBar.new()
        bar.min_value = 0
        bar.max_value = 10
        bar.value = data["stats"][key]
        bar.show_percentage = false
        bar.custom_minimum_size = Vector2(100, 16)
        bar.size_flags_vertical = Control.SIZE_SHRINK_CENTER
        line.add_child(bar)
        box.add_child(line)

    var button := Button.new()
    button.pressed.connect(_on_select.bind(i))
    box.add_child(button)

    cards.append({"panel": panel, "button": button})
    return panel


func _on_select(i: int) -> void:
    GameState.select_character(i)
    _refresh()


func _refresh() -> void:
    for i in cards.size():
        var selected: bool = (i == GameState.selected_index)
        cards[i]["panel"].modulate = Color(1, 1, 1) if selected else Color(0.6, 0.6, 0.6)
        cards[i]["button"].text = "✔ Selecionado" if selected else "Selecionar"
