@tool
class_name CollisionCone3D
extends CollisionShape3D

@export_tool_button("Rebuild cone") var rebuid_func = _rebuild_cone

@export_range(0.01, 100.0, 0.01, "or_greater") var length : float = 1.0
@export_range(0.01, 100.0, 0.01, "or_greater") var radius : float = 0.5
@export_range(4, 100) var sides : int = 16
@export var mesh_node : MeshInstance3D = null

func _rebuild_cone() -> void:
	shape = ConvexPolygonShape3D.new()
	var cone := shape as ConvexPolygonShape3D
	var points : Array[Vector3]
	points.append(Vector3.ZERO)
	var step_angle : float = 2 * PI / sides
	for idx in range(sides):
		var point := Vector3.FORWARD * length + (Vector3.UP.rotated(Vector3.FORWARD, step_angle * idx)) * radius
		points.append(point)
	cone.points = points
	if mesh_node:
		var old_mesh = mesh_node.mesh
		var new_mesh = CylinderMesh.new()
		new_mesh.height = length
		new_mesh.top_radius = 0.0
		new_mesh.bottom_radius = radius
		new_mesh.radial_segments = sides
		new_mesh.material = old_mesh.surface_get_material(0)
		mesh_node.mesh = new_mesh
		mesh_node.position = Vector3.FORWARD * length / 2.0
