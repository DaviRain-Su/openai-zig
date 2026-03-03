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

- The transport applies provider-aware rewrites for DeepSeek-compatible base URLs (base URL containing `deepseek`):
  - `POST /completions` and `GET /completions` are rewritten to `<base>/beta`.
  - `POST /chat/completions` is rewritten to `<base>/beta` only when the last message is
    `{"role":"assistant", "prefix": true}`.
  - `/beta` is normalized idempotently (no duplicated `/beta` suffix is added).
- This behavior applies in all normal request paths and request-with-options calls.

### Provider support matrix (practical)

- Stable under OpenAI/compatible endpoints:
  - `models`, `chat`, `completions`, `files`, `images`, `embeddings`, `moderations`, `responses`, `audio`, `vector_stores`
- DeepSeek-compatible routes with SDK auto-adjustment:
  - `/completions*` automatically switches to `/beta` when base URL contains DeepSeek
  - `/chat/completions` switches to `/beta` when last message has `prefix: true`
- DeepSeek-specific endpoints/examples:
  - `user_balance` (`/user/balance`) supported via explicit example (`user_balance`)
- Provider mismatch handling in SDK/examples:
  - Unsupported endpoints generally return SDK errors (e.g. `NotFoundError` / `HttpError`) and examples print skip logs instead of aborting the whole run.
  - Stream fallback examples include non-stream fallback and `/DeepSeek` guards to reduce truncated output risk.

Examples:

- `https://api.deepseek.com/v1 + /completions` -> `https://api.deepseek.com/beta`
- `https://api.deepseek.com/v1 + /completions?stream=true` -> `https://api.deepseek.com/beta`
- `https://api.deepseek.com/v1 + /chat/completions` (without assistant prefix) -> `https://api.deepseek.com/v1`
- `https://api.deepseek.com/v1 + /chat/completions` (assistant `prefix=true` last message) -> `https://api.deepseek.com/beta`

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
zig build -Dexamples=true run-examples  # build + run example binaries (auto-skip when no API key)
zig build -Dexamples=true -Drun_examples_without_key=true run-examples  # force-run examples without API key
zig build -Dexamples=true -Dexamples_filter=chat_completion,models_list run-examples  # run selected examples only
bash scripts/check-op-coverage.sh     # verify operation coverage against generated/ir.json
```

`run-examples` key behavior:
- If neither `OPENAI_API_KEY` nor `DEEPSEEK_API_KEY` is set, `run-examples` now skips gracefully with a single warning line.
- Use `-Drun_examples_without_key=true` to force running all example binaries even without API keys.
- Use `-Dexamples_filter=name1,name2` to run only specific examples by name.

## Examples
- `examples/models_list.zig` — list available models
- `examples/chat_completion.zig` — single chat completion call
- `examples/chat_completion_raw.zig` — raw JSON chat completion request demo
- `examples/chat_thinking_mode.zig` — chat completion with DeepSeek thinking/reasoning fields
- `examples/chat_completion_stream.zig` — chat completion stream
- `examples/chat_list.zig` — list chat completion objects
- `examples/chat_multiturn.zig` — multi-turn chat continuation
- `examples/chat_prefix_completion.zig` — chat prefix completion (`prefix=true`) sample
- `examples/chat_tool_calls.zig` — chat tool call sample with `tools` + `tool_choice` request + response parsing
- `examples/chat_json_extract.zig` — function-like structured chat output demo
- `examples/chat_json_mode.zig` — strict JSON-mode chat completion demo (`json_object` / `json_schema`)
- `examples/files_list.zig` — list files
- `examples/assistants_list.zig` — assistants list with fallback handling
- `examples/embeddings_and_moderations.zig` — embeddings + moderations call path
- `examples/completions_stream.zig` — completions stream wrapper
- `examples/completions_basic.zig` — completions call (legacy completion endpoint) with DeepSeek `/beta` compatibility
- `examples/fim_completion.zig` — FIM-style completion (`prompt` + `suffix`) via `/completions`
- `examples/fim_completion_stream.zig` — FIM-style streaming completion with fallback completion fallback
- `examples/fim_completion_raw.zig` — raw JSON FIM completion request via `/completions`
- `examples/responses_basic.zig` — responses API baseline sample
- `examples/batch_basic.zig` — batch list/detail sample
- `examples/files_list_paged.zig` — manual pagination helper
- `examples/files_list_auto_paged.zig` — auto pagination helper
- `examples/audio_transcription.zig` — transcribe local audio file with file-path helper
- `examples/audio_translation.zig` — translate local audio file with file-path helper
- `examples/audio_speech.zig` — speech synthesis
- `examples/user_balance.zig` — query DeepSeek account balance via `/user/balance` with provider compatibility handling
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
