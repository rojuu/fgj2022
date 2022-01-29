extends Control


onready var slot0: TextureRect = $StockWeapon0
onready var slot1: TextureRect = $StockWeapon1

func update_slot_texture(player, slot, idx):
	if len(player.weapon_queue) > idx:
		slot.texture = player.weapon_queue[idx].get_texture()
	else:
		slot.texture = null

func _process(delta):
	var player: Player = get_tree().get_nodes_in_group("Player")[0] as Player
	if player:
		update_slot_texture(player, slot0, 0)
		update_slot_texture(player, slot1, 1)
		

