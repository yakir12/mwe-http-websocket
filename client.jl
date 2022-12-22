using Test
using ProgressMeter, HTTP
using HTTP: send, post, receive

n = 1000

@info "running client with $(Threads.nthreads()) threads"

##################### HTTP #######################

const header = ["Content-Type" => "application/octet-stream"]

function http_request()
    bytes = rand(UInt8, 5)
    resp = post("http://127.0.0.1:8081/http", header; body = bytes)
    @test resp.status == 200 && resp.body == reverse(bytes)
end

@info "testing multi-threaded http endpoint"
p = Progress(n)
Threads.@threads for i in 1:n
    http_request()
    next!(p)
end

#################### WebSocket ###################

function websocket_function(ws)
    # @info "I'm running on thread #$(Threads.threadid())"
    pkg = rand(UInt8, 10)
    send(ws, pkg)
    msg = receive(ws)
    @test reverse(pkg) == msg
    return 
end

@info "testing single-threaded websocket endpoint"
HTTP.WebSockets.open("http://127.0.0.1:8081/websocket") do ws
    @showprogress for i in 1:n
        websocket_function(ws)
    end
end

@info "testing multi-threaded single websocket endpoint"
HTTP.WebSockets.open("http://127.0.0.1:8081/websocket") do ws
    p = Progress(n)
    Threads.@threads for i in 1:n
        websocket_function(ws)
        next!(p)
    end
end

@info "testing single-threaded multiple websocket endpoints"
@showprogress for i in 1:n
    HTTP.WebSockets.open(websocket_function, "http://127.0.0.1:8081/websocket")
end

@info "testing multi-threaded multiple websocket endpoints"
p = Progress(n)
Threads.@threads for i in 1:n
    HTTP.WebSockets.open(websocket_function, "http://127.0.0.1:8081/websocket")
    next!(p)
end
