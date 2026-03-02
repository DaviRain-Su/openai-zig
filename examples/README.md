# Examples

Simple examples demonstrating the SDK usage.

Config: `config/config.toml` with
```toml
api_key = "sk-..."
base_url = "https://api.deepseek.com/v1"
```

Environment overrides are also supported (priority: env vars override TOML):
- `OPENAI_API_KEY`, `DEEPSEEK_API_KEY`
- `OPENAI_BASE_URL`, `DEEPSEEK_BASE_URL`
- `OPENAI_MODEL`, `DEEPSEEK_MODEL`
- `OPENAI_ORGANIZATION`, `OPENAI_PROJECT`
- `OPENAI_TIMEOUT_MS`, `OPENAI_MAX_RETRIES`, `OPENAI_RETRY_BASE_DELAY_MS`
- `DEEPSEEK_TIMEOUT_MS`, `DEEPSEEK_MAX_RETRIES`, `DEEPSEEK_RETRY_BASE_DELAY_MS`

- `models_list.zig` — list models.
- `chat_completion.zig` — create a chat completion.
- `chat_completion_raw.zig` — raw JSON chat completion request.
- `chat_completion_stream.zig` — stream chat completion delta chunks.
- `chat_list.zig` — list chat completions.
- `chat_multiturn.zig` — create multi-turn chat messages, including `prefix` continuation examples.
- `chat_prefix_completion.zig` — direct DeepSeek/Chat prefix completion (`prefix=true`) sample.
- `chat_json_extract.zig` — extract JSON via chat responses.
- `chat_thinking_mode.zig` — chat completion with reasoning/`thinking` mode and follow-up control.
- `assistants_list.zig` — list assistants with capability fallback.
- `files_list.zig` — list files.
- `embeddings_and_moderations.zig` — embeddings + moderations examples.
- `completions_stream.zig` — stream completions output.
- `completions_basic.zig` — basic `/completions` request with DeepSeek compatibility behavior.
- `fim_completion.zig` — FIM-style completion (`prompt` + `suffix`) via `/completions`.
- `fim_completion_stream.zig` — FIM-style streaming completion.
- `fim_completion_raw.zig` — raw JSON FIM completion request.
- `files_list_paged.zig` — manually paginate `files` list with cursor helpers.
- `files_list_auto_paged.zig` — automatically paginate `files` list with `auto_paginate_after`.
- `images_generation.zig` — generate images with basic request/response handling.
- `error_handling_and_options.zig` — show per-request options and `with_options` cloning behavior.
- `vector_stores_list.zig` — list vector stores with provider fallback.
- `audio_speech.zig` — request speech synthesis.
- `responses_basic.zig` — create a response and print raw result (provider fallback aware).
- `batch_basic.zig` — list batch jobs and fetch one batch detail with provider fallback handling.
- 分页一致性：
  - 标准分页列表响应应包含 `data`、`has_more`、`first_id`、`last_id`。
  - `has_more == true` 时再读取对应方向的游标：`after` 用 `last_id`，`before` 用 `first_id`。
