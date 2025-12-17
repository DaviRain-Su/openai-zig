# OpenAI Zig SDK (skeleton)

This repo hosts an in-progress Zig SDK generated from `spec/openapi.documented.yml`. It currently ships a minimal runtime and a few implemented endpoints to validate the transport/JSON path.

## Status
- Implemented runtime: `src/transport/http.zig`, `src/errors.zig`, `src/client.zig`.
- Implemented resources: `models` (list/retrieve/delete), `files` (list/retrieve), `chat` (create_chat_completion JSON), plus stubs for other tags.
- Generator: `tools/generate.py` builds `generated/ir.json` and stub resources from the OpenAPI spec.
- Sample entrypoint: `src/main.zig` demonstrates models.list and chat.completions.

## Prerequisites
- Zig 0.15.x (matches the lib path in this environment).
- Place your API key in `config/api_key.txt` (single line, no quotes). Empty or invalid keys will return HTTP 401.

## Build and run
```sh
zig build          # compile
zig build run      # run the demo (models list + chat completion)
```

## Generator
```sh
python3 tools/generate.py  # reads spec/openapi.documented.yml, writes generated/ir.json and regenerates stub resources
```
Note: the generator will overwrite `src/resources/*.zig` stubs; avoid running it if you have manual edits in those files until merge logic is added.

## Next steps
- Expand generator to emit full request/response types and all operations.
- Flesh out runtime for multipart, streaming, retries, richer error mapping.
- Add tests covering JSON parse/stringify and a few core endpoints.
