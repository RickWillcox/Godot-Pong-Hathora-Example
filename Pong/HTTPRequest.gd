extends HTTPRequest

signal token_result(token) 

func _make_post_request(url, data_to_send, use_ssl):
	# Convert data to json string:
	var query = JSON.print(data_to_send)
	# Add 'Content-Type' header:
	var headers = ["Content-Type: application/json"]
	request(url, headers, use_ssl, HTTPClient.METHOD_POST, query)
		
func http_request():
	connect("request_completed", self, "_on_request_completed")
	var url = "https://rtag.dev/ae20be369f03a33fba96a395e8a17c0d8e31e53a0638cab836babb44683003c4/login/anonymous"
	var data : Dictionary = {}
	_make_post_request(url, data, true)

func _on_request_completed(result, response_code, headers, body):
	emit_signal("token_result", JSON.parse(body.get_string_from_utf8()).result["token"])

