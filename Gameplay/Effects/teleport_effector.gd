class_name TeleportEffector
extends Effector

# TODO: only show one or the other
@export var destination_3d : Node3D
@export var destination_2d : Node2D

var destination : Node:
	get:
		if destination_3d:
			return destination_3d
		else:
			return destination_2d

# TODO: rotation?
# TODO: reparenting?
func apply_effect(target: Node) -> bool:
	if target is Node2D and destination_2d:
		target.global_position = destination_2d.global_position
		return true
	if target is Node3D and destination_3d:
		target.global_position = destination_3d.global_position
		return true
	push_warning("Could not teleport node %s (%s) to target %s (%s)" % [target.name, JamUtils.get_object_type_name(target), destination.name, JamUtils.get_object_type_name(destination)])
	return false

func remove_effect(target: Node) -> bool:
	# Teleportation is a one-off effect
	return false
