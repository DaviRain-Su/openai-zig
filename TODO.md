# OpenAI Zig SDK 对齐清单（对照 openai-python）

目标：基于 `openai-python` 的使用语义，逐步把当前实现补齐到完整可用能力。

## 0. 当前状态快照（已确认）
- `scripts/check-op-coverage.sh` 通过，operation wrapper 覆盖已到位。
- `zig build` / `zig build test` / `zig build -Dexamples=true run-examples` 均可运行。
- 关键 example 已通过 Zig 0.15 兼容编译验证：`run-chat_completion`、`run-chat_completion_stream`、`run-examples` 组执行已通过编译并到达请求响应。
- 当前更多是“功能覆盖存在”，但未完全达到 `openai-python` 运行时行为一致性与完整开发体验。

## 1. 优先级 P0（第一优先）

### 1.1 Runtime / Transport 统一能力
- [x] 完善 `request` 与 `requestStream` 的统一配置语义（global + per-client + per-request）。
- [x] 统一 `RequestOptions` 支持：`timeout_ms / max_retries / retry_base_delay_ms / extra_headers`。
- [x] 重试语义落地：指数退避、`Retry-After` 合并、`max_retries=0` 正常工作。
- [x] 确认 `proxy/api_key/organization/project` 等配置变更/克隆时内存释放无泄漏。
- [x] 将 `withOptions` 与 `with_options` 的行为对齐。

### 1.2 错误模型与可观测性
- [x] 统一错误分类映射（400/401/403/404/409/422/429/5xx）。
- [x] 错误路径中保留 `status`、`body`、`request_id`、`code`、`type`、`param`、`message`（通过增强日志/解析行为）。
- [x] 调试/日志输出包含可观测字段（不影响返回值解码）。
- [x] 保留兼容 `errors.Error` 的同时，提供更丰富的错误详情入口（`parseApiError`）。
- [x] 修复错误日志对非 UTF-8 响应体的直接 `{s}` 打印，改为安全降级输出，避免示例在异常响应下崩溃。

### 1.3 资源方法行为一致性（兼容别名）
- [x] 核对核心资源函数命名与 `openai-python` 常见别名（如 `create/retrieve/list/delete` 与具体方法名）基本一致，并补齐 `chat`、`completions`、`models`、`files`、`images`、`responses` 的核心别名。
- [x] 保持 `payload`/可选参数语义，减少 `null` 与“未传”差异。
  - [x] 已将若干别名/默认 `with_options` 调用改为传 `null`（如 `chat`、`realtime` 的包装方法），避免显式空 request options 与默认行为混淆。
  - [x] 已将 `sendJsonTyped` 与各关键流式/语音/会话 multipart 辅助路径的 JSON 序列化默认改为 `emit_null_optional_fields = false`，默认不发送可选字段的 `null`。
  - [x] 已增加 `chat`/`completions` 的本地序列化回归测试，直接验证可选字段在 JSON 发送阶段被省略。
  - [x] 已补齐 `audio.create_speech` 与 `responses.count_input_tokens` 的本地序列化回归测试，验证可选字段 null/未传差异一致。
- [x] 确认 `chat`/`completions` 等核心路径行为优先对齐。

## 2. 优先级 P1（第二优先）

### 2.1 资源通用化（减少重复实现）
- [x] 将各资源中的发送逻辑统一到 `common` 的 `sendJsonTypedWithOptions` / `sendNoBodyTypedWithOptions`（逐步推进）。
  - [x] 已统一 `default/audio/files/videos/vector_stores` 中二进制返回分支到 `common.sendBinaryWithOptions`，去除手写 `transport.requestWithOptions`。
  - [x] `realtime` 的 `/realtime/calls` 二进制请求已改为复用 `common.sendBinaryWithOptions`，保留 SDP multipart 等定制构建逻辑。
  - [x] `realtime` 的 `sendNoBodyValueOrNullWithOptions` 已抽象为 `common.sendValueOrNullWithOptions`，保留空体返回 `null` 行为。
  - [x] 已完成 `chat.update_chat_completion` 的 raw JSON 分支统一到 `common.sendRawJsonTypedWithOptions`（其余同类手写分支持续处理）。
  - [x] `fine_tuning`：已补齐 `send...WithOptions` 与方法级 `*_with_options`。
  - [x] `projects`：已补齐 `send...WithOptions` 与方法级 `*_with_options`。
  - [x] `default`：已统一请求发送入口，补齐核心与 alias 的 `*_with_options`。
  - [x] `audio`：已统一发送辅助函数，补齐可选 `request_opts` 与 `*_with_options` 透传。
  - [x] `usage`：已统一 `*_with_options` 与可选 `request_opts` 约束。
- [x] 统一 query 构建/URL 编码逻辑（分页字段 `limit/after/before/order` 等）。
- [x] 批量接入 `request options` 到核心资源方法：`chat`、`completions`、`models`、`files`、`images`、`responses`、`audio`、`embeddings`、`moderations`、`batch`、`users`、`groups`、`group_users`、`invites`、`user_role_assignments`、`group_role_assignments`、`project_user_role_assignments`、`project_group_role_assignments`、`roles`、`project_groups`、`certificates`。
  - [x] 已统一上述资源 `*_with_options` 的 `request_opts` 为可空参数（`?RequestOptions`），兼容无 options 调用。

### 2.2 流式能力统一
- [x] 抽象 SSE/parsing 工具，统一 `text/event-stream` 处理。
- [x] 统一 `[DONE]` 终止行为，新增 `common` 级别 done 回调并在例子里可观测流式终止状态，保留回调错误透传。
- [x] 逐步补齐支持流式的 endpoint。
  - [x] 已为 `responses` 增加 `create_response_stream` / `create_response_stream_with_options` + `create_with_options_stream`，统一使用 `common.sendStreamTypedWithOptions`。
  - [x] 已为 `completions` 增加 `create_completion_stream` / `create_completion_stream_with_options` / `create_completion_stream_with_options_and_done` / `create_stream` / `create_with_options_stream`，统一使用 `common.sendStreamTypedWithDoneWithOptions` 进行 `[DONE]` 通知。
  - [x] 已修复 `completions` 与 `chat` 的 `*_stream_raw` 别名链路中 `request_opts` 未透传到最终发送层的问题。
  - [x] 已新增 `examples/completions_stream.zig` 示例并接入 `run-examples`。
  - [x] 已为 `responses` 增加 `create_response_stream` / `create_response_stream_with_options` + `create_with_options_stream`，统一使用 `common.sendStreamTypedWithOptions`。
  - [x] 已修复 `chat` raw 流式接口参数回归问题，`run-chat_completion_stream` 与 `run-examples` 能成功编译通过。
  - [x] 已增强 SSE 解析器：在 `StreamEventParser.flush` 时对有事件却未收到 `[DONE]` 的流自动触发 done 回调，减少部分供应商误判为未完成导致 fallback 的情况。

### 2.3 文件与多部分请求
- [x] 统一 multipart 构建流程（边界、字段、content-type）。
  - [x] 已将 `files` 的 multipart 构建抽离为 `common.MultipartBuilder`，统一 boundary/字段写入与 footer 行为。
  - [x] 已为 `files.create_file` 接入公共 `common.sendMultipartTypedWithOptions`，减少重复。
  - [x] 已将 `default/audio/videos/certificates/uploads` 的 multipart 发送路径改为公共 `common.sendMultipartTypedWithOptions`，并保持 `request_opts` 行为一致透传。
  - [x] 已将 `images` 的 `create_image_edit` / `create_image_variation` 复用公共 `common.sendMultipartTypedWithOptions`。
- [x] 支持文件上传场景中的常见元数据参数（如 `purpose`）。
  - [x] 已新增 `files.create_file_from_path` / `create_file_from_path_with_options`，可直接按 `file_path + purpose` 构建 multipart。
- [x] 最小化内存复制（可后续引入更高效实现）。
  - [x] 已移除流式解析器的 `chunk` 冗余缓存复制；`readResponseBody` 直接使用持久分配器组装并返回响应体，减少一次中间缓冲拷贝。

### 2.4 开发体验与回归
- [x] 已修复 Zig 0.15 兼容性问题（`ArrayList` allocator 生命周期、示例编译路径）并更新回归文档。
- [x] 统一 `std.json.parseFromSlice` 的解析策略为 `alloc_always`，修复响应体释放后模型/列表示例中出现的悬空字符串引用和运行时崩溃。

## 3. 优先级 P2（第三优先）

### 3.1 分页体验
- [x] 实现自动分页工具（可选，不改 breaking change）：
  - [x] 手动分页器（`after/before/limit`）。
    - [x] 已新增 `src/pagination.zig` 与 `examples/files_list_paged.zig`，提供 `has_more/next cursor` 的手动分页入口示例。
  - [x] 自动分页迭代（可选）。
    - [x] 已新增 `src/pagination.zig` 自动分页入口 `auto_paginate_after` 与 `auto_paginate_before`，并补充 `examples/files_list_auto_paged.zig`。
- [x] 提供分页返回字段一致性检查与文档示例。

### 3.2 返回模型完整性
- [x] 对齐高频模型字段与 `openai-python` 行为（chat/create response、assistants/runs/messages、vector stores、files 等）。
  - [x] 增加高频返回模型 `ignore_unknown_fields` 兼容性回归测试（`ListModelsResponse`、`ListFilesResponse`、`CreateModerationResponse`）。
  - [x] 新增 `ListAssistantsResponse` 与 `ThreadObject` 的 `ignore_unknown_fields` 回归测试。
  - [x] 新增 `ListMessagesResponse`、`ListRunStepsResponse`、`ListVectorStoreFilesResponse`、`ListVectorStoresResponse` 的 `ignore_unknown_fields` 回归测试，并补齐对应 `generated/types.zig` 结构体定义。
  - [x] 新增 `CreateChatCompletionResponse` 与 `ChatCompletionList` 的结构体定义，并补齐 `ignore_unknown_fields` 回归测试。
  - [x] 修复 `CreateChatCompletionResponse` 中 `ChatCompletionResponseMessage` 可选字段的默认值问题，避免 DeepSeek 响应下游路径 `MissingField` 反序列化失败。
  - [x] 缺失字段补齐，保持 `ignore_unknown_fields = true` 兜底。
  - [x] 新增 `OpenAIFile` 与 `ListBatchesResponse` 缺省字段解析回归测试。
  - [x] 新增 `CreateCompletionResponse`、`CreateEmbeddingResponse`、`ImagesResponse` 的回归测试，覆盖高频返回模型在 extra 字段与可选字段场景下的兼容。
  - [x] 补充 `CompletionUsage` 的 DeepSeek 兼容字段（如 `prompt_cache_hit_tokens` / `prompt_cache_miss_tokens`）并增加对应回归测试。
  - [x] 新增 `ListRunsResponse` 与 `RunObject` 回归测试，覆盖助理运行列表与运行体的未知字段与空值兼容。
  - [x] 新增 `ListPaginatedFineTuningJobsResponse`、`ListFineTuningJobEventsResponse` 回归测试，覆盖微调任务列表与事件在未知字段场景下的兼容。
  - [x] 新增 `ListRunStepsResponse`、`RunStepObject`、`FineTuningJob`、`FineTuningJobCheckpoint` 的容错回归测试，覆盖高频响应对象未知字段场景。
  - [x] 新增 `VectorStoreSearchResultsPage`、`VectorStoreFileContentResponse`、`ListFineTuningJobCheckpointsResponse` 的回归测试，覆盖向量与微调分页列表兼容场景。
- [x] 扩展 `chat.create_chat_completion` 请求参数与 `StreamResponseDelta` 覆盖度：新增 `top_p`、`frequency_penalty`、`presence_penalty`、`stop`、`tools`、`tool_choice`、`stream_options`、`logprobs`、`n`、`reasoning_content` 等字段在本地结构体层面的可用性。
- [x] 增加 `chat.create_chat_completion_raw`/`create_chat_completion_raw_with_options` 及对应 stream raw 方法，提供 `std.json.Value` 的透传入口用于 docs/测试用例中完整请求体字段覆盖。
- [x] 增加 `completions.create_completion_raw` 与 `completions.create_completion_stream_raw` 透传入口（含 with_options 与流式 raw 别名），用于 `/completions` 在 DeepSeek 等兼容提供商下保留非标准字段。
- [x] 增加 `chat` 请求兼容扩展字段（`functions`、`function_call`、`logit_bias`、`modalities`、`audio`、`store`、`prediction`）与序列化回归测试，便于兼容 DeepSeek/OpenAI chat completion 的老接口参数。
- [x] 增加 Chat 消息级 `prefix` 字段（DeepSeek 前缀续写）与序列化回归测试。
- [x] 新增 `examples/chat_completion_raw.zig`，展示原始 JSON 请求体（含额外字段）到 `chat/create` 的透传示例，并纳入 `run-examples` 示例列表。
  - [x] 增强 `ChatMessage` 的序列化能力：支持 `content` 普通字符串与 `content_json` 复杂内容（如多模态 content 数组）并通过自定义 `jsonStringify` 序列化为同名 `content`，补充 `content_json` 回归测试。

### 3.3 配置层和开发体验
- [x] 统一环境变量优先级文档（`OPENAI_*` / `DEEPSEEK_*`）。
- [x] 文档化 `Client.init` 与 `Client.withOptions/with_options` 行为。
- [x] 明确 base_url、组织/项目 id 的默认来源与覆盖规则。

## 4. 优先级 P3（完善）

### 4.1 示例与文档
- [x] 增加错误处理、流式、分页、文件上传案例。
- [x] 完善 `examples/completions_stream.zig`：DeepSeek 环境下按需切换 `base_url=https://api.deepseek.com/beta`，避免 `/completions` 在 `/v1` 返回 400 的误判。
- [x] 补齐 DeepSeek 兼容层示例行为：对 `assistants`、`files`、`chat/list`、`images`、`embeddings`、`moderations`、`responses`、`batch`、`audio/speech`、`vector_stores` 等非公开能力，示例在 DeepSeek 模式下直接跳过并输出明确原因，避免误判为 SDK 错误。
- [x] 补齐每个核心资源示例（最少 1~2 个）。
  - [x] 新增 `examples/completions_basic.zig`，补充 legacy `/completions` 非流式调用；该示例依赖 transport 的自动 `/completions -> /beta` 兼容，避免重复手工 base 覆盖。
- [x] 深度兼容 DeepSeek 的 `beta` 约定：为 `Path=/completions` 的调用自动切换到 `.../beta`，无需调用方手工拼接 base_url；仍支持通过 `create_completion_with_options(..., .{ .base_url = "https://api.deepseek.com/beta" })` 显式覆盖。
  - [x] 在 `README` 与 `completions_stream` 示例中补充了显式 `/beta` 覆盖示例，避免出现 `/completions` 在 DeepSeek 下的兼容性误判。
  - [x] 扩展为 `chat/completions` 的 `messages[].prefix=true` 场景自动转发到 `.../beta`。
  - [x] 新增 `examples/responses_basic.zig`：补充 `responses` 资源的基本调用与 provider 降级示例。
  - [x] 新增 `embeddings_and_moderations` 示例：覆盖 `embeddings` 与 `moderations` 核心调用形态。
  - [x] 新增 `assistants_list.zig`：补充 `assistants` 列表示例与 provider 降级处理。
  - [x] 新增 `batch_basic.zig`：补充 `batch` 列表与详情调用示例（404 降级处理）。
  - [x] 新增 `images_generation.zig`：补充 `images` 资源基础调用示例（provider 降级处理）。
  - [x] 新增 `vector_stores_list.zig`：补充 `vector_stores` 列表示例（provider 降级处理）。
- [x] `examples/chat_completion.zig` 已统一到 `client.chat().create_chat_completion` 标准高层调用路径。
- [x] `examples/chat_multiturn.zig` 避免了对返回对象直接 stringify，改为安全字段级输出，修复运行时 UTF-8 崩溃。
- [x] `examples/chat_multiturn.zig` 新增 `messages[].prefix` 多轮续写示例（兼容 DeepSeek `prefix` 续写能力）。
- [x] `examples/models_list.zig` 改为字段级安全输出，避免 `Model` 为 `std.json.Value` 时 stringify 出现异常二进制片段。
- [x] `examples/chat_completion_stream.zig` 与 `examples/completions_stream.zig` 增加递归文本提取与非完整流回退（在无有效流片段时补齐非流请求）。
- [x] `examples/chat_completion_stream.zig` 与 `examples/completions_stream.zig` 新增流式分片增量输出去重：当供应商返回“累积文本”而非增量 token 时，仅打印新增片段，避免重复内容。
- [x] 完善 `examples/completions_stream.zig`：加入 `done` 信号检测，与 `fallback` 联动，降低流式未完整输出导致截断的场景。
- [x] `examples/completions_stream.zig` 修复流式事件抽取：不再因 `text` 字段存在而跳过 `delta` 解析，避免某些供应商返回双字段导致内容丢失。
- [x] `examples/completions_stream.zig` 与 `examples/chat_completion_stream.zig` 放宽回退触发：无 `done` 信号但有事件返回时，会走非流式补齐，减少“流式返回片段截断”。
- [x] `examples/completions_stream.zig` 与 `examples/chat_completion_stream.zig` 增加 `saw_finish_reason` 回退维度：若事件链未带 `finish_reason` 则自动触发非流式补齐，增强 DeepSeek 兼容场景下的完整性保障。
- [x] `examples/completions_stream.zig` 与 `examples/chat_completion_stream.zig` 改为缓存流式文本并在最终输出，避免 DeepSeek 兼容场景下“部分流式输出 + 非流式补齐”重复内容。
- [x] `examples/completions_stream.zig` 增加 `reasoning` / `reasoning_content` 流式字段抽取，并独立打印，配合 DeepSeek 兼容回退策略降低返回截断率。
- [x] 进一步优化流式分片去重与回退判定：新增尾部重叠检测，避免供应商返回累积文本导致重复片段；保留无 `done` 信号时走降级补齐。
- [x] `examples/completions_stream.zig` 增加 DeepSeek 专用兜底：当流式结果明显截断（长文本却非结尾符）时继续触发非流式补齐，避免偶发尾部截断。
- [x] 修复流式示例 `done` 回调上下文传递错误：`completions_stream` 与 `chat_completion_stream` 现传入 `&stream_state`，确保 `stream_done` 可由 `onDone` 正确置位。
- [x] 加固示例主请求路径容错：`chat_completion`、`chat_completion_stream`、`completions_basic`、`completions_stream`、`chat_prefix_completion`、`fim_completion`、`fim_completion_stream`、`models_list` 的关键调用全部改为错误兜底，避免单例失败导致 `run-examples` 链路中断。
- [x] 补齐 `transport/http.zig` 中 DeepSeek `/beta` 自动切换边界测试（含 `/completions` 查询串、`/chat/completions` 查询串、`prefix` 在带 query 的 chat 路径场景）。
- [x] 进一步修复 DeepSeek `/beta` 自动切换路径归一化：补齐 `completions`、`chat/completions` 的“无前导 `/` + query 字符串”边界（例如 `completions?stream=true`）。
- [x] 强化 DeepSeek `/beta` 路由判断对路径形态的兼容（支持无前导 `/`、`?`、带空白的 base_url 场景），避免边界路径误判。
- [x] 修复 `deepSeekBetaBase` 对 `https://api.deepseek.com/beta/` 等幂等场景的兼容：在已有 `/beta/` 时不再追加重复 `/beta`，同时增加空白字符裁剪为通用空白字符。
- [x] `examples/completions_basic.zig` 与 `examples/completions_stream.zig` 显式设置 `echo = false`，避免 DeepSeek 在流式/非流式下返回输入提示词；`completions_stream` 的默认 `max_tokens` 提升到 768，提升长文本输出稳定性。
- [x] 为 `chat`、`completions`、`responses` 的流式 raw/alias 场景补齐可选 `done` 回调签名，统一流式终止观测。

### 4.2 回归测试
- [x] 补 transport 测试（重试、超时行为）。
- [x] 补充错误码映射测试。
- [x] 补资源方法签名测试（请求构建与响应解析）。
- [x] 增加流式解析测试（SSE）。
- [x] 增加配置加载/覆盖测试。
- [x] 补齐分页 helper 语义边界测试（has_more=false 及方向/游标边界行为）。
- [x] 扩展资源方法签名回归测试覆盖 `audio`/`embeddings`/`batch`/`moderations`。
- [x] `examples/chat_completion_stream.zig` 与 `examples/completions_stream.zig` 再次收紧回退边界：在无流式事件、无流式文本输出、或未收到结束信号时走非流式补齐，降低“返回不全”场景。
- [x] 调整 DeepSeek 流式回退判定：在 `stream_done` 缺失但文本末尾看似完整时，不再触发无条件补齐；仅在输出为空或文本尾部明显不完整时才发起非流式兜底。

### 4.3 Thinking Mode / Reasoning content
- [x] 完善 `chat` 侧的 Raw Value 能力：
  - [x] 新增 `create_chat_completion_value`/`create_chat_completion_value_with_options`。
  - [x] 新增 `create_chat_completion_raw_value`/`create_chat_completion_raw_value_with_options`。
- [x] 验证 `extra_body` 与 `thinking` 兼容：`CreateChatCompletionRequest` 支持 `extra_body` 并平铺到顶层 JSON。
- [x] 新增 `extra_body` 平铺回归测试（包含 `thinking` 与自定义键值）。
- [x] 新增 `examples/chat_thinking_mode.zig`，支持输出 `content` 与 `reasoning_content`，并演示多轮对话仅携带 `content` 回流。
- [x] 优化 `examples/chat_completion_stream.zig` 的流式输出：默认仅按 `content` 输出，`reasoning_content` 另行缓存并显示，避免思考内容与正文混排。

### 4.4 DeepSeek 多轮与 Prefix 能力对齐
- [x] 新增 `examples/chat_prefix_completion.zig`，演示 `messages[].prefix = true` 续写调用，并接入 `build.zig` 与示例文档清单。
- [x] 收敛 `DeepSeek prefix` 路由条件：仅在 `messages` 最后一条 `assistant` 且 `prefix=true` 时自动切换到 `/beta`，并补充路由边界测试。

### 4.5 FIM / Suffix 补全能力对齐
- [x] 确认 `CreateCompletionRequest` 已包含 `suffix` 字段，可用于 DeepSeek FIM 风格续写。
- [x] 增加 `examples/fim_completion.zig`，演示 `prompt` + `suffix` 示例并接入 `build.zig`。
- [x] 增加 `completions` 本地序列化回归测试，确保 `suffix` 能正确参与 JSON 请求体构造。
- [x] 新增 `examples/fim_completion_stream.zig`，验证 FIM 流式续写与 fallback 兜底。
- [x] 增加 `examples/fim_completion_raw.zig`，通过 `std.json.Value` 直接发起 `/completions` FIM 请求，演示 raw 透传。

### 4.6 音频转写与示例补齐
- [x] 增加 `audio` 本地文件路径转写/翻译 helper（`create_transcription_from_path` / `create_translation_from_path`）并补齐 `transcriptions_from_path`、`translations_from_path` 别名链路。
- [x] 修复 Zig 0.15 下 multipart 构建与文件长度读取编译兼容（`ArrayList.writer`、`file.stat` 错误集合适配）。
- [x] 新增 `examples/audio_transcription.zig` 示例并接入 `run-examples`，支持缺失文件与 DeepSeek 兼容层跳过提示。

### 4.7 JSON Mode / JSON 输出能力
- [x] 在 `chat` 资源补充 `ResponseFormat` 结构化构造能力，支持 `json_object` 与 `json_schema`。
- [x] 新增 `examples/chat_json_mode.zig`，演示 `response_format` JSON 模式请求与 JSON Schema 限制输出。
- [x] 补充 `examples/chat_json_mode.zig` 的 DeepSeek 兼容分支：当 `response_format` `json_schema` 不可用时自动降级到 `json_object`，避免 DeepSeek 兼容链路报错。

### 4.8 Tool Calls
- [x] 补齐 `chat.create_chat_completion` 的 `tools` 与 `tool_choice` 结构化请求能力（含 `forFunction/forAuto/forNone/forRequired` 与 `raw` 兼容）。
- [x] 新增 `examples/chat_tool_calls.zig`，展示 `tools` + `tool_choice` 的请求构造与返回 `tool_calls` 解析。

## 5. 后续执行建议
- 第一步先做 P0：transport、errors、资源通用层（`common`）。
- 第二步做 P1：流式统一、文件 multipart、核心资源 `with_options` 接口扩展。
- 第三步做 P2：分页、模型/文档、测试收口。
