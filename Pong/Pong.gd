extends Node2D

var token_result 

onready var http_request = get_node("Login/HTTPRequest")

export var websocket_url = "wss://rtag.dev/ae20be369f03a33fba96a395e8a17c0d8e31e53a0638cab836babb44683003c4"
# Our WebSocketClient instance
var _client = WebSocketClient.new()



func _ready():
	http_request.connect("token_result", self, "_on_received_token_result")

func _physics_process(delta):
	get_input()

func _on_Play_pressed():
	http_request.http_request()
	

	
	$Login.visible = false
	$Game.visible = true

#http

func _on_received_token_result(token : String):
	token_result = token
	connect_to_server_id()


#websocket	
func connect_to_server_id():
	_client.connect("connection_closed", self, "_closed")
	_client.connect("connection_error", self, "_closed")
	_client.connect("connection_established", self, "_connected")
	_client.connect("data_received", self, "_on_data")
	
	var err = _client.connect_to_url(websocket_url)
	if err != OK:
		print("Unable to connect")
		set_process(false)


func _closed(was_clean = false):
	# was_clean will tell you if the disconnection was correctly notified
	# by the remote peer before closing the socket.
	print("Closed, clean: ", was_clean)
	set_process(false)

func _connected(proto = ""):
	# This is called on connection, "proto" will be the selected WebSocket
	# sub-protocol (which is optional)
	print("Connected with protocol: ", proto)
	# You MUST always use get_peer(1).put_packet to send data to server,
	# and not put_packet directly when not using the MultiplayerAPI.
	_client.get_peer(1).set_write_mode(WebSocketPeer.WRITE_MODE_TEXT)
	_client.get_peer(1).put_packet(token_result.to_utf8())
	_client.get_peer(1).put_packet($Login/LineEdit.text.to_utf8())
#	var pba = PoolByteArray ([00, 99, 99, 99, 99])
#	_client.get_peer(1).put_packet(pba)
	_client.get_peer(1).set_write_mode(WebSocketPeer.WRITE_MODE_BINARY)

	
func _on_data():
	# Print the received packet, you MUST always use get_peer(1).get_packet
	# to receive data from server, and not get_packet directly when not
	# using the MultiplayerAPI.
	print("Got data from server: ", _client.get_peer(1).get_packet().get_string_from_utf8())

func _process(delta):
	# Call this in _process or _physics_process. Data transfer, and signals
	# emission will only happen when calling this function.
	_client.poll()

func get_input():
	randomize()
	var r1 = randi() % 255
	var r2 = randi() % 255
	var r3 = randi() % 255
	var r4 = randi() % 255
	var up_pba : PoolByteArray = ([00, r1, r2, r3, r4, 01])
	var down_pba : PoolByteArray = ([00, r1, r2, r3, r4, 02])
	var stop_pba : PoolByteArray = ([00, r1, r2, r3, r4, 00])
	if Input.is_action_pressed("Up"):
		print(up_pba)
		_client.get_peer(1).put_packet(up_pba)
		print("up")
	elif Input.is_action_pressed("Down"):
		_client.get_peer(1).put_packet(down_pba)
		print("down")
	else:
		_client.get_peer(1).put_packet(stop_pba)


