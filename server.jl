using HTTP
using HTTP: Response, register!

const ROUTER = HTTP.Router()

server = HTTP.serve!(ROUTER; stream=true)

@info "running server with $(Threads.nthreads()) threads"

##################### HTTP #######################

const header = ["Content-Type" => "application/octet-stream"]

function async_middleware(handler)
    function (req)
        tsk = Threads.@spawn handler(req)
        return fetch(tsk)
    end
end

function expensive_function(bytes)
    @info "I'm running on thread #$(Threads.threadid())"
    return reverse(bytes)
end

function handler(request)
    bytes = request.body
    body = expensive_function(bytes)
    Response(200, header; body)
end

register!(ROUTER, "/http", handler |> async_middleware |> HTTP.streamhandler)

#################### WebSocket ###################

function websocket_handler(stream)
    request = stream.message
    return WebSockets.upgrade(ws -> websocket_handler(request, ws), stream)
end

function websocket_handler(request, websocket)
    for bytes in websocket
        tsk = Threads.@spawn expensive_function(bytes)
        WebSockets.send(websocket, fetch(tsk))
    end
end

register!(ROUTER, "/websocket", websocket_handler)

wait(server)
