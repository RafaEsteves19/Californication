extends Node3D
# MAPA PROTÓTIPO (ilha gerada por código).
# Para usar o mapa final do Blender, substitua a cena map.tscn por uma cena
# que ofereça as mesmas duas funções abaixo: get_spawn_point e get_mission_points.

const ISLAND_RADIUS := 120.0
const GRASS_RADIUS := 100.0
const SPAWN_POINT := Vector3(0, 1, 0)

# Posições dos 8 pontos de missão (X, Y, Z)
const MISSION_POINTS := [
    Vector3(30, 0, 15),
    Vector3(-45, 0, 20),
    Vector3(60, 0, 45),
    Vector3(5, 0, 75),
    Vector3(-70, 0, -35),
    Vector3(-35, 0, -75),
    Vector3(88, 0, 15),
    Vector3(40, 0, -90),
]


func get_spawn_point() -> Vector3:
    return SPAWN_POINT


func get_mission_points() -> Array:
    return MISSION_POINTS


func _ready() -> void:
    _build_ocean()
    _build_island()
    _build_roads()
    _build_city()
    _build_houses()


# ---------------------------------------------------------------- helpers
func _mat(color: Color) -> StandardMaterial3D:
    var m := StandardMaterial3D.new()
    m.albedo_color = color
    return m


func _add_box(pos: Vector3, size: Vector3, color: Color, collide := true) -> void:
    var mesh := MeshInstance3D.new()
    var bm := BoxMesh.new()
    bm.size = size
    mesh.mesh = bm
    mesh.material_override = _mat(color)
    if collide:
        var body := StaticBody3D.new()
        body.position = pos
        var cs := CollisionShape3D.new()
        var shape := BoxShape3D.new()
        shape.size = size
        cs.shape = shape
        body.add_child(cs)
        body.add_child(mesh)
        add_child(body)
    else:
        mesh.position = pos
        add_child(mesh)


# ------------------------------------------------------------ construção
func _build_ocean() -> void:
    var ocean := MeshInstance3D.new()
    var pm := PlaneMesh.new()
    pm.size = Vector2(1000, 1000)
    ocean.mesh = pm
    ocean.material_override = _mat(Color(0.1, 0.4, 0.75))
    ocean.position.y = -1.0
    add_child(ocean)


func _build_island() -> void:
    # Base de areia, com colisão (topo em y = 0)
    var body := StaticBody3D.new()
    body.position = Vector3(0, -1.5, 0)
    var cs := CollisionShape3D.new()
    var shape := CylinderShape3D.new()
    shape.radius = ISLAND_RADIUS
    shape.height = 3.0
    cs.shape = shape
    body.add_child(cs)
    var sand := MeshInstance3D.new()
    var sm := CylinderMesh.new()
    sm.top_radius = ISLAND_RADIUS
    sm.bottom_radius = ISLAND_RADIUS
    sm.height = 3.0
    sm.radial_segments = 64
    sand.mesh = sm
    sand.material_override = _mat(Color(0.9, 0.82, 0.55))
    body.add_child(sand)
    add_child(body)

    # Camada de grama por cima (só visual)
    var grass := MeshInstance3D.new()
    var gm := CylinderMesh.new()
    gm.top_radius = GRASS_RADIUS
    gm.bottom_radius = GRASS_RADIUS
    gm.height = 0.02
    gm.radial_segments = 64
    grass.mesh = gm
    grass.material_override = _mat(Color(0.35, 0.65, 0.3))
    grass.position.y = 0.01
    add_child(grass)


func _build_roads() -> void:
    var road_color := Color(0.2, 0.2, 0.22)
    _add_box(Vector3(0, 0.03, 0), Vector3(GRASS_RADIUS * 2, 0.02, 10), road_color, false)
    _add_box(Vector3(0, 0.03, 0), Vector3(10, 0.02, GRASS_RADIUS * 2), road_color, false)


func _build_city() -> void:
    # Bairro de prédios no nordeste da ilha
    var rng := RandomNumberGenerator.new()
    rng.seed = 1234
    for i in 5:
        for j in 5:
            var x := 20.0 + 14.0 * i
            var z := -20.0 - 14.0 * j
            var w := rng.randf_range(7.0, 10.0)
            var d := rng.randf_range(7.0, 10.0)
            var h := rng.randf_range(6.0, 30.0)
            var color := Color.from_hsv(rng.randf_range(0.5, 0.7), 0.15, rng.randf_range(0.55, 0.85))
            _add_box(Vector3(x, h / 2.0, z), Vector3(w, h, d), color)


func _build_houses() -> void:
    # Casinhas baixas no sudoeste
    for i in 3:
        for j in 3:
            var x := -30.0 - 12.0 * i
            var z := 30.0 + 12.0 * j
            _add_box(Vector3(x, 2.0, z), Vector3(6, 4, 6), Color(0.95, 0.6, 0.4))
