extends CanvasLayer
# Menu de veículos (tecla V). Mostra só os veículos desbloqueados.

signal vehicle_chosen(id: String)

var root: Control


func _ready() -> void:
    layer = 10
    process_mode = Node.PROCESS_MODE_ALWAYS  # funciona com o jogo pausado
    visible = false


func open() -> void:
    _build()
    visible = true
    get_tree().paused = true
    Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func close() -> void:
    visible = false
    get_tree().paused = false
    Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _unhandled_input(event: InputEvent) -> void:
    if visible and (event.is_action_pressed("vehicle_menu") or event.is_action_pressed("ui_cancel")):
        close()
        get_viewport().set_input_as_handled()


func _build() -> void:
    if root:
        root.queue_free()
    root = Control.new()
    root.set_anchors_preset(Control.PRESET_FULL_RECT)
    add_child(root)

    var dim := ColorRect.new()
    dim.set_anchors_preset(Control.PRESET_FULL_RECT)
    dim.color = Color(0, 0, 0, 0.6)
    root.add_child(dim)

    var center := CenterContainer.new()
    center.set_anchors_preset(Control.PRESET_FULL_RECT)
    root.add_child(center)

    var panel := PanelContainer.new()
    center.add_child(panel)

    var margin := MarginContainer.new()
    for side in ["left", "right", "top", "bottom"]:
        margin.add_theme_constant_override("margin_" + side, 24)
    panel.add_child(margin)

    var box := VBoxContainer.new()
    box.add_theme_constant_override("separation", 12)
    margin.add_child(box)

    var title := Label.new()
    title.text = "VEÍCULOS"
    title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    title.add_theme_font_size_override("font_size", 32)
    box.add_child(title)

    var locked := 0
    for v in GameState.vehicles:
        if GameState.is_vehicle_unlocked(v["id"]):
            var b := Button.new()
            b.text = v["name"]
            b.custom_minimum_size = Vector2(360, 50)
            b.pressed.connect(_on_choose.bind(v["id"]))
            box.add_child(b)
        else:
            locked += 1

    if locked > 0:
        var info := Label.new()
        info.text = "%d veículo(s) ainda bloqueado(s)" % locked
        info.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
        info.modulate = Color(1, 1, 1, 0.6)
        box.add_child(info)

    var close_btn := Button.new()
    close_btn.text = "Fechar"
    close_btn.pressed.connect(close)
    box.add_child(close_btn)


func _on_choose(id: String) -> void:
    close()
    vehicle_chosen.emit(id)
