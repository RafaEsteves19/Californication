extends Node3D
# Controla o mundo aberto: pontos de missão, veículos e interações.

const VEHICLE_SCENE := preload("res://scenes/vehicle.tscn")

var marker_scene := preload("res://scenes/world/mission_marker.tscn")

@onready var map = $Map
@onready var player: CharacterBody3D = $Player
@onready var hud = $HUD

var spawn_point := Vector3(0, 1, 0)
var current_mission := -1
var vehicle_menu
var current_vehicle = null  # veículo atual (estacionado ou em uso)
var driving := false


func _ready() -> void:
    spawn_point = map.get_spawn_point()
    player.global_position = spawn_point
    _build_markers()
    hud.player = player

    vehicle_menu = preload("res://scripts/vehicle_menu.gd").new()
    add_child(vehicle_menu)
    vehicle_menu.vehicle_chosen.connect(_on_vehicle_chosen)


func _physics_process(_delta: float) -> void:
    # Caiu no mar: volta para o ponto inicial
    var actor = current_vehicle if driving else player
    if actor.global_position.y < -8.0:
        actor.global_position = spawn_point
        actor.velocity = Vector3.ZERO
        if driving:
            actor.speed = 0.0
    # Veículo estacionado que caiu no mar some
    if current_vehicle != null and not driving and current_vehicle.global_position.y < -8.0:
        current_vehicle.queue_free()
        current_vehicle = null


func _unhandled_input(event: InputEvent) -> void:
    if event.is_action_pressed("interact") and current_mission != -1:
        print("Abrir missão ", current_mission)
        hud.show_prompt("Missão %d: será implementada na Etapa 7" % current_mission)
    elif event.is_action_pressed("vehicle_toggle"):
        _toggle_vehicle()
    elif event.is_action_pressed("vehicle_menu"):
        vehicle_menu.open()
    elif event is InputEventKey and event.pressed and event.keycode == KEY_F2:
        # Atalho de teste: libera todos os veículos
        for v in GameState.vehicles:
            GameState.unlock_vehicle(v["id"])
        _flash_hint("[TESTE] Todos os veículos liberados")


# ------------------------------------------------------------ missões
func _build_markers() -> void:
    var points: Array = map.get_mission_points()
    for i in points.size():
        var m = marker_scene.instantiate()
        m.mission_id = i + 1
        m.position = points[i]
        add_child(m)
        m.player_entered.connect(_on_player_entered)
        m.player_exited.connect(_on_player_exited)


func _on_player_entered(id: int) -> void:
    current_mission = id
    hud.show_prompt("Aperte E para abrir a Missão %d" % id)


func _on_player_exited(id: int) -> void:
    if current_mission == id:
        current_mission = -1
        hud.hide_prompt()


# ------------------------------------------------------------ veículos
func _on_vehicle_chosen(id: String) -> void:
    if driving:
        _exit_vehicle()
    if current_vehicle != null:
        current_vehicle.queue_free()
        current_vehicle = null

    var data := GameState.get_vehicle(id)
    var v = VEHICLE_SCENE.instantiate()
    add_child(v)
    v.setup(data)

    # Aparece 5 metros na frente do jogador, virado para o mesmo lado
    var visual: Node3D = player.get_node("Visual")
    var fwd: Vector3 = -visual.global_transform.basis.z
    v.global_position = player.global_position + fwd * 5.0 + Vector3(0, 0.5, 0)
    v.rotation.y = visual.global_rotation.y

    current_vehicle = v
    _enter_vehicle(v)


func _toggle_vehicle() -> void:
    if driving:
        _exit_vehicle()
    elif current_vehicle != null:
        if player.global_position.distance_to(current_vehicle.global_position) < 6.0:
            _enter_vehicle(current_vehicle)


func _enter_vehicle(v) -> void:
    driving = true
    v.driver = player
    player.visible = false
    player.process_mode = Node.PROCESS_MODE_DISABLED
    player.get_node("CollisionShape3D").set_deferred("disabled", true)
    v.get_node("CameraPivot/SpringArm3D/Camera3D").make_current()
    hud.player = v
    _flash_hint("F: sair do veículo | W/S acelerar e frear | A/D virar | Espaço: freio de mão")


func _exit_vehicle() -> void:
    var v = current_vehicle
    driving = false
    v.driver = null
    # Sai pela lateral esquerda do veículo
    player.global_position = v.global_position + v.global_transform.basis.x * 3.0 + Vector3(0, 1.0, 0)
    player.velocity = Vector3.ZERO
    player.visible = true
    player.process_mode = Node.PROCESS_MODE_INHERIT
    player.get_node("CollisionShape3D").set_deferred("disabled", false)
    player.get_node("CameraPivot").rotation.y = v.rotation.y
    player.get_node("CameraPivot/SpringArm3D/Camera3D").make_current()
    hud.player = player


func _flash_hint(text: String) -> void:
    hud.show_prompt(text)
    await get_tree().create_timer(3.5).timeout
    if current_mission == -1:
        hud.hide_prompt()
