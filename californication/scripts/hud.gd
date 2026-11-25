extends CanvasLayer
# Interface do mundo aberto: minimapa, dicas de controle e aviso de interação.

const MAP_SIZE := 220
const MAP_RANGE := 140.0  # quantos metros o minimapa mostra

var player: Node3D
var cam: Camera3D
var prompt: Label


func _ready() -> void:
    _build_minimap()
    _build_labels()


func _process(_delta: float) -> void:
    if is_instance_valid(player) and cam:
        cam.global_position = Vector3(player.global_position.x, 150.0, player.global_position.z)


func show_prompt(text: String) -> void:
    prompt.text = text
    prompt.visible = true


func hide_prompt() -> void:
    prompt.visible = false


func _build_minimap() -> void:
    var map_root := Control.new()
    map_root.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
    map_root.offset_left = -MAP_SIZE - 20
    map_root.offset_top = -MAP_SIZE - 20
    map_root.offset_right = -20
    map_root.offset_bottom = -20
    map_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
    add_child(map_root)

    var frame := ColorRect.new()
    frame.color = Color(0, 0, 0, 0.85)
    frame.position = Vector2(-4, -4)
    frame.size = Vector2(MAP_SIZE + 8, MAP_SIZE + 8)
    frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
    map_root.add_child(frame)

    var container := SubViewportContainer.new()
    container.stretch = true
    container.mouse_filter = Control.MOUSE_FILTER_IGNORE
    map_root.add_child(container)
    container.size = Vector2(MAP_SIZE, MAP_SIZE)

    var vp := SubViewport.new()
    vp.size = Vector2i(MAP_SIZE, MAP_SIZE)
    vp.render_target_update_mode = SubViewport.UPDATE_ALWAYS
    container.add_child(vp)

    # Câmera ortogonal olhando de cima para baixo (norte para cima)
    cam = Camera3D.new()
    cam.projection = Camera3D.PROJECTION_ORTHOGONAL
    cam.size = MAP_RANGE
    cam.rotation_degrees = Vector3(-90, 0, 0)
    vp.add_child(cam)
    cam.current = true

    # Ponto vermelho = jogador (sempre no centro)
    var dot := ColorRect.new()
    dot.color = Color(1, 0.1, 0.1)
    dot.size = Vector2(10, 10)
    dot.position = Vector2(MAP_SIZE, MAP_SIZE) / 2.0 - Vector2(5, 5)
    dot.mouse_filter = Control.MOUSE_FILTER_IGNORE
    map_root.add_child(dot)


func _build_labels() -> void:
    var help := Label.new()
    help.text = "WASD mover | Espaço pular | Mouse câmera | E interagir | V veículos | F entrar/sair | ESC solta o mouse | F1 menu"
    help.position = Vector2(12, 10)
    add_child(help)

    prompt = Label.new()
    prompt.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
    prompt.offset_left = -300
    prompt.offset_right = 300
    prompt.offset_top = -110
    prompt.offset_bottom = -70
    prompt.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    prompt.add_theme_font_size_override("font_size", 26)
    prompt.add_theme_color_override("font_outline_color", Color.BLACK)
    prompt.add_theme_constant_override("outline_size", 8)
    prompt.visible = false
    add_child(prompt)
