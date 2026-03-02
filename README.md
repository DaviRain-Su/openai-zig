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
  - `DEEPSEEK_BASE_URL`, `DEEPSEEK_MODEL`, `DEEPSEEK_TIMEOUT_MS`, `DEEPSEEK_MAX_RETRIES`, `DEEPSEEK_RETRY_BASE_DELAY_MS`
  `api_key` is required for live calls; `base_url` defaults to DeepSeek if omitted.

### Runtime/config precedence

- `config.load()` resolves each field in this order:
  - Environment variable override
  - TOML file field
  - Built-in default (for `base_url`, `model`, retry settings, and timeout)
- For credentials and routing fields, supported env keys are:
  - `OPENAI_API_KEY`, `DEEPSEEK_API_KEY`
  - `OPENAI_BASE_URL`, `DEEPSEEK_BASE_URL`
  - `OPENAI_MODEL`, `DEEPSEEK_MODEL`
  - `OPENAI_ORGANIZATION`, `OPENAI_PROJECT`
  - `OPENAI_TIMEOUT_MS`, `OPENAI_MAX_RETRIES`, `OPENAI_RETRY_BASE_DELAY_MS`
  - `DEEPSEEK_TIMEOUT_MS`, `DEEPSEEK_MAX_RETRIES`, `DEEPSEEK_RETRY_BASE_DELAY_MS`
- `OPENAI_*` keys are checked before `DEEPSEEK_*` keys for each field.

### DeepSeek `/beta` compatibility notes

- Some DeepSeek endpoints (for example legacy `/completions` in some accounts) require the `/beta` base path.
- The transport automatically switches DeepSeek requests for `/completions` to `.../beta` when `base_url` contains `api.deepseek.com`.
- You can also force it explicitly per request with `RequestOptions.base_url`:

```zig
const opts: sdk.transport.Transport.RequestOptions = .{
    .base_url = "https://api.deepseek.com/beta",
};

try client.completions().create_completion_with_options(
    allocator,
    .{
        .model = "deepseek-chat",
        .prompt = "hello",
        .stream = true,
    },
    opts,
);
```

### Client init / with_options behavior

- `initClient` / `init` creates a new client with fully isolated transport state; option values are copied into owned transport buffers.
- `withOptions` and `with_options` return a new cloned client, inheriting unspecified values from the source client and replacing only explicitly provided fields.
- Typical pattern:
  - `base = init(...)` -> `runtime = try base.with_options(..., .{ .timeout_ms = 1000 })`
  - The returned client is useful for scoped configuration and does not mutate `base`.

## Build and run
```sh
zig build          # compile
zig build run      # run the demo (models list + chat completion)
zig build -Dexamples=true run-examples  # build + run example binaries
bash scripts/check-op-coverage.sh     # verify operation coverage against generated/ir.json
```

## Examples
- `examples/models_list.zig` — list available models
- `examples/chat_completion.zig` — single chat completion call
- `examples/chat_completion_stream.zig` — chat completion stream
- `examples/chat_list.zig` — list chat completion objects
- `examples/chat_multiturn.zig` — multi-turn chat continuation
- `examples/chat_json_extract.zig` — function-like structured chat output demo
- `examples/files_list.zig` — list files
- `examples/assistants_list.zig` — assistants list with fallback handling
- `examples/embeddings_and_moderations.zig` — embeddings + moderations call path
- `examples/completions_stream.zig` — completions stream wrapper
- `examples/completions_basic.zig` — completions call (legacy completion endpoint) with DeepSeek `/beta` compatibility
- `examples/responses_basic.zig` — responses API baseline sample
- `examples/batch_basic.zig` — batch list/detail sample
- `examples/files_list_paged.zig` — manual pagination helper
- `examples/files_list_auto_paged.zig` — auto pagination helper
- `examples/audio_speech.zig` — speech synthesis
- `examples/vector_stores_list.zig` — list vector stores
- `examples/images_generation.zig` — images generation baseline sample
- `examples/error_handling_and_options.zig` — per-request options and clone behavior

## Generator
```sh
python3 tools/generate.py  # reads spec/openapi.documented.yml, writes generated/ir.json and regenerates stub resources
```
Note: the generator will overwrite `src/resources/*.zig` stubs; avoid running it if you have manual edits in those files until merge logic is added.

## Next steps
- Expand generator to emit full request/response types and all operations.
- Flesh out runtime for multipart, streaming, retries, richer error mapping.
- Add tests covering JSON parse/stringify and a few core endpoints.
