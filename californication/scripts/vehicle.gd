extends CharacterBody3D
# Veículo arcade: simples de dirigir e fácil de ajustar.
# Os valores de cada veículo ficam em GameState.vehicles.

const GRAVITY := 24.0
const MOUSE_SENS := 0.003

var max_speed := 28.0   # velocidade máxima (m/s)
var accel := 14.0       # aceleração
var turn_rate := 1.8    # velocidade de curva
var brake := 30.0       # frenagem
var drag := 6.0         # desaceleração ao soltar o acelerador
var speed := 0.0        # velocidade para frente atual
var driver = null       # quem está dirigindo (null = estacionado)

@onready var pivot: Node3D = $CameraPivot
@onready var arm: SpringArm3D = $CameraPivot/SpringArm3D


func _ready() -> void:
    arm.add_excluded_object(get_rid())
    pivot.rotation.x = deg_to_rad(-12.0)


# Monta o visual e a colisão a partir dos dados do veículo
func setup(data: Dictionary) -> void:
    max_speed = data["max_speed"]
    accel = data["accel"]
    turn_rate = data["turn"]
    var size: Vector3 = data["size"]
    var color: Color = data["color"]

    arm.spring_length = 5.0 + size.z
    pivot.position.y = size.y + 1.0

    var cs := CollisionShape3D.new()
    var shape := BoxShape3D.new()
    shape.size = size
    cs.shape = shape
    cs.position = Vector3(0, size.y / 2.0, 0)
    add_child(cs)

    # Chassi, cabine (mais atrás), faróis (na frente) e rodas
    _add_box(Vector3(size.x, size.y - 0.3, size.z), color, Vector3(0, 0.3 + (size.y - 0.3) / 2.0, 0))
    _add_box(Vector3(size.x * 0.8, 0.7, size.z * 0.45), color.lightened(0.35), Vector3(0, size.y + 0.35, size.z * 0.12))
    for sx in [-1, 1]:
        _add_box(Vector3(0.4, 0.25, 0.1), Color(1, 1, 0.6), Vector3(sx * size.x * 0.3, size.y * 0.55, -size.z / 2.0))
        for sz in [-1, 1]:
            _add_wheel(Vector3(sx * (size.x / 2.0 - 0.1), 0.4, sz * (size.z / 2.0 - 0.7)))


func _add_box(size: Vector3, color: Color, pos: Vector3) -> void:
    var mi := MeshInstance3D.new()
    var bm := BoxMesh.new()
    bm.size = size
    mi.mesh = bm
    var mat := StandardMaterial3D.new()
    mat.albedo_color = color
    mi.material_override = mat
    mi.position = pos
    add_child(mi)


func _add_wheel(pos: Vector3) -> void:
    var mi := MeshInstance3D.new()
    var cm := CylinderMesh.new()
    cm.top_radius = 0.4
    cm.bottom_radius = 0.4
    cm.height = 0.3
    mi.mesh = cm
    var mat := StandardMaterial3D.new()
    mat.albedo_color = Color(0.08, 0.08, 0.08)
    mi.material_override = mat
    mi.rotation_degrees = Vector3(0, 0, 90)
    mi.position = pos
    add_child(mi)


func _unhandled_input(event: InputEvent) -> void:
    if driver == null:
        return
    if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
        pivot.rotation.y -= event.relative.x * MOUSE_SENS
        pivot.rotation.x = clamp(
            pivot.rotation.x - event.relative.y * MOUSE_SENS,
            deg_to_rad(-50), deg_to_rad(10))
    elif event.is_action_pressed("ui_cancel"):
        if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
            Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
        else:
            Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
    elif event is InputEventMouseButton and event.pressed \
            and Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
        Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
    elif event is InputEventKey and event.pressed and event.keycode == KEY_F1:
        SceneManager.goto("res://scenes/menus/main_menu.tscn")


func _physics_process(delta: float) -> void:
    if driver != null:
        var throttle := Input.get_axis("move_back", "move_forward")
        var steer := Input.get_axis("move_right", "move_left")

        if throttle > 0.0:
            if speed < 0.0:
                speed += brake * delta
            else:
                speed += accel * delta
        elif throttle < 0.0:
            if speed > 0.0:
                speed -= brake * delta
            else:
                speed -= accel * 0.7 * delta
        else:
            speed = move_toward(speed, 0.0, drag * delta)

        # Freio de mão
        if Input.is_action_pressed("jump"):
            speed = move_toward(speed, 0.0, brake * 1.5 * delta)

        speed = clamp(speed, -max_speed * 0.4, max_speed)

        # Só consegue virar se estiver em movimento (e inverte ao dar ré)
        var grip := clampf(speed / (max_speed * 0.3), -1.0, 1.0)
        rotation.y += steer * turn_rate * grip * delta

        # A câmera livre volta para trás do veículo aos poucos
        pivot.rotation.y = lerp_angle(pivot.rotation.y, 0.0, 1.5 * delta)
    else:
        speed = move_toward(speed, 0.0, brake * delta)

    var forward := -global_transform.basis.z
    velocity.x = forward.x * speed
    velocity.z = forward.z * speed
    if is_on_floor():
        velocity.y = -0.5
    else:
        velocity.y -= GRAVITY * delta

    move_and_slide()

    # Bateu em algo? A velocidade para frente cai sozinha
    speed = velocity.x * forward.x + velocity.z * forward.z
