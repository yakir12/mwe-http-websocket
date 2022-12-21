This stress-tests http and websocket endpoints in `HTTP.jl`.

When the number of threads for the server is smaller than the number of client threads, then a `IOError: read: connection reset by peer (ECONNRESET)` is encountered:
```
julia --threads=2 --project=. server.jl & julia --threads=3 --project=. client.jl
```
(don't forget to `pkill julia`), But when the number of threads the client has is smaller than that of the server, then this usually works fine:
```
julia --threads=3 --project=. server.jl & julia --threads=2 --project=. client.jl
```
