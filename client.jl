using HTTP, JSON3, ProgressMeter 
using Test

function http_request()
    resp = HTTP.get("http://127.0.0.1:8081/http")
    @test 0 ≤ JSON3.read(resp.body) ≤ 1
end

function websocket_request()
    HTTP.WebSockets.open("http://127.0.0.1:8081/websocket") do ws
        pkg = rand(UInt8, 10)
        HTTP.send(ws, pkg)
        msg = HTTP.receive(ws)
        @test reverse(pkg) == msg
    end
end

function requests()
    http_request()
    websocket_request()
end

@showprogress for i in 1:1000
    requests()
end

