# OpenAI Zig SDK 对齐清单（对照 openai-python）

目标：基于 `openai-python` 的使用语义，逐步把当前实现补齐到完整可用能力。

## 0. 当前状态快照（已确认）
- `scripts/check-op-coverage.sh` 通过，operation wrapper 覆盖已到位。
- `zig build` / `zig build test` / `zig build -Dexamples=true run-examples` 均可运行。
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

### 1.3 资源方法行为一致性（兼容别名）
- [x] 核对核心资源函数命名与 `openai-python` 常见别名（如 `create/retrieve/list/delete` 与具体方法名）基本一致，并补齐 `chat`、`completions`、`models`、`files`、`images`、`responses` 的核心别名。
- [ ] 保持 `payload`/可选参数语义，减少 `null` 与“未传”差异。
- [ ] 确认 `chat`/`completions`/`responses` 等核心路径行为优先对齐。

## 2. 优先级 P1（第二优先）

### 2.1 资源通用化（减少重复实现）
- [ ] 将各资源中的发送逻辑统一到 `common` 的 `sendJsonTypedWithOptions` / `sendNoBodyTypedWithOptions`（逐步推进）。
- [x] 统一 query 构建/URL 编码逻辑（分页字段 `limit/after/before/order` 等）。
- [x] 批量接入 `request options` 到核心资源方法：`chat`、`completions`、`models`、`files`、`images`、`responses`、`audio`、`embeddings`、`moderations`、`batch`、`users`、`groups`、`group_users`、`invites`、`user_role_assignments`、`group_role_assignments`、`project_user_role_assignments`、`project_group_role_assignments`、`roles`。

### 2.2 流式能力统一
- [ ] 抽象 SSE/parsing 工具，统一 `text/event-stream` 处理。
- [ ] 统一 `[DONE]` 终止行为，保留回调错误透传。
- [ ] 逐步补齐支持流式的 endpoint。

### 2.3 文件与多部分请求
- [ ] 统一 multipart 构建流程（边界、字段、content-type）。
- [ ] 支持文件上传场景中的常见元数据参数（如 `purpose`）。
- [ ] 最小化内存复制（可后续引入更高效实现）。

## 3. 优先级 P2（第三优先）

### 3.1 分页体验
- [ ] 实现自动分页工具（可选，不改 breaking change）：
  - [ ] 手动分页器（`after/before/limit`）。
  - [ ] 自动分页迭代（可选）。
- [ ] 提供分页返回字段一致性检查与文档示例。

### 3.2 返回模型完整性
- [ ] 对齐高频模型字段与 `openai-python` 行为（chat/create response、assistants/runs/messages、vector stores、files 等）。
- [ ] 缺失字段补齐，保持 `ignore_unknown_fields = true` 兜底。

### 3.3 配置层和开发体验
- [ ] 统一环境变量优先级文档（`OPENAI_*` / `DEEPSEEK_*`）。
- [ ] 文档化 `Client.init` 与 `Client.withOptions/with_options` 行为。
- [ ] 明确 base_url、组织/项目 id 的默认来源与覆盖规则。

## 4. 优先级 P3（完善）

### 4.1 示例与文档
- [ ] 补齐每个核心资源示例（最少 1~2 个）。
- [ ] 增加错误处理、流式、分页、文件上传案例。

### 4.2 回归测试
- [ ] 补 transport 测试（重试、错误码映射、超时行为）。
- [ ] 补资源方法签名测试（请求构建与响应解析）。
- [ ] 增加流式解析测试（SSE）。
- [ ] 增加配置加载/覆盖测试。

## 5. 后续执行建议
- 第一步先做 P0：transport、errors、资源通用层（`common`）。
- 第二步做 P1：流式统一、文件 multipart、核心资源 `with_options` 接口扩展。
- 第三步做 P2：分页、模型/文档、测试收口。
