using HTTP, JSON3, ThreadPools

header = ["Content-Type" => "text/json"]
body = JSON3.write(rand())

http_handler(request) = HTTP.Response(200, header; body)

function websocket_handler(stream)
    request = stream.message
    return WebSockets.upgrade(ws -> websocket_handler(request, ws), stream)
end

function fun(bytes)
    @info "I'm running on thread #$(Threads.threadid())"
    return reverse(bytes)
end

function websocket_handler(request, websocket)
    for bytes in websocket
        # tsk = Threads.@spawn fun(bytes)
        tsk = spawnbg() do
            fun(bytes)
        end
        WebSockets.send(websocket, fetch(tsk))
    end
end

const ROUTER = HTTP.Router()
HTTP.register!(ROUTER, "/http", HTTP.streamhandler(http_handler))
HTTP.register!(ROUTER, "/websocket", websocket_handler)

server = HTTP.serve!(ROUTER; stream=true)

@info "running server with $(Threads.nthreads()) threads"

wait(server)
