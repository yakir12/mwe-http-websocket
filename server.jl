using HTTP, JSON3

header = ["Content-Type" => "text/json"]
body = JSON3.write(rand())

http_handler(request) = HTTP.Response(200, header; body)

function websocket_handler(stream)
    request = stream.message
    return WebSockets.upgrade(ws -> websocket_handler(request, ws), stream)
end

function websocket_handler(request, websocket)
    while !WebSockets.isclosed(websocket)
        bytes = WebSockets.receive(websocket)
        WebSockets.send(websocket, reverse(bytes))
    end
    return 
end

const ROUTER = HTTP.Router()
HTTP.register!(ROUTER, "/http", HTTP.streamhandler(http_handler))
HTTP.register!(ROUTER, "/websocket", websocket_handler)

server = HTTP.serve!(ROUTER; stream=true)

wait(server)
