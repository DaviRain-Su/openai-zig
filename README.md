# OpenAI Zig SDK (skeleton)

This repo hosts an in-progress Zig SDK generated from `spec/openapi.documented.yml`. It currently ships a minimal runtime and a few implemented endpoints to validate the transport/JSON path.

## Status
- Implemented runtime: `src/transport/http.zig`, `src/errors.zig`, `src/client.zig`.
- Implemented resource wrappers for the generated OpenAPI operation surface in `src/resources/*.zig` (all operations present according to `generated/ir.json`).
- Streaming support: `chat.create_chat_completion_stream` parses SSE chunks and calls an event callback per streamed chunk.
- Generator: `tools/generate.py` builds `generated/ir.json` and stub resources from the OpenAPI spec.
- Sample entrypoint: `src/main.zig` demonstrates models.list and chat.completions.

## Prerequisites
- Zig 0.15.x (matches the lib path in this environment).
- Config is read from `config/config.toml`:
  ```toml
  api_key = "sk-..."
  base_url = "https://api.deepseek.com/v1"
  model = "deepseek-chat"
  # organization = "org-id"
  # project = "project-id"
  # timeout_ms = 30000
  # max_retries = 3
  # retry_base_delay_ms = 500
  ```
  Env var fallback is supported:
  - `OPENAI_API_KEY`, `DEEPSEEK_API_KEY`
  - `OPENAI_BASE_URL`, `OPENAI_MODEL`
  - `OPENAI_ORGANIZATION`, `OPENAI_PROJECT`
  - `OPENAI_TIMEOUT_MS`, `OPENAI_MAX_RETRIES`, `OPENAI_RETRY_BASE_DELAY_MS`
  `api_key` is required for live calls; `base_url` defaults to DeepSeek if omitted.

## Build and run
```sh
zig build          # compile
zig build run      # run the demo (models list + chat completion)
zig build -Dexamples=true run-examples  # build + run example binaries
bash scripts/check-op-coverage.sh     # verify operation coverage against generated/ir.json
```

## Examples
- `examples/models_list.zig`
- `examples/chat_completion.zig`
- `examples/chat_completion_stream.zig`
- `examples/chat_list.zig`
- `examples/files_list.zig`
- `examples/audio_speech.zig`

## Generator
```sh
python3 tools/generate.py  # reads spec/openapi.documented.yml, writes generated/ir.json and regenerates stub resources
```
Note: the generator will overwrite `src/resources/*.zig` stubs; avoid running it if you have manual edits in those files until merge logic is added.

## Next steps
- Expand generator to emit full request/response types and all operations.
- Flesh out runtime for multipart, streaming, retries, richer error mapping.
- Add tests covering JSON parse/stringify and a few core endpoints.
