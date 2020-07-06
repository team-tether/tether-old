
extends Control

func _on_host_pressed():
	Network.on_host_game()

func _on_join_pressed():
	var ip = get_node("Address").get_text()
	if (not ip.is_valid_ip_address()):
		return
	Network.on_join_game(ip)
