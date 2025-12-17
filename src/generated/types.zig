const std = @import("std");

pub const ActiveStatus = struct {
    type: []const u8,
};
pub const AddUploadPartRequest = struct {
    data: []const u8,
};
pub const AdminApiKey = struct {
    object: []const u8,
    id: []const u8,
    name: []const u8,
    redacted_value: []const u8,
    value: ?[]const u8,
    created_at: i64,
    last_used_at: std.json.Value,
    owner: struct {
        type: ?[]const u8,
        object: ?[]const u8,
        id: ?[]const u8,
        name: ?[]const u8,
        created_at: ?i64,
        role: ?[]const u8,
    },
};
pub const Annotation = std.json.Value;
pub const ApiKeyList = struct {
    object: ?[]const u8,
    data: ?[]const AdminApiKey,
    has_more: ?bool,
    first_id: ?[]const u8,
    last_id: ?[]const u8,
};
pub const ApplyPatchCallOutputStatus = []const u8;
pub const ApplyPatchCallOutputStatusParam = []const u8;
pub const ApplyPatchCallStatus = []const u8;
pub const ApplyPatchCallStatusParam = []const u8;
pub const ApplyPatchCreateFileOperation = struct {
    type: []const u8,
    path: []const u8,
    diff: []const u8,
};
pub const ApplyPatchCreateFileOperationParam = struct {
    type: []const u8,
    path: []const u8,
    diff: []const u8,
};
pub const ApplyPatchDeleteFileOperation = struct {
    type: []const u8,
    path: []const u8,
};
pub const ApplyPatchDeleteFileOperationParam = struct {
    type: []const u8,
    path: []const u8,
};
pub const ApplyPatchOperationParam = std.json.Value;
pub const ApplyPatchToolCall = struct {
    type: []const u8,
    id: []const u8,
    call_id: []const u8,
    status: ApplyPatchCallStatus,
    operation: std.json.Value,
    created_by: ?[]const u8,
};
pub const ApplyPatchToolCallItemParam = struct {
    type: []const u8,
    id: ?std.json.Value,
    call_id: []const u8,
    status: ApplyPatchCallStatusParam,
    operation: ApplyPatchOperationParam,
};
pub const ApplyPatchToolCallOutput = struct {
    type: []const u8,
    id: []const u8,
    call_id: []const u8,
    status: ApplyPatchCallOutputStatus,
    output: ?std.json.Value,
    created_by: ?[]const u8,
};
pub const ApplyPatchToolCallOutputItemParam = struct {
    type: []const u8,
    id: ?std.json.Value,
    call_id: []const u8,
    status: ApplyPatchCallOutputStatusParam,
    output: ?std.json.Value,
};
pub const ApplyPatchToolParam = struct {
    type: []const u8,
};
pub const ApplyPatchUpdateFileOperation = struct {
    type: []const u8,
    path: []const u8,
    diff: []const u8,
};
pub const ApplyPatchUpdateFileOperationParam = struct {
    type: []const u8,
    path: []const u8,
    diff: []const u8,
};
pub const ApproximateLocation = struct {
    type: []const u8,
    country: ?std.json.Value,
    region: ?std.json.Value,
    city: ?std.json.Value,
    timezone: ?std.json.Value,
};
pub const AssignedRoleDetails = struct {
    id: []const u8,
    name: []const u8,
    permissions: []const []const u8,
    resource_type: []const u8,
    predefined_role: bool,
    description: std.json.Value,
    created_at: std.json.Value,
    updated_at: std.json.Value,
    created_by: std.json.Value,
    created_by_user_obj: std.json.Value,
    metadata: std.json.Value,
};
pub const AssistantMessageItem = struct {
    id: []const u8,
    object: []const u8,
    created_at: i64,
    thread_id: []const u8,
    type: []const u8,
    content: []const ResponseOutputText,
};
pub const AssistantObject = struct {
    id: []const u8,
    object: []const u8,
    created_at: i64,
    name: std.json.Value,
    description: std.json.Value,
    model: []const u8,
    instructions: std.json.Value,
    tools: []const AssistantTool,
    tool_resources: ?std.json.Value,
    metadata: Metadata,
    temperature: ?std.json.Value,
    top_p: ?std.json.Value,
    response_format: ?std.json.Value,
};
pub const AssistantStreamEvent = std.json.Value;
pub const AssistantSupportedModels = []const u8;
pub const AssistantTool = std.json.Value;
pub const AssistantToolsCode = struct {
    type: []const u8,
};
pub const AssistantToolsFileSearch = struct {
    type: []const u8,
    file_search: ?struct {
        max_num_results: ?i64,
        ranking_options: ?FileSearchRankingOptions,
    },
};
pub const AssistantToolsFileSearchTypeOnly = struct {
    type: []const u8,
};
pub const AssistantToolsFunction = struct {
    type: []const u8,
    function: FunctionObject,
};
pub const AssistantsApiResponseFormatOption = std.json.Value;
pub const AssistantsApiToolChoiceOption = std.json.Value;
pub const AssistantsNamedToolChoice = struct {
    type: []const u8,
    function: ?struct {
        name: []const u8,
    },
};
pub const Attachment = struct {
    type: AttachmentType,
    id: []const u8,
    name: []const u8,
    mime_type: []const u8,
    preview_url: std.json.Value,
};
pub const AttachmentType = []const u8;
pub const AudioResponseFormat = []const u8;
pub const AudioTranscription = struct {
    model: ?[]const u8,
    language: ?[]const u8,
    prompt: ?[]const u8,
};
pub const AuditLog = struct {
    id: []const u8,
    type: AuditLogEventType,
    effective_at: i64,
    project: ?struct {
        id: ?[]const u8,
        name: ?[]const u8,
    },
    actor: AuditLogActor,
    api_key_created: ?struct {
        id: ?[]const u8,
        data: ?struct {
            scopes: ?[]const []const u8,
        },
    },
    api_key_updated: ?struct {
        id: ?[]const u8,
        changes_requested: ?struct {
            scopes: ?[]const []const u8,
        },
    },
    api_key_deleted: ?struct {
        id: ?[]const u8,
    },
    checkpoint_permission_created: ?struct {
        id: ?[]const u8,
        data: ?struct {
            project_id: ?[]const u8,
            fine_tuned_model_checkpoint: ?[]const u8,
        },
    },
    checkpoint_permission_deleted: ?struct {
        id: ?[]const u8,
    },
    external_key_registered: ?struct {
        id: ?[]const u8,
        data: ?std.json.Value,
    },
    external_key_removed: ?struct {
        id: ?[]const u8,
    },
    group_created: ?struct {
        id: ?[]const u8,
        data: ?struct {
            group_name: ?[]const u8,
        },
    },
    group_updated: ?struct {
        id: ?[]const u8,
        changes_requested: ?struct {
            group_name: ?[]const u8,
        },
    },
    group_deleted: ?struct {
        id: ?[]const u8,
    },
    scim_enabled: ?struct {
        id: ?[]const u8,
    },
    scim_disabled: ?struct {
        id: ?[]const u8,
    },
    invite_sent: ?struct {
        id: ?[]const u8,
        data: ?struct {
            email: ?[]const u8,
            role: ?[]const u8,
        },
    },
    invite_accepted: ?struct {
        id: ?[]const u8,
    },
    invite_deleted: ?struct {
        id: ?[]const u8,
    },
    ip_allowlist_created: ?struct {
        id: ?[]const u8,
        name: ?[]const u8,
        allowed_ips: ?[]const []const u8,
    },
    ip_allowlist_updated: ?struct {
        id: ?[]const u8,
        allowed_ips: ?[]const []const u8,
    },
    ip_allowlist_deleted: ?struct {
        id: ?[]const u8,
        name: ?[]const u8,
        allowed_ips: ?[]const []const u8,
    },
    ip_allowlist_config_activated: ?struct {
        configs: ?[]const struct {
            id: ?[]const u8,
            name: ?[]const u8,
        },
    },
    ip_allowlist_config_deactivated: ?struct {
        configs: ?[]const struct {
            id: ?[]const u8,
            name: ?[]const u8,
        },
    },
    login_succeeded: ?std.json.Value,
    login_failed: ?struct {
        error_code: ?[]const u8,
        error_message: ?[]const u8,
    },
    logout_succeeded: ?std.json.Value,
    logout_failed: ?struct {
        error_code: ?[]const u8,
        error_message: ?[]const u8,
    },
    organization_updated: ?struct {
        id: ?[]const u8,
        changes_requested: ?struct {
            title: ?[]const u8,
            description: ?[]const u8,
            name: ?[]const u8,
            threads_ui_visibility: ?[]const u8,
            usage_dashboard_visibility: ?[]const u8,
            api_call_logging: ?[]const u8,
            api_call_logging_project_ids: ?[]const u8,
        },
    },
    project_created: ?struct {
        id: ?[]const u8,
        data: ?struct {
            name: ?[]const u8,
            title: ?[]const u8,
        },
    },
    project_updated: ?struct {
        id: ?[]const u8,
        changes_requested: ?struct {
            title: ?[]const u8,
        },
    },
    project_archived: ?struct {
        id: ?[]const u8,
    },
    project_deleted: ?struct {
        id: ?[]const u8,
    },
    rate_limit_updated: ?struct {
        id: ?[]const u8,
        changes_requested: ?struct {
            max_requests_per_1_minute: ?i64,
            max_tokens_per_1_minute: ?i64,
            max_images_per_1_minute: ?i64,
            max_audio_megabytes_per_1_minute: ?i64,
            max_requests_per_1_day: ?i64,
            batch_1_day_max_input_tokens: ?i64,
        },
    },
    rate_limit_deleted: ?struct {
        id: ?[]const u8,
    },
    role_created: ?struct {
        id: ?[]const u8,
        role_name: ?[]const u8,
        permissions: ?[]const []const u8,
        resource_type: ?[]const u8,
        resource_id: ?[]const u8,
    },
    role_updated: ?struct {
        id: ?[]const u8,
        changes_requested: ?struct {
            role_name: ?[]const u8,
            resource_id: ?[]const u8,
            resource_type: ?[]const u8,
            permissions_added: ?[]const []const u8,
            permissions_removed: ?[]const []const u8,
            description: ?[]const u8,
            metadata: ?std.json.Value,
        },
    },
    role_deleted: ?struct {
        id: ?[]const u8,
    },
    role_assignment_created: ?struct {
        id: ?[]const u8,
        principal_id: ?[]const u8,
        principal_type: ?[]const u8,
        resource_id: ?[]const u8,
        resource_type: ?[]const u8,
    },
    role_assignment_deleted: ?struct {
        id: ?[]const u8,
        principal_id: ?[]const u8,
        principal_type: ?[]const u8,
        resource_id: ?[]const u8,
        resource_type: ?[]const u8,
    },
    service_account_created: ?struct {
        id: ?[]const u8,
        data: ?struct {
            role: ?[]const u8,
        },
    },
    service_account_updated: ?struct {
        id: ?[]const u8,
        changes_requested: ?struct {
            role: ?[]const u8,
        },
    },
    service_account_deleted: ?struct {
        id: ?[]const u8,
    },
    user_added: ?struct {
        id: ?[]const u8,
        data: ?struct {
            role: ?[]const u8,
        },
    },
    user_updated: ?struct {
        id: ?[]const u8,
        changes_requested: ?struct {
            role: ?[]const u8,
        },
    },
    user_deleted: ?struct {
        id: ?[]const u8,
    },
    certificate_created: ?struct {
        id: ?[]const u8,
        name: ?[]const u8,
    },
    certificate_updated: ?struct {
        id: ?[]const u8,
        name: ?[]const u8,
    },
    certificate_deleted: ?struct {
        id: ?[]const u8,
        name: ?[]const u8,
        certificate: ?[]const u8,
    },
    certificates_activated: ?struct {
        certificates: ?[]const struct {
            id: ?[]const u8,
            name: ?[]const u8,
        },
    },
    certificates_deactivated: ?struct {
        certificates: ?[]const struct {
            id: ?[]const u8,
            name: ?[]const u8,
        },
    },
};
pub const AuditLogActor = struct {
    type: ?[]const u8,
    session: ?AuditLogActorSession,
    api_key: ?AuditLogActorApiKey,
};
pub const AuditLogActorApiKey = struct {
    id: ?[]const u8,
    type: ?[]const u8,
    user: ?AuditLogActorUser,
    service_account: ?AuditLogActorServiceAccount,
};
pub const AuditLogActorServiceAccount = struct {
    id: ?[]const u8,
};
pub const AuditLogActorSession = struct {
    user: ?AuditLogActorUser,
    ip_address: ?[]const u8,
};
pub const AuditLogActorUser = struct {
    id: ?[]const u8,
    email: ?[]const u8,
};
pub const AuditLogEventType = []const u8;
pub const AutoChunkingStrategyRequestParam = struct {
    type: []const u8,
};
pub const AutomaticThreadTitlingParam = struct {
    enabled: ?bool,
};
pub const Batch = struct {
    id: []const u8,
    object: []const u8,
    endpoint: []const u8,
    model: ?[]const u8,
    errors: ?struct {
        object: ?[]const u8,
        data: ?[]const BatchError,
    },
    input_file_id: []const u8,
    completion_window: []const u8,
    status: []const u8,
    output_file_id: ?[]const u8,
    error_file_id: ?[]const u8,
    created_at: i64,
    in_progress_at: ?i64,
    expires_at: ?i64,
    finalizing_at: ?i64,
    completed_at: ?i64,
    failed_at: ?i64,
    expired_at: ?i64,
    cancelling_at: ?i64,
    cancelled_at: ?i64,
    request_counts: ?BatchRequestCounts,
    usage: ?struct {
        input_tokens: i64,
        input_tokens_details: struct {
            cached_tokens: i64,
        },
        output_tokens: i64,
        output_tokens_details: struct {
            reasoning_tokens: i64,
        },
        total_tokens: i64,
    },
    metadata: ?Metadata,
};
pub const BatchError = struct {
    code: ?[]const u8,
    message: ?[]const u8,
    param: ?std.json.Value,
    line: ?std.json.Value,
};
pub const BatchFileExpirationAfter = struct {
    anchor: []const u8,
    seconds: i64,
};
pub const BatchRequestCounts = struct {
    total: i64,
    completed: i64,
    failed: i64,
};
pub const BatchRequestInput = struct {
    custom_id: ?[]const u8,
    method: ?[]const u8,
    url: ?[]const u8,
};
pub const BatchRequestOutput = struct {
    id: ?[]const u8,
    custom_id: ?[]const u8,
    response: ?std.json.Value,
    _error: ?std.json.Value,
};
pub const Certificate = struct {
    object: []const u8,
    id: []const u8,
    name: []const u8,
    created_at: i64,
    certificate_details: struct {
        valid_at: ?i64,
        expires_at: ?i64,
        content: ?[]const u8,
    },
    active: ?bool,
};
pub const ChatCompletionAllowedTools = struct {
    mode: []const u8,
    tools: []const std.json.Value,
};
pub const ChatCompletionAllowedToolsChoice = struct {
    type: []const u8,
    allowed_tools: ChatCompletionAllowedTools,
};
pub const ChatCompletionDeleted = struct {
    object: []const u8,
    id: []const u8,
    deleted: bool,
};
pub const ChatCompletionFunctionCallOption = struct {
    name: []const u8,
};
pub const ChatCompletionFunctions = struct {
    description: ?[]const u8,
    name: []const u8,
    parameters: ?FunctionParameters,
};
pub const ChatCompletionList = struct {
    object: []const u8,
    data: []const CreateChatCompletionResponse,
    first_id: []const u8,
    last_id: []const u8,
    has_more: bool,
};
pub const ChatCompletionMessageCustomToolCall = struct {
    id: []const u8,
    type: []const u8,
    custom: struct {
        name: []const u8,
        input: []const u8,
    },
};
pub const ChatCompletionMessageList = struct {
    object: []const u8,
    data: []const std.json.Value,
    first_id: []const u8,
    last_id: []const u8,
    has_more: bool,
};
pub const ChatCompletionMessageToolCall = struct {
    id: []const u8,
    type: []const u8,
    function: struct {
        name: []const u8,
        arguments: []const u8,
    },
};
pub const ChatCompletionMessageToolCallChunk = struct {
    index: i64,
    id: ?[]const u8,
    type: ?[]const u8,
    function: ?struct {
        name: ?[]const u8,
        arguments: ?[]const u8,
    },
};
pub const ChatCompletionMessageToolCalls = []const std.json.Value;
pub const ChatCompletionModalities = std.json.Value;
pub const ChatCompletionNamedToolChoice = struct {
    type: []const u8,
    function: struct {
        name: []const u8,
    },
};
pub const ChatCompletionNamedToolChoiceCustom = struct {
    type: []const u8,
    custom: struct {
        name: []const u8,
    },
};
pub const ChatCompletionRequestAssistantMessage = struct {
    content: ?std.json.Value,
    refusal: ?std.json.Value,
    role: []const u8,
    name: ?[]const u8,
    audio: ?std.json.Value,
    tool_calls: ?ChatCompletionMessageToolCalls,
    function_call: ?std.json.Value,
};
pub const ChatCompletionRequestAssistantMessageContentPart = std.json.Value;
pub const ChatCompletionRequestDeveloperMessage = struct {
    content: std.json.Value,
    role: []const u8,
    name: ?[]const u8,
};
pub const ChatCompletionRequestFunctionMessage = struct {
    role: []const u8,
    content: std.json.Value,
    name: []const u8,
};
pub const ChatCompletionRequestMessage = std.json.Value;
pub const ChatCompletionRequestMessageContentPartAudio = struct {
    type: []const u8,
    input_audio: struct {
        data: []const u8,
        format: []const u8,
    },
};
pub const ChatCompletionRequestMessageContentPartFile = struct {
    type: []const u8,
    file: struct {
        filename: ?[]const u8,
        file_data: ?[]const u8,
        file_id: ?[]const u8,
    },
};
pub const ChatCompletionRequestMessageContentPartImage = struct {
    type: []const u8,
    image_url: struct {
        url: []const u8,
        detail: ?[]const u8,
    },
};
pub const ChatCompletionRequestMessageContentPartRefusal = struct {
    type: []const u8,
    refusal: []const u8,
};
pub const ChatCompletionRequestMessageContentPartText = struct {
    type: []const u8,
    text: []const u8,
};
pub const ChatCompletionRequestSystemMessage = struct {
    content: std.json.Value,
    role: []const u8,
    name: ?[]const u8,
};
pub const ChatCompletionRequestSystemMessageContentPart = std.json.Value;
pub const ChatCompletionRequestToolMessage = struct {
    role: []const u8,
    content: std.json.Value,
    tool_call_id: []const u8,
};
pub const ChatCompletionRequestToolMessageContentPart = std.json.Value;
pub const ChatCompletionRequestUserMessage = struct {
    content: std.json.Value,
    role: []const u8,
    name: ?[]const u8,
};
pub const ChatCompletionRequestUserMessageContentPart = std.json.Value;
pub const ChatCompletionResponseMessage = struct {
    content: std.json.Value,
    refusal: std.json.Value,
    tool_calls: ?ChatCompletionMessageToolCalls,
    annotations: ?[]const struct {
        type: []const u8,
        url_citation: struct {
            end_index: i64,
            start_index: i64,
            url: []const u8,
            title: []const u8,
        },
    },
    role: []const u8,
    function_call: ?struct {
        arguments: []const u8,
        name: []const u8,
    },
    audio: ?std.json.Value,
};
pub const ChatCompletionRole = []const u8;
pub const ChatCompletionStreamOptions = std.json.Value;
pub const ChatCompletionStreamResponseDelta = struct {
    content: ?std.json.Value,
    function_call: ?struct {
        arguments: ?[]const u8,
        name: ?[]const u8,
    },
    tool_calls: ?[]const ChatCompletionMessageToolCallChunk,
    role: ?[]const u8,
    refusal: ?std.json.Value,
};
pub const ChatCompletionTokenLogprob = struct {
    token: []const u8,
    logprob: f64,
    bytes: std.json.Value,
    top_logprobs: []const struct {
        token: []const u8,
        logprob: f64,
        bytes: std.json.Value,
    },
};
pub const ChatCompletionTool = struct {
    type: []const u8,
    function: FunctionObject,
};
pub const ChatCompletionToolChoiceOption = std.json.Value;
pub const ChatModel = []const u8;
pub const ChatSessionAutomaticThreadTitling = struct {
    enabled: bool,
};
pub const ChatSessionChatkitConfiguration = struct {
    automatic_thread_titling: ChatSessionAutomaticThreadTitling,
    file_upload: ChatSessionFileUpload,
    history: ChatSessionHistory,
};
pub const ChatSessionFileUpload = struct {
    enabled: bool,
    max_file_size: std.json.Value,
    max_files: std.json.Value,
};
pub const ChatSessionHistory = struct {
    enabled: bool,
    recent_threads: std.json.Value,
};
pub const ChatSessionRateLimits = struct {
    max_requests_per_1_minute: i64,
};
pub const ChatSessionResource = struct {
    id: []const u8,
    object: []const u8,
    expires_at: i64,
    client_secret: []const u8,
    workflow: ChatkitWorkflow,
    user: []const u8,
    rate_limits: ChatSessionRateLimits,
    max_requests_per_1_minute: i64,
    status: ChatSessionStatus,
    chatkit_configuration: ChatSessionChatkitConfiguration,
};
pub const ChatSessionStatus = []const u8;
pub const ChatkitConfigurationParam = struct {
    automatic_thread_titling: ?AutomaticThreadTitlingParam,
    file_upload: ?FileUploadParam,
    history: ?HistoryParam,
};
pub const ChatkitWorkflow = struct {
    id: []const u8,
    version: std.json.Value,
    state_variables: std.json.Value,
    tracing: ChatkitWorkflowTracing,
};
pub const ChatkitWorkflowTracing = struct {
    enabled: bool,
};
pub const ChunkingStrategyRequestParam = std.json.Value;
pub const ChunkingStrategyResponse = std.json.Value;
pub const ClickButtonType = []const u8;
pub const ClickParam = struct {
    type: []const u8,
    button: ClickButtonType,
    x: i64,
    y: i64,
};
pub const ClientToolCallItem = struct {
    id: []const u8,
    object: []const u8,
    created_at: i64,
    thread_id: []const u8,
    type: []const u8,
    status: ClientToolCallStatus,
    call_id: []const u8,
    name: []const u8,
    arguments: []const u8,
    output: std.json.Value,
};
pub const ClientToolCallStatus = []const u8;
pub const ClosedStatus = struct {
    type: []const u8,
    reason: std.json.Value,
};
pub const CodeInterpreterContainerAuto = struct {
    type: []const u8,
    file_ids: ?[]const []const u8,
    memory_limit: ?std.json.Value,
};
pub const CodeInterpreterFileOutput = struct {
    type: []const u8,
    files: []const struct {
        mime_type: []const u8,
        file_id: []const u8,
    },
};
pub const CodeInterpreterOutputImage = struct {
    type: []const u8,
    url: []const u8,
};
pub const CodeInterpreterOutputLogs = struct {
    type: []const u8,
    logs: []const u8,
};
pub const CodeInterpreterTextOutput = struct {
    type: []const u8,
    logs: []const u8,
};
pub const CodeInterpreterTool = struct {
    type: []const u8,
    container: std.json.Value,
};
pub const CodeInterpreterToolCall = struct {
    type: []const u8,
    id: []const u8,
    status: []const u8,
    container_id: []const u8,
    code: std.json.Value,
    outputs: std.json.Value,
};
pub const CompactResource = struct {
    id: []const u8,
    object: []const u8,
    output: []const OutputItem,
    created_at: i64,
    usage: ResponseUsage,
};
pub const CompactResponseMethodPublicBody = struct {
    model: ModelIdsCompaction,
    input: ?std.json.Value,
    previous_response_id: ?std.json.Value,
    instructions: ?std.json.Value,
};
pub const CompactionBody = struct {
    type: []const u8,
    id: []const u8,
    encrypted_content: []const u8,
    created_by: ?[]const u8,
};
pub const CompactionSummaryItemParam = struct {
    id: ?std.json.Value,
    type: []const u8,
    encrypted_content: []const u8,
};
pub const ComparisonFilter = struct {
    type: []const u8,
    key: []const u8,
    value: std.json.Value,
};
pub const ComparisonFilterValueItems = std.json.Value;
pub const CompleteUploadRequest = struct {
    part_ids: []const []const u8,
    md5: ?[]const u8,
};
pub const CompletionUsage = struct {
    completion_tokens: i64,
    prompt_tokens: i64,
    total_tokens: i64,
    completion_tokens_details: ?struct {
        accepted_prediction_tokens: ?i64,
        audio_tokens: ?i64,
        reasoning_tokens: ?i64,
        rejected_prediction_tokens: ?i64,
    },
    prompt_tokens_details: ?struct {
        audio_tokens: ?i64,
        cached_tokens: ?i64,
    },
};
pub const CompoundFilter = struct {
    type: []const u8,
    filters: []const std.json.Value,
};
pub const ComputerAction = std.json.Value;
pub const ComputerCallOutputItemParam = struct {
    id: ?std.json.Value,
    call_id: []const u8,
    type: []const u8,
    output: ComputerScreenshotImage,
    acknowledged_safety_checks: ?std.json.Value,
    status: ?std.json.Value,
};
pub const ComputerCallSafetyCheckParam = struct {
    id: []const u8,
    code: ?std.json.Value,
    message: ?std.json.Value,
};
pub const ComputerEnvironment = []const u8;
pub const ComputerScreenshotContent = struct {
    type: []const u8,
    image_url: std.json.Value,
    file_id: std.json.Value,
};
pub const ComputerScreenshotImage = struct {
    type: []const u8,
    image_url: ?[]const u8,
    file_id: ?[]const u8,
};
pub const ComputerToolCall = struct {
    type: []const u8,
    id: []const u8,
    call_id: []const u8,
    action: ComputerAction,
    pending_safety_checks: []const ComputerCallSafetyCheckParam,
    status: []const u8,
};
pub const ComputerToolCallOutput = struct {
    type: []const u8,
    id: ?[]const u8,
    call_id: []const u8,
    acknowledged_safety_checks: ?[]const ComputerCallSafetyCheckParam,
    output: ComputerScreenshotImage,
    status: ?[]const u8,
};
pub const ComputerToolCallOutputResource = std.json.Value;
pub const ComputerUsePreviewTool = struct {
    type: []const u8,
    environment: ComputerEnvironment,
    display_width: i64,
    display_height: i64,
};
pub const ContainerFileCitationBody = struct {
    type: []const u8,
    container_id: []const u8,
    file_id: []const u8,
    start_index: i64,
    end_index: i64,
    filename: []const u8,
};
pub const ContainerFileListResource = struct {
    object: std.json.Value,
    data: []const ContainerFileResource,
    first_id: []const u8,
    last_id: []const u8,
    has_more: bool,
};
pub const ContainerFileResource = struct {
    id: []const u8,
    object: []const u8,
    container_id: []const u8,
    created_at: i64,
    bytes: i64,
    path: []const u8,
    source: []const u8,
};
pub const ContainerListResource = struct {
    object: std.json.Value,
    data: []const ContainerResource,
    first_id: []const u8,
    last_id: []const u8,
    has_more: bool,
};
pub const ContainerMemoryLimit = []const u8;
pub const ContainerResource = struct {
    id: []const u8,
    object: []const u8,
    name: []const u8,
    created_at: i64,
    status: []const u8,
    last_active_at: ?i64,
    expires_after: ?struct {
        anchor: ?[]const u8,
        minutes: ?i64,
    },
    memory_limit: ?[]const u8,
};
pub const Content = std.json.Value;
pub const Conversation = std.json.Value;
pub const Conversation_2 = struct {
    id: []const u8,
};
pub const ConversationItem = std.json.Value;
pub const ConversationItemList = struct {
    object: std.json.Value,
    data: []const ConversationItem,
    has_more: bool,
    first_id: []const u8,
    last_id: []const u8,
};
pub const ConversationParam = std.json.Value;
pub const ConversationParam_2 = struct {
    id: []const u8,
};
pub const ConversationResource = struct {
    id: []const u8,
    object: []const u8,
    metadata: std.json.Value,
    created_at: i64,
};
pub const CostsResult = struct {
    object: []const u8,
    amount: ?struct {
        value: ?f64,
        currency: ?[]const u8,
    },
    line_item: ?std.json.Value,
    project_id: ?std.json.Value,
};
pub const CreateAssistantRequest = struct {
    model: std.json.Value,
    name: ?std.json.Value,
    description: ?std.json.Value,
    instructions: ?std.json.Value,
    reasoning_effort: ?ReasoningEffort,
    tools: ?[]const AssistantTool,
    tool_resources: ?std.json.Value,
    metadata: ?Metadata,
    temperature: ?std.json.Value,
    top_p: ?std.json.Value,
    response_format: ?std.json.Value,
};
pub const CreateChatCompletionRequest = std.json.Value;
pub const CreateChatCompletionResponse = struct {
    id: []const u8,
    choices: []const struct {
        finish_reason: []const u8,
        index: i64,
        message: ChatCompletionResponseMessage,
        logprobs: std.json.Value,
    },
    created: i64,
    model: []const u8,
    service_tier: ?ServiceTier,
    system_fingerprint: ?[]const u8,
    object: []const u8,
    usage: ?CompletionUsage,
};
pub const CreateChatCompletionStreamResponse = struct {
    id: []const u8,
    choices: []const struct {
        delta: ChatCompletionStreamResponseDelta,
        logprobs: ?struct {
            content: []const ChatCompletionTokenLogprob,
            refusal: []const ChatCompletionTokenLogprob,
        },
        finish_reason: []const u8,
        index: i64,
    },
    created: i64,
    model: []const u8,
    service_tier: ?ServiceTier,
    system_fingerprint: ?[]const u8,
    object: []const u8,
    usage: ?CompletionUsage,
};
pub const CreateChatSessionBody = struct {
    workflow: WorkflowParam,
    user: []const u8,
    expires_after: ?ExpiresAfterParam,
    rate_limits: ?RateLimitsParam,
    chatkit_configuration: ?ChatkitConfigurationParam,
};
pub const CreateCompletionRequest = struct {
    model: std.json.Value,
    prompt: std.json.Value,
    best_of: ?i64,
    echo: ?bool,
    frequency_penalty: ?f64,
    logit_bias: ?std.json.Value,
    logprobs: ?i64,
    max_tokens: ?i64,
    n: ?i64,
    presence_penalty: ?f64,
    seed: ?i64,
    stop: ?StopConfiguration,
    stream: ?bool,
    stream_options: ?ChatCompletionStreamOptions,
    suffix: ?[]const u8,
    temperature: ?f64,
    top_p: ?f64,
    user: ?[]const u8,
};
pub const CreateCompletionResponse = struct {
    id: []const u8,
    choices: []const struct {
        finish_reason: []const u8,
        index: i64,
        logprobs: std.json.Value,
        text: []const u8,
    },
    created: i64,
    model: []const u8,
    system_fingerprint: ?[]const u8,
    object: []const u8,
    usage: ?CompletionUsage,
};
pub const CreateContainerBody = struct {
    name: []const u8,
    file_ids: ?[]const []const u8,
    expires_after: ?struct {
        anchor: []const u8,
        minutes: i64,
    },
    memory_limit: ?[]const u8,
};
pub const CreateContainerFileBody = struct {
    file_id: ?[]const u8,
    file: ?[]const u8,
};
pub const CreateConversationBody = struct {
    metadata: ?std.json.Value,
    items: ?std.json.Value,
};
pub const CreateEmbeddingRequest = struct {
    input: std.json.Value,
    model: std.json.Value,
    encoding_format: ?[]const u8,
    dimensions: ?i64,
    user: ?[]const u8,
};
pub const CreateEmbeddingResponse = struct {
    data: []const Embedding,
    model: []const u8,
    object: []const u8,
    usage: struct {
        prompt_tokens: i64,
        total_tokens: i64,
    },
};
pub const CreateEvalCompletionsRunDataSource = struct {
    type: []const u8,
    input_messages: ?std.json.Value,
    sampling_params: ?struct {
        reasoning_effort: ?ReasoningEffort,
        temperature: ?f64,
        max_completion_tokens: ?i64,
        top_p: ?f64,
        seed: ?i64,
        response_format: ?std.json.Value,
        tools: ?[]const ChatCompletionTool,
    },
    model: ?[]const u8,
    source: std.json.Value,
};
pub const CreateEvalCustomDataSourceConfig = struct {
    type: []const u8,
    item_schema: std.json.Value,
    include_sample_schema: ?bool,
};
pub const CreateEvalItem = std.json.Value;
pub const CreateEvalJsonlRunDataSource = struct {
    type: []const u8,
    source: std.json.Value,
};
pub const CreateEvalLabelModelGrader = struct {
    type: []const u8,
    name: []const u8,
    model: []const u8,
    input: []const CreateEvalItem,
    labels: []const []const u8,
    passing_labels: []const []const u8,
};
pub const CreateEvalLogsDataSourceConfig = struct {
    type: []const u8,
    metadata: ?std.json.Value,
};
pub const CreateEvalRequest = struct {
    name: ?[]const u8,
    metadata: ?Metadata,
    data_source_config: std.json.Value,
    testing_criteria: []const std.json.Value,
};
pub const CreateEvalResponsesRunDataSource = struct {
    type: []const u8,
    input_messages: ?std.json.Value,
    sampling_params: ?struct {
        reasoning_effort: ?ReasoningEffort,
        temperature: ?f64,
        max_completion_tokens: ?i64,
        top_p: ?f64,
        seed: ?i64,
        tools: ?[]const Tool,
        text: ?struct {
            format: ?TextResponseFormatConfiguration,
        },
    },
    model: ?[]const u8,
    source: std.json.Value,
};
pub const CreateEvalRunRequest = struct {
    name: ?[]const u8,
    metadata: ?Metadata,
    data_source: std.json.Value,
};
pub const CreateEvalStoredCompletionsDataSourceConfig = struct {
    type: []const u8,
    metadata: ?std.json.Value,
};
pub const CreateFileRequest = struct {
    file: []const u8,
    purpose: FilePurpose,
    expires_after: ?FileExpirationAfter,
};
pub const CreateFineTuningCheckpointPermissionRequest = struct {
    project_ids: []const []const u8,
};
pub const CreateFineTuningJobRequest = struct {
    model: std.json.Value,
    training_file: []const u8,
    hyperparameters: ?struct {
        batch_size: ?std.json.Value,
        learning_rate_multiplier: ?std.json.Value,
        n_epochs: ?std.json.Value,
    },
    suffix: ?[]const u8,
    validation_file: ?[]const u8,
    integrations: ?[]const struct {
        type: std.json.Value,
        wandb: struct {
            project: []const u8,
            name: ?[]const u8,
            entity: ?[]const u8,
            tags: ?[]const []const u8,
        },
    },
    seed: ?i64,
    method: ?FineTuneMethod,
    metadata: ?Metadata,
};
pub const CreateGroupBody = struct {
    name: []const u8,
};
pub const CreateGroupUserBody = struct {
    user_id: []const u8,
};
pub const CreateImageEditRequest = struct {
    image: std.json.Value,
    prompt: []const u8,
    mask: ?[]const u8,
    background: ?[]const u8,
    model: ?std.json.Value,
    n: ?i64,
    size: ?[]const u8,
    response_format: ?[]const u8,
    output_format: ?[]const u8,
    output_compression: ?i64,
    user: ?[]const u8,
    input_fidelity: ?std.json.Value,
    stream: ?bool,
    partial_images: ?PartialImages,
    quality: ?[]const u8,
};
pub const CreateImageRequest = struct {
    prompt: []const u8,
    model: ?std.json.Value,
    n: ?i64,
    quality: ?[]const u8,
    response_format: ?[]const u8,
    output_format: ?[]const u8,
    output_compression: ?i64,
    stream: ?bool,
    partial_images: ?PartialImages,
    size: ?[]const u8,
    moderation: ?[]const u8,
    background: ?[]const u8,
    style: ?[]const u8,
    user: ?[]const u8,
};
pub const CreateImageVariationRequest = struct {
    image: []const u8,
    model: ?std.json.Value,
    n: ?i64,
    response_format: ?[]const u8,
    size: ?[]const u8,
    user: ?[]const u8,
};
pub const CreateMessageRequest = struct {
    role: []const u8,
    content: std.json.Value,
    attachments: ?std.json.Value,
    metadata: ?Metadata,
};
pub const CreateModelResponseProperties = std.json.Value;
pub const CreateModerationRequest = struct {
    input: std.json.Value,
    model: ?std.json.Value,
};
pub const CreateModerationResponse = struct {
    id: []const u8,
    model: []const u8,
    results: []const struct {
        flagged: bool,
        categories: struct {
            hate: bool,
            hate_threatening: bool,
            harassment: bool,
            harassment_threatening: bool,
            illicit: std.json.Value,
            illicit_violent: std.json.Value,
            self_harm: bool,
            self_harm_intent: bool,
            self_harm_instructions: bool,
            sexual: bool,
            sexual_minors: bool,
            violence: bool,
            violence_graphic: bool,
        },
        category_scores: struct {
            hate: f64,
            hate_threatening: f64,
            harassment: f64,
            harassment_threatening: f64,
            illicit: f64,
            illicit_violent: f64,
            self_harm: f64,
            self_harm_intent: f64,
            self_harm_instructions: f64,
            sexual: f64,
            sexual_minors: f64,
            violence: f64,
            violence_graphic: f64,
        },
        category_applied_input_types: struct {
            hate: []const []const u8,
            hate_threatening: []const []const u8,
            harassment: []const []const u8,
            harassment_threatening: []const []const u8,
            illicit: []const []const u8,
            illicit_violent: []const []const u8,
            self_harm: []const []const u8,
            self_harm_intent: []const []const u8,
            self_harm_instructions: []const []const u8,
            sexual: []const []const u8,
            sexual_minors: []const []const u8,
            violence: []const []const u8,
            violence_graphic: []const []const u8,
        },
    },
};
pub const CreateResponse = std.json.Value;
pub const CreateRunRequest = struct {
    assistant_id: []const u8,
    model: ?std.json.Value,
    reasoning_effort: ?ReasoningEffort,
    instructions: ?[]const u8,
    additional_instructions: ?[]const u8,
    additional_messages: ?[]const CreateMessageRequest,
    tools: ?[]const AssistantTool,
    metadata: ?Metadata,
    temperature: ?f64,
    top_p: ?f64,
    stream: ?bool,
    max_prompt_tokens: ?i64,
    max_completion_tokens: ?i64,
    truncation_strategy: ?std.json.Value,
    tool_choice: ?std.json.Value,
    parallel_tool_calls: ?ParallelToolCalls,
    response_format: ?AssistantsApiResponseFormatOption,
};
pub const CreateRunRequestWithoutStream = struct {
    assistant_id: []const u8,
    model: ?std.json.Value,
    reasoning_effort: ?ReasoningEffort,
    instructions: ?[]const u8,
    additional_instructions: ?[]const u8,
    additional_messages: ?[]const CreateMessageRequest,
    tools: ?[]const AssistantTool,
    metadata: ?Metadata,
    temperature: ?f64,
    top_p: ?f64,
    max_prompt_tokens: ?i64,
    max_completion_tokens: ?i64,
    truncation_strategy: ?std.json.Value,
    tool_choice: ?std.json.Value,
    parallel_tool_calls: ?ParallelToolCalls,
    response_format: ?AssistantsApiResponseFormatOption,
};
pub const CreateSpeechRequest = struct {
    model: std.json.Value,
    input: []const u8,
    instructions: ?[]const u8,
    voice: VoiceIdsShared,
    response_format: ?[]const u8,
    speed: ?f64,
    stream_format: ?[]const u8,
};
pub const CreateSpeechResponseStreamEvent = std.json.Value;
pub const CreateThreadAndRunRequest = struct {
    assistant_id: []const u8,
    thread: ?CreateThreadRequest,
    model: ?std.json.Value,
    instructions: ?[]const u8,
    tools: ?[]const AssistantTool,
    tool_resources: ?struct {
        code_interpreter: ?struct {
            file_ids: ?[]const []const u8,
        },
        file_search: ?struct {
            vector_store_ids: ?[]const []const u8,
        },
    },
    metadata: ?Metadata,
    temperature: ?f64,
    top_p: ?f64,
    stream: ?bool,
    max_prompt_tokens: ?i64,
    max_completion_tokens: ?i64,
    truncation_strategy: ?std.json.Value,
    tool_choice: ?std.json.Value,
    parallel_tool_calls: ?ParallelToolCalls,
    response_format: ?AssistantsApiResponseFormatOption,
};
pub const CreateThreadAndRunRequestWithoutStream = struct {
    assistant_id: []const u8,
    thread: ?CreateThreadRequest,
    model: ?std.json.Value,
    instructions: ?[]const u8,
    tools: ?[]const AssistantTool,
    tool_resources: ?struct {
        code_interpreter: ?struct {
            file_ids: ?[]const []const u8,
        },
        file_search: ?struct {
            vector_store_ids: ?[]const []const u8,
        },
    },
    metadata: ?Metadata,
    temperature: ?f64,
    top_p: ?f64,
    max_prompt_tokens: ?i64,
    max_completion_tokens: ?i64,
    truncation_strategy: ?std.json.Value,
    tool_choice: ?std.json.Value,
    parallel_tool_calls: ?ParallelToolCalls,
    response_format: ?AssistantsApiResponseFormatOption,
};
pub const CreateThreadRequest = struct {
    messages: ?[]const CreateMessageRequest,
    tool_resources: ?std.json.Value,
    metadata: ?Metadata,
};
pub const CreateTranscriptionRequest = struct {
    file: []const u8,
    model: std.json.Value,
    language: ?[]const u8,
    prompt: ?[]const u8,
    response_format: ?AudioResponseFormat,
    temperature: ?f64,
    include: ?[]const TranscriptionInclude,
    timestamp_granularities: ?[]const []const u8,
    stream: ?std.json.Value,
    chunking_strategy: ?TranscriptionChunkingStrategy,
    known_speaker_names: ?[]const []const u8,
    known_speaker_references: ?[]const []const u8,
};
pub const CreateTranscriptionResponseDiarizedJson = struct {
    task: []const u8,
    duration: f64,
    text: []const u8,
    segments: []const TranscriptionDiarizedSegment,
    usage: ?std.json.Value,
};
pub const CreateTranscriptionResponseJson = struct {
    text: []const u8,
    logprobs: ?[]const struct {
        token: ?[]const u8,
        logprob: ?f64,
        bytes: ?[]const f64,
    },
    usage: ?std.json.Value,
};
pub const CreateTranscriptionResponseStreamEvent = std.json.Value;
pub const CreateTranscriptionResponseVerboseJson = struct {
    language: []const u8,
    duration: f64,
    text: []const u8,
    words: ?[]const TranscriptionWord,
    segments: ?[]const TranscriptionSegment,
    usage: ?TranscriptTextUsageDuration,
};
pub const CreateTranslationRequest = struct {
    file: []const u8,
    model: std.json.Value,
    prompt: ?[]const u8,
    response_format: ?[]const u8,
    temperature: ?f64,
};
pub const CreateTranslationResponseJson = struct {
    text: []const u8,
};
pub const CreateTranslationResponseVerboseJson = struct {
    language: []const u8,
    duration: f64,
    text: []const u8,
    segments: ?[]const TranscriptionSegment,
};
pub const CreateUploadRequest = struct {
    filename: []const u8,
    purpose: []const u8,
    bytes: i64,
    mime_type: []const u8,
    expires_after: ?FileExpirationAfter,
};
pub const CreateVectorStoreFileBatchRequest = struct {
    file_ids: ?[]const []const u8,
    files: ?[]const CreateVectorStoreFileRequest,
    chunking_strategy: ?ChunkingStrategyRequestParam,
    attributes: ?VectorStoreFileAttributes,
};
pub const CreateVectorStoreFileRequest = struct {
    file_id: []const u8,
    chunking_strategy: ?ChunkingStrategyRequestParam,
    attributes: ?VectorStoreFileAttributes,
};
pub const CreateVectorStoreRequest = struct {
    file_ids: ?[]const []const u8,
    name: ?[]const u8,
    description: ?[]const u8,
    expires_after: ?VectorStoreExpirationAfter,
    chunking_strategy: ?ChunkingStrategyRequestParam,
    metadata: ?Metadata,
};
pub const CreateVideoBody = struct {
    model: ?VideoModel,
    prompt: []const u8,
    input_reference: ?[]const u8,
    seconds: ?VideoSeconds,
    size: ?VideoSize,
};
pub const CreateVideoRemixBody = struct {
    prompt: []const u8,
};
pub const CreateVoiceConsentRequest = struct {
    name: []const u8,
    recording: []const u8,
    language: []const u8,
};
pub const CreateVoiceRequest = struct {
    name: []const u8,
    audio_sample: []const u8,
    consent: []const u8,
};
pub const CustomGrammarFormatParam = struct {
    type: []const u8,
    syntax: GrammarSyntax1,
    definition: []const u8,
};
pub const CustomTextFormatParam = struct {
    type: []const u8,
};
pub const CustomToolCall = struct {
    type: []const u8,
    id: ?[]const u8,
    call_id: []const u8,
    name: []const u8,
    input: []const u8,
};
pub const CustomToolCallOutput = struct {
    type: []const u8,
    id: ?[]const u8,
    call_id: []const u8,
    output: std.json.Value,
};
pub const CustomToolChatCompletions = struct {
    type: []const u8,
    custom: struct {
        name: []const u8,
        description: ?[]const u8,
        format: ?std.json.Value,
    },
};
pub const CustomToolParam = struct {
    type: []const u8,
    name: []const u8,
    description: ?[]const u8,
    format: ?std.json.Value,
};
pub const DeleteAssistantResponse = struct {
    id: []const u8,
    deleted: bool,
    object: []const u8,
};
pub const DeleteCertificateResponse = struct {
    object: std.json.Value,
    id: []const u8,
};
pub const DeleteFileResponse = struct {
    id: []const u8,
    object: []const u8,
    deleted: bool,
};
pub const DeleteFineTuningCheckpointPermissionResponse = struct {
    id: []const u8,
    object: []const u8,
    deleted: bool,
};
pub const DeleteMessageResponse = struct {
    id: []const u8,
    deleted: bool,
    object: []const u8,
};
pub const DeleteModelResponse = struct {
    id: []const u8,
    deleted: bool,
    object: []const u8,
};
pub const DeleteThreadResponse = struct {
    id: []const u8,
    deleted: bool,
    object: []const u8,
};
pub const DeleteVectorStoreFileResponse = struct {
    id: []const u8,
    deleted: bool,
    object: []const u8,
};
pub const DeleteVectorStoreResponse = struct {
    id: []const u8,
    deleted: bool,
    object: []const u8,
};
pub const DeletedConversation = std.json.Value;
pub const DeletedConversationResource = struct {
    object: []const u8,
    deleted: bool,
    id: []const u8,
};
pub const DeletedRoleAssignmentResource = struct {
    object: []const u8,
    deleted: bool,
};
pub const DeletedThreadResource = struct {
    id: []const u8,
    object: []const u8,
    deleted: bool,
};
pub const DeletedVideoResource = struct {
    object: []const u8,
    deleted: bool,
    id: []const u8,
};
pub const DetailEnum = []const u8;
pub const DoneEvent = struct {
    event: []const u8,
    data: []const u8,
};
pub const DoubleClickAction = struct {
    type: []const u8,
    x: i64,
    y: i64,
};
pub const Drag = struct {
    type: []const u8,
    path: []const DragPoint,
};
pub const DragPoint = struct {
    x: i64,
    y: i64,
};
pub const EasyInputMessage = struct {
    role: []const u8,
    content: std.json.Value,
    type: ?[]const u8,
};
pub const Embedding = struct {
    index: i64,
    embedding: []const f64,
    object: []const u8,
};
pub const Error = struct {
    code: std.json.Value,
    message: []const u8,
    param: std.json.Value,
    type: []const u8,
};
pub const Error_2 = struct {
    code: []const u8,
    message: []const u8,
};
pub const ErrorEvent = struct {
    event: []const u8,
    data: Error,
};
pub const ErrorResponse = struct {
    _error: Error,
};
pub const Eval = struct {
    object: []const u8,
    id: []const u8,
    name: []const u8,
    data_source_config: std.json.Value,
    testing_criteria: []const std.json.Value,
    created_at: i64,
    metadata: Metadata,
};
pub const EvalApiError = struct {
    code: []const u8,
    message: []const u8,
};
pub const EvalCustomDataSourceConfig = struct {
    type: []const u8,
    schema: std.json.Value,
};
pub const EvalGraderLabelModel = std.json.Value;
pub const EvalGraderPython = std.json.Value;
pub const EvalGraderScoreModel = std.json.Value;
pub const EvalGraderStringCheck = std.json.Value;
pub const EvalGraderTextSimilarity = std.json.Value;
pub const EvalItem = struct {
    role: []const u8,
    content: EvalItemContent,
    type: ?[]const u8,
};
pub const EvalItemContent = std.json.Value;
pub const EvalItemContentArray = []const EvalItemContentItem;
pub const EvalItemContentItem = std.json.Value;
pub const EvalItemContentOutputText = struct {
    type: []const u8,
    text: []const u8,
};
pub const EvalItemContentText = []const u8;
pub const EvalItemInputImage = struct {
    type: []const u8,
    image_url: []const u8,
    detail: ?[]const u8,
};
pub const EvalJsonlFileContentSource = struct {
    type: []const u8,
    content: []const struct {
        item: std.json.Value,
        sample: ?std.json.Value,
    },
};
pub const EvalJsonlFileIdSource = struct {
    type: []const u8,
    id: []const u8,
};
pub const EvalList = struct {
    object: []const u8,
    data: []const Eval,
    first_id: []const u8,
    last_id: []const u8,
    has_more: bool,
};
pub const EvalLogsDataSourceConfig = struct {
    type: []const u8,
    metadata: ?Metadata,
    schema: std.json.Value,
};
pub const EvalResponsesSource = struct {
    type: []const u8,
    metadata: ?std.json.Value,
    model: ?std.json.Value,
    instructions_search: ?std.json.Value,
    created_after: ?std.json.Value,
    created_before: ?std.json.Value,
    reasoning_effort: ?std.json.Value,
    temperature: ?std.json.Value,
    top_p: ?std.json.Value,
    users: ?std.json.Value,
    tools: ?std.json.Value,
};
pub const EvalRun = struct {
    object: []const u8,
    id: []const u8,
    eval_id: []const u8,
    status: []const u8,
    model: []const u8,
    name: []const u8,
    created_at: i64,
    report_url: []const u8,
    result_counts: struct {
        total: i64,
        errored: i64,
        failed: i64,
        passed: i64,
    },
    per_model_usage: []const struct {
        model_name: []const u8,
        invocation_count: i64,
        prompt_tokens: i64,
        completion_tokens: i64,
        total_tokens: i64,
        cached_tokens: i64,
    },
    per_testing_criteria_results: []const struct {
        testing_criteria: []const u8,
        passed: i64,
        failed: i64,
    },
    data_source: std.json.Value,
    metadata: Metadata,
    _error: EvalApiError,
};
pub const EvalRunList = struct {
    object: []const u8,
    data: []const EvalRun,
    first_id: []const u8,
    last_id: []const u8,
    has_more: bool,
};
pub const EvalRunOutputItem = struct {
    object: []const u8,
    id: []const u8,
    run_id: []const u8,
    eval_id: []const u8,
    created_at: i64,
    status: []const u8,
    datasource_item_id: i64,
    datasource_item: std.json.Value,
    results: []const EvalRunOutputItemResult,
    sample: struct {
        input: []const struct {
            role: []const u8,
            content: []const u8,
        },
        output: []const struct {
            role: ?[]const u8,
            content: ?[]const u8,
        },
        finish_reason: []const u8,
        model: []const u8,
        usage: struct {
            total_tokens: i64,
            completion_tokens: i64,
            prompt_tokens: i64,
            cached_tokens: i64,
        },
        _error: EvalApiError,
        temperature: f64,
        max_completion_tokens: i64,
        top_p: f64,
        seed: i64,
    },
};
pub const EvalRunOutputItemList = struct {
    object: []const u8,
    data: []const EvalRunOutputItem,
    first_id: []const u8,
    last_id: []const u8,
    has_more: bool,
};
pub const EvalRunOutputItemResult = struct {
    name: []const u8,
    type: ?[]const u8,
    score: f64,
    passed: bool,
    sample: ?std.json.Value,
};
pub const EvalStoredCompletionsDataSourceConfig = struct {
    type: []const u8,
    metadata: ?Metadata,
    schema: std.json.Value,
};
pub const EvalStoredCompletionsSource = struct {
    type: []const u8,
    metadata: ?Metadata,
    model: ?std.json.Value,
    created_after: ?std.json.Value,
    created_before: ?std.json.Value,
    limit: ?std.json.Value,
};
pub const ExpiresAfterParam = struct {
    anchor: []const u8,
    seconds: i64,
};
pub const FileAnnotation = struct {
    type: []const u8,
    source: FileAnnotationSource,
};
pub const FileAnnotationSource = struct {
    type: []const u8,
    filename: []const u8,
};
pub const FileCitationBody = struct {
    type: []const u8,
    file_id: []const u8,
    index: i64,
    filename: []const u8,
};
pub const FileExpirationAfter = struct {
    anchor: []const u8,
    seconds: i64,
};
pub const FilePath = struct {
    type: []const u8,
    file_id: []const u8,
    index: i64,
};
pub const FilePurpose = []const u8;
pub const FileSearchRanker = []const u8;
pub const FileSearchRankingOptions = struct {
    ranker: ?FileSearchRanker,
    score_threshold: f64,
};
pub const FileSearchTool = struct {
    type: []const u8,
    vector_store_ids: []const []const u8,
    max_num_results: ?i64,
    ranking_options: ?RankingOptions,
    filters: ?std.json.Value,
};
pub const FileSearchToolCall = struct {
    id: []const u8,
    type: []const u8,
    status: []const u8,
    queries: []const []const u8,
    results: ?std.json.Value,
};
pub const FileUploadParam = struct {
    enabled: ?bool,
    max_file_size: ?i64,
    max_files: ?i64,
};
pub const Filters = std.json.Value;
pub const FineTuneChatCompletionRequestAssistantMessage = std.json.Value;
pub const FineTuneChatRequestInput = struct {
    messages: ?[]const std.json.Value,
    tools: ?[]const ChatCompletionTool,
    parallel_tool_calls: ?ParallelToolCalls,
    functions: ?[]const ChatCompletionFunctions,
};
pub const FineTuneDPOHyperparameters = struct {
    beta: ?std.json.Value,
    batch_size: ?std.json.Value,
    learning_rate_multiplier: ?std.json.Value,
    n_epochs: ?std.json.Value,
};
pub const FineTuneDPOMethod = struct {
    hyperparameters: ?FineTuneDPOHyperparameters,
};
pub const FineTuneMethod = struct {
    type: []const u8,
    supervised: ?FineTuneSupervisedMethod,
    dpo: ?FineTuneDPOMethod,
    reinforcement: ?FineTuneReinforcementMethod,
};
pub const FineTunePreferenceRequestInput = struct {
    input: ?struct {
        messages: ?[]const std.json.Value,
        tools: ?[]const ChatCompletionTool,
        parallel_tool_calls: ?ParallelToolCalls,
    },
    preferred_output: ?[]const std.json.Value,
    non_preferred_output: ?[]const std.json.Value,
};
pub const FineTuneReinforcementHyperparameters = struct {
    batch_size: ?std.json.Value,
    learning_rate_multiplier: ?std.json.Value,
    n_epochs: ?std.json.Value,
    reasoning_effort: ?[]const u8,
    compute_multiplier: ?std.json.Value,
    eval_interval: ?std.json.Value,
    eval_samples: ?std.json.Value,
};
pub const FineTuneReinforcementMethod = struct {
    grader: std.json.Value,
    hyperparameters: ?FineTuneReinforcementHyperparameters,
};
pub const FineTuneReinforcementRequestInput = struct {
    messages: []const std.json.Value,
    tools: ?[]const ChatCompletionTool,
};
pub const FineTuneSupervisedHyperparameters = struct {
    batch_size: ?std.json.Value,
    learning_rate_multiplier: ?std.json.Value,
    n_epochs: ?std.json.Value,
};
pub const FineTuneSupervisedMethod = struct {
    hyperparameters: ?FineTuneSupervisedHyperparameters,
};
pub const FineTuningCheckpointPermission = struct {
    id: []const u8,
    created_at: i64,
    project_id: []const u8,
    object: []const u8,
};
pub const FineTuningIntegration = struct {
    type: []const u8,
    wandb: struct {
        project: []const u8,
        name: ?std.json.Value,
        entity: ?std.json.Value,
        tags: ?[]const []const u8,
    },
};
pub const FineTuningJob = struct {
    id: []const u8,
    created_at: i64,
    _error: std.json.Value,
    fine_tuned_model: std.json.Value,
    finished_at: std.json.Value,
    hyperparameters: struct {
        batch_size: ?std.json.Value,
        learning_rate_multiplier: ?std.json.Value,
        n_epochs: ?std.json.Value,
    },
    model: []const u8,
    object: []const u8,
    organization_id: []const u8,
    result_files: []const []const u8,
    status: []const u8,
    trained_tokens: std.json.Value,
    training_file: []const u8,
    validation_file: std.json.Value,
    integrations: ?std.json.Value,
    seed: i64,
    estimated_finish: ?std.json.Value,
    method: ?FineTuneMethod,
    metadata: ?Metadata,
};
pub const FineTuningJobCheckpoint = struct {
    id: []const u8,
    created_at: i64,
    fine_tuned_model_checkpoint: []const u8,
    step_number: i64,
    metrics: struct {
        step: ?f64,
        train_loss: ?f64,
        train_mean_token_accuracy: ?f64,
        valid_loss: ?f64,
        valid_mean_token_accuracy: ?f64,
        full_valid_loss: ?f64,
        full_valid_mean_token_accuracy: ?f64,
    },
    fine_tuning_job_id: []const u8,
    object: []const u8,
};
pub const FineTuningJobEvent = struct {
    object: []const u8,
    id: []const u8,
    created_at: i64,
    level: []const u8,
    message: []const u8,
    type: ?[]const u8,
    data: ?std.json.Value,
};
pub const FunctionAndCustomToolCallOutput = std.json.Value;
pub const FunctionCallItemStatus = []const u8;
pub const FunctionCallOutputItemParam = struct {
    id: ?std.json.Value,
    call_id: []const u8,
    type: []const u8,
    output: std.json.Value,
    status: ?std.json.Value,
};
pub const FunctionObject = struct {
    description: ?[]const u8,
    name: []const u8,
    parameters: ?FunctionParameters,
    strict: ?std.json.Value,
};
pub const FunctionParameters = std.json.Value;
pub const FunctionShellAction = struct {
    commands: []const []const u8,
    timeout_ms: std.json.Value,
    max_output_length: std.json.Value,
};
pub const FunctionShellActionParam = struct {
    commands: []const []const u8,
    timeout_ms: ?std.json.Value,
    max_output_length: ?std.json.Value,
};
pub const FunctionShellCall = struct {
    type: []const u8,
    id: []const u8,
    call_id: []const u8,
    action: FunctionShellAction,
    status: LocalShellCallStatus,
    created_by: ?[]const u8,
};
pub const FunctionShellCallItemParam = struct {
    id: ?std.json.Value,
    call_id: []const u8,
    type: []const u8,
    action: FunctionShellActionParam,
    status: ?std.json.Value,
};
pub const FunctionShellCallItemStatus = []const u8;
pub const FunctionShellCallOutput = struct {
    type: []const u8,
    id: []const u8,
    call_id: []const u8,
    output: []const FunctionShellCallOutputContent,
    max_output_length: std.json.Value,
    created_by: ?[]const u8,
};
pub const FunctionShellCallOutputContent = struct {
    stdout: []const u8,
    stderr: []const u8,
    outcome: std.json.Value,
    created_by: ?[]const u8,
};
pub const FunctionShellCallOutputContentParam = struct {
    stdout: []const u8,
    stderr: []const u8,
    outcome: FunctionShellCallOutputOutcomeParam,
};
pub const FunctionShellCallOutputExitOutcome = struct {
    type: []const u8,
    exit_code: i64,
};
pub const FunctionShellCallOutputExitOutcomeParam = struct {
    type: []const u8,
    exit_code: i64,
};
pub const FunctionShellCallOutputItemParam = struct {
    id: ?std.json.Value,
    call_id: []const u8,
    type: []const u8,
    output: []const FunctionShellCallOutputContentParam,
    max_output_length: ?std.json.Value,
};
pub const FunctionShellCallOutputOutcomeParam = std.json.Value;
pub const FunctionShellCallOutputTimeoutOutcome = struct {
    type: []const u8,
};
pub const FunctionShellCallOutputTimeoutOutcomeParam = struct {
    type: []const u8,
};
pub const FunctionShellToolParam = struct {
    type: []const u8,
};
pub const FunctionTool = struct {
    type: []const u8,
    name: []const u8,
    description: ?std.json.Value,
    parameters: std.json.Value,
    strict: std.json.Value,
};
pub const FunctionToolCall = struct {
    id: ?[]const u8,
    type: []const u8,
    call_id: []const u8,
    name: []const u8,
    arguments: []const u8,
    status: ?[]const u8,
};
pub const FunctionToolCallOutput = struct {
    id: ?[]const u8,
    type: []const u8,
    call_id: []const u8,
    output: std.json.Value,
    status: ?[]const u8,
};
pub const FunctionToolCallOutputResource = std.json.Value;
pub const FunctionToolCallResource = std.json.Value;
pub const GraderLabelModel = struct {
    type: []const u8,
    name: []const u8,
    model: []const u8,
    input: []const EvalItem,
    labels: []const []const u8,
    passing_labels: []const []const u8,
};
pub const GraderMulti = struct {
    type: []const u8,
    name: []const u8,
    graders: std.json.Value,
    calculate_output: []const u8,
};
pub const GraderPython = struct {
    type: []const u8,
    name: []const u8,
    source: []const u8,
    image_tag: ?[]const u8,
};
pub const GraderScoreModel = struct {
    type: []const u8,
    name: []const u8,
    model: []const u8,
    sampling_params: ?struct {
        seed: ?std.json.Value,
        top_p: ?std.json.Value,
        temperature: ?std.json.Value,
        max_completions_tokens: ?std.json.Value,
        reasoning_effort: ?ReasoningEffort,
    },
    input: []const EvalItem,
    range: ?[]const f64,
};
pub const GraderStringCheck = struct {
    type: []const u8,
    name: []const u8,
    input: []const u8,
    reference: []const u8,
    operation: []const u8,
};
pub const GraderTextSimilarity = struct {
    type: []const u8,
    name: []const u8,
    input: []const u8,
    reference: []const u8,
    evaluation_metric: []const u8,
};
pub const GrammarSyntax1 = []const u8;
pub const Group = struct {
    object: []const u8,
    id: []const u8,
    name: []const u8,
    created_at: i64,
    scim_managed: bool,
};
pub const GroupDeletedResource = struct {
    object: []const u8,
    id: []const u8,
    deleted: bool,
};
pub const GroupListResource = struct {
    object: []const u8,
    data: []const GroupResponse,
    has_more: bool,
    next: std.json.Value,
};
pub const GroupResourceWithSuccess = struct {
    id: []const u8,
    name: []const u8,
    created_at: i64,
    is_scim_managed: bool,
};
pub const GroupResponse = struct {
    id: []const u8,
    name: []const u8,
    created_at: i64,
    is_scim_managed: bool,
};
pub const GroupRoleAssignment = struct {
    object: []const u8,
    group: Group,
    role: Role,
};
pub const GroupUserAssignment = struct {
    object: []const u8,
    user_id: []const u8,
    group_id: []const u8,
};
pub const GroupUserDeletedResource = struct {
    object: []const u8,
    deleted: bool,
};
pub const HistoryParam = struct {
    enabled: ?bool,
    recent_threads: ?i64,
};
pub const HybridSearchOptions = struct {
    embedding_weight: f64,
    text_weight: f64,
};
pub const Image = struct {
    b64_json: ?[]const u8,
    url: ?[]const u8,
    revised_prompt: ?[]const u8,
};
pub const ImageDetail = []const u8;
pub const ImageEditCompletedEvent = struct {
    type: []const u8,
    b64_json: []const u8,
    created_at: i64,
    size: []const u8,
    quality: []const u8,
    background: []const u8,
    output_format: []const u8,
    usage: ImagesUsage,
};
pub const ImageEditPartialImageEvent = struct {
    type: []const u8,
    b64_json: []const u8,
    created_at: i64,
    size: []const u8,
    quality: []const u8,
    background: []const u8,
    output_format: []const u8,
    partial_image_index: i64,
};
pub const ImageEditStreamEvent = std.json.Value;
pub const ImageGenCompletedEvent = struct {
    type: []const u8,
    b64_json: []const u8,
    created_at: i64,
    size: []const u8,
    quality: []const u8,
    background: []const u8,
    output_format: []const u8,
    usage: ImagesUsage,
};
pub const ImageGenInputUsageDetails = struct {
    text_tokens: i64,
    image_tokens: i64,
};
pub const ImageGenOutputTokensDetails = struct {
    image_tokens: i64,
    text_tokens: i64,
};
pub const ImageGenPartialImageEvent = struct {
    type: []const u8,
    b64_json: []const u8,
    created_at: i64,
    size: []const u8,
    quality: []const u8,
    background: []const u8,
    output_format: []const u8,
    partial_image_index: i64,
};
pub const ImageGenStreamEvent = std.json.Value;
pub const ImageGenTool = struct {
    type: []const u8,
    model: ?std.json.Value,
    quality: ?[]const u8,
    size: ?[]const u8,
    output_format: ?[]const u8,
    output_compression: ?i64,
    moderation: ?[]const u8,
    background: ?[]const u8,
    input_fidelity: ?std.json.Value,
    input_image_mask: ?struct {
        image_url: ?[]const u8,
        file_id: ?[]const u8,
    },
    partial_images: ?i64,
};
pub const ImageGenToolCall = struct {
    type: []const u8,
    id: []const u8,
    status: []const u8,
    result: std.json.Value,
};
pub const ImageGenUsage = struct {
    input_tokens: i64,
    total_tokens: i64,
    output_tokens: i64,
    output_tokens_details: ?ImageGenOutputTokensDetails,
    input_tokens_details: ImageGenInputUsageDetails,
};
pub const ImagesResponse = struct {
    created: i64,
    data: ?[]const Image,
    background: ?[]const u8,
    output_format: ?[]const u8,
    size: ?[]const u8,
    quality: ?[]const u8,
    usage: ?ImageGenUsage,
};
pub const ImagesUsage = struct {
    total_tokens: i64,
    input_tokens: i64,
    output_tokens: i64,
    input_tokens_details: struct {
        text_tokens: i64,
        image_tokens: i64,
    },
};
pub const IncludeEnum = []const u8;
pub const InferenceOptions = struct {
    tool_choice: std.json.Value,
    model: std.json.Value,
};
pub const InputAudio = struct {
    type: []const u8,
    input_audio: struct {
        data: []const u8,
        format: []const u8,
    },
};
pub const InputContent = std.json.Value;
pub const InputFidelity = []const u8;
pub const InputFileContent = struct {
    type: []const u8,
    file_id: ?std.json.Value,
    filename: ?[]const u8,
    file_url: ?[]const u8,
    file_data: ?[]const u8,
};
pub const InputFileContentParam = struct {
    type: []const u8,
    file_id: ?std.json.Value,
    filename: ?std.json.Value,
    file_data: ?std.json.Value,
    file_url: ?std.json.Value,
};
pub const InputImageContent = struct {
    type: []const u8,
    image_url: ?std.json.Value,
    file_id: ?std.json.Value,
    detail: ImageDetail,
};
pub const InputImageContentParamAutoParam = struct {
    type: []const u8,
    image_url: ?std.json.Value,
    file_id: ?std.json.Value,
    detail: ?std.json.Value,
};
pub const InputItem = std.json.Value;
pub const InputMessage = struct {
    type: ?[]const u8,
    role: []const u8,
    status: ?[]const u8,
    content: InputMessageContentList,
};
pub const InputMessageContentList = []const InputContent;
pub const InputMessageResource = std.json.Value;
pub const InputParam = std.json.Value;
pub const InputTextContent = struct {
    type: []const u8,
    text: []const u8,
};
pub const InputTextContentParam = struct {
    type: []const u8,
    text: []const u8,
};
pub const Invite = struct {
    object: []const u8,
    id: []const u8,
    email: []const u8,
    role: []const u8,
    status: []const u8,
    invited_at: i64,
    expires_at: i64,
    accepted_at: ?i64,
    projects: ?[]const struct {
        id: ?[]const u8,
        role: ?[]const u8,
    },
};
pub const InviteDeleteResponse = struct {
    object: []const u8,
    id: []const u8,
    deleted: bool,
};
pub const InviteListResponse = struct {
    object: []const u8,
    data: []const Invite,
    first_id: ?[]const u8,
    last_id: ?[]const u8,
    has_more: ?bool,
};
pub const InviteProjectGroupBody = struct {
    group_id: []const u8,
    role: []const u8,
};
pub const InviteRequest = struct {
    email: []const u8,
    role: []const u8,
    projects: ?[]const struct {
        id: []const u8,
        role: []const u8,
    },
};
pub const Item = std.json.Value;
pub const ItemField = std.json.Value;
pub const ItemReferenceParam = struct {
    type: ?std.json.Value,
    id: []const u8,
};
pub const ItemResource = std.json.Value;
pub const KeyPressAction = struct {
    type: []const u8,
    keys: []const []const u8,
};
pub const ListAssistantsResponse = struct {
    object: []const u8,
    data: []const AssistantObject,
    first_id: []const u8,
    last_id: []const u8,
    has_more: bool,
};
pub const ListAuditLogsResponse = struct {
    object: []const u8,
    data: []const AuditLog,
    first_id: []const u8,
    last_id: []const u8,
    has_more: bool,
};
pub const ListBatchesResponse = struct {
    data: []const Batch,
    first_id: ?[]const u8,
    last_id: ?[]const u8,
    has_more: bool,
    object: []const u8,
};
pub const ListCertificatesResponse = struct {
    data: []const Certificate,
    first_id: ?[]const u8,
    last_id: ?[]const u8,
    has_more: bool,
    object: []const u8,
};
pub const ListFilesResponse = struct {
    object: []const u8,
    data: []const OpenAIFile,
    first_id: []const u8,
    last_id: []const u8,
    has_more: bool,
};
pub const ListFineTuningCheckpointPermissionResponse = struct {
    data: []const FineTuningCheckpointPermission,
    object: []const u8,
    first_id: ?std.json.Value,
    last_id: ?std.json.Value,
    has_more: bool,
};
pub const ListFineTuningJobCheckpointsResponse = struct {
    data: []const FineTuningJobCheckpoint,
    object: []const u8,
    first_id: ?std.json.Value,
    last_id: ?std.json.Value,
    has_more: bool,
};
pub const ListFineTuningJobEventsResponse = struct {
    data: []const FineTuningJobEvent,
    object: []const u8,
    has_more: bool,
};
pub const ListMessagesResponse = std.json.Value;
pub const ListModelsResponse = struct {
    object: []const u8,
    data: []const Model,
};
pub const ListPaginatedFineTuningJobsResponse = struct {
    data: []const FineTuningJob,
    has_more: bool,
    object: []const u8,
};
pub const ListRunStepsResponse = std.json.Value;
pub const ListRunsResponse = struct {
    object: []const u8,
    data: []const RunObject,
    first_id: []const u8,
    last_id: []const u8,
    has_more: bool,
};
pub const ListVectorStoreFilesResponse = std.json.Value;
pub const ListVectorStoresResponse = std.json.Value;
pub const LocalShellCallStatus = []const u8;
pub const LocalShellExecAction = struct {
    type: []const u8,
    command: []const []const u8,
    timeout_ms: ?std.json.Value,
    working_directory: ?std.json.Value,
    env: std.json.Value,
    user: ?std.json.Value,
};
pub const LocalShellToolCall = struct {
    type: []const u8,
    id: []const u8,
    call_id: []const u8,
    action: LocalShellExecAction,
    status: []const u8,
};
pub const LocalShellToolCallOutput = struct {
    type: []const u8,
    id: []const u8,
    output: []const u8,
    status: ?std.json.Value,
};
pub const LocalShellToolParam = struct {
    type: []const u8,
};
pub const LockedStatus = struct {
    type: []const u8,
    reason: std.json.Value,
};
pub const LogProb = struct {
    token: []const u8,
    logprob: f64,
    bytes: []const i64,
    top_logprobs: []const TopLogProb,
};
pub const LogProbProperties = struct {
    token: []const u8,
    logprob: f64,
    bytes: []const i64,
};
pub const MCPApprovalRequest = struct {
    type: []const u8,
    id: []const u8,
    server_label: []const u8,
    name: []const u8,
    arguments: []const u8,
};
pub const MCPApprovalResponse = struct {
    type: []const u8,
    id: ?std.json.Value,
    approval_request_id: []const u8,
    approve: bool,
    reason: ?std.json.Value,
};
pub const MCPApprovalResponseResource = struct {
    type: []const u8,
    id: []const u8,
    approval_request_id: []const u8,
    approve: bool,
    reason: ?std.json.Value,
};
pub const MCPListTools = struct {
    type: []const u8,
    id: []const u8,
    server_label: []const u8,
    tools: []const MCPListToolsTool,
    _error: ?std.json.Value,
};
pub const MCPListToolsTool = struct {
    name: []const u8,
    description: ?std.json.Value,
    input_schema: std.json.Value,
    annotations: ?std.json.Value,
};
pub const MCPTool = struct {
    type: []const u8,
    server_label: []const u8,
    server_url: ?[]const u8,
    connector_id: ?[]const u8,
    authorization: ?[]const u8,
    server_description: ?[]const u8,
    headers: ?std.json.Value,
    allowed_tools: ?std.json.Value,
    require_approval: ?std.json.Value,
};
pub const MCPToolCall = struct {
    type: []const u8,
    id: []const u8,
    server_label: []const u8,
    name: []const u8,
    arguments: []const u8,
    output: ?std.json.Value,
    _error: ?std.json.Value,
    status: ?MCPToolCallStatus,
    approval_request_id: ?std.json.Value,
};
pub const MCPToolCallStatus = []const u8;
pub const MCPToolFilter = struct {
    tool_names: ?[]const []const u8,
    read_only: ?bool,
};
pub const Message = struct {
    type: []const u8,
    id: []const u8,
    status: MessageStatus,
    role: MessageRole,
    content: []const std.json.Value,
};
pub const MessageContent = std.json.Value;
pub const MessageContentDelta = std.json.Value;
pub const MessageContentImageFileObject = struct {
    type: []const u8,
    image_file: struct {
        file_id: []const u8,
        detail: ?[]const u8,
    },
};
pub const MessageContentImageUrlObject = struct {
    type: []const u8,
    image_url: struct {
        url: []const u8,
        detail: ?[]const u8,
    },
};
pub const MessageContentRefusalObject = struct {
    type: []const u8,
    refusal: []const u8,
};
pub const MessageContentTextAnnotationsFileCitationObject = struct {
    type: []const u8,
    text: []const u8,
    file_citation: struct {
        file_id: []const u8,
    },
    start_index: i64,
    end_index: i64,
};
pub const MessageContentTextAnnotationsFilePathObject = struct {
    type: []const u8,
    text: []const u8,
    file_path: struct {
        file_id: []const u8,
    },
    start_index: i64,
    end_index: i64,
};
pub const MessageContentTextObject = struct {
    type: []const u8,
    text: struct {
        value: []const u8,
        annotations: []const TextAnnotation,
    },
};
pub const MessageDeltaContentImageFileObject = struct {
    index: i64,
    type: []const u8,
    image_file: ?struct {
        file_id: ?[]const u8,
        detail: ?[]const u8,
    },
};
pub const MessageDeltaContentImageUrlObject = struct {
    index: i64,
    type: []const u8,
    image_url: ?struct {
        url: ?[]const u8,
        detail: ?[]const u8,
    },
};
pub const MessageDeltaContentRefusalObject = struct {
    index: i64,
    type: []const u8,
    refusal: ?[]const u8,
};
pub const MessageDeltaContentTextAnnotationsFileCitationObject = struct {
    index: i64,
    type: []const u8,
    text: ?[]const u8,
    file_citation: ?struct {
        file_id: ?[]const u8,
        quote: ?[]const u8,
    },
    start_index: ?i64,
    end_index: ?i64,
};
pub const MessageDeltaContentTextAnnotationsFilePathObject = struct {
    index: i64,
    type: []const u8,
    text: ?[]const u8,
    file_path: ?struct {
        file_id: ?[]const u8,
    },
    start_index: ?i64,
    end_index: ?i64,
};
pub const MessageDeltaContentTextObject = struct {
    index: i64,
    type: []const u8,
    text: ?struct {
        value: ?[]const u8,
        annotations: ?[]const TextAnnotationDelta,
    },
};
pub const MessageDeltaObject = struct {
    id: []const u8,
    object: []const u8,
    delta: struct {
        role: ?[]const u8,
        content: ?[]const MessageContentDelta,
    },
};
pub const MessageObject = struct {
    id: []const u8,
    object: []const u8,
    created_at: i64,
    thread_id: []const u8,
    status: []const u8,
    incomplete_details: std.json.Value,
    completed_at: std.json.Value,
    incomplete_at: std.json.Value,
    role: []const u8,
    content: []const MessageContent,
    assistant_id: std.json.Value,
    run_id: std.json.Value,
    attachments: std.json.Value,
    metadata: Metadata,
};
pub const MessageRequestContentTextObject = struct {
    type: []const u8,
    text: []const u8,
};
pub const MessageRole = []const u8;
pub const MessageStatus = []const u8;
pub const MessageStreamEvent = std.json.Value;
pub const Metadata = std.json.Value;
pub const Model = std.json.Value;
pub const ModelIds = std.json.Value;
pub const ModelIdsCompaction = std.json.Value;
pub const ModelIdsResponses = std.json.Value;
pub const ModelIdsShared = std.json.Value;
pub const ModelResponseProperties = struct {
    metadata: ?Metadata,
    top_logprobs: ?std.json.Value,
    temperature: ?std.json.Value,
    top_p: ?std.json.Value,
    user: ?[]const u8,
    safety_identifier: ?[]const u8,
    prompt_cache_key: ?[]const u8,
    service_tier: ?ServiceTier,
    prompt_cache_retention: ?std.json.Value,
};
pub const ModerationImageURLInput = struct {
    type: []const u8,
    image_url: struct {
        url: []const u8,
    },
};
pub const ModerationTextInput = struct {
    type: []const u8,
    text: []const u8,
};
pub const ModifyAssistantRequest = struct {
    model: ?std.json.Value,
    reasoning_effort: ?ReasoningEffort,
    name: ?std.json.Value,
    description: ?std.json.Value,
    instructions: ?std.json.Value,
    tools: ?[]const AssistantTool,
    tool_resources: ?std.json.Value,
    metadata: ?Metadata,
    temperature: ?std.json.Value,
    top_p: ?std.json.Value,
    response_format: ?std.json.Value,
};
pub const ModifyCertificateRequest = struct {
    name: []const u8,
};
pub const ModifyMessageRequest = struct {
    metadata: ?Metadata,
};
pub const ModifyRunRequest = struct {
    metadata: ?Metadata,
};
pub const ModifyThreadRequest = struct {
    tool_resources: ?std.json.Value,
    metadata: ?Metadata,
};
pub const Move = struct {
    type: []const u8,
    x: i64,
    y: i64,
};
pub const NoiseReductionType = []const u8;
pub const OpenAIFile = std.json.Value;
pub const OrderEnum = []const u8;
pub const OtherChunkingStrategyResponseParam = struct {
    type: []const u8,
};
pub const OutputAudio = struct {
    type: []const u8,
    data: []const u8,
    transcript: []const u8,
};
pub const OutputContent = std.json.Value;
pub const OutputItem = std.json.Value;
pub const OutputMessage = struct {
    id: []const u8,
    type: []const u8,
    role: []const u8,
    content: []const OutputMessageContent,
    status: []const u8,
};
pub const OutputMessageContent = std.json.Value;
pub const OutputTextContent = struct {
    type: []const u8,
    text: []const u8,
    annotations: []const Annotation,
    logprobs: ?[]const LogProb,
};
pub const ParallelToolCalls = bool;
pub const PartialImages = std.json.Value;
pub const PredictionContent = struct {
    type: []const u8,
    content: std.json.Value,
};
pub const Project = struct {
    id: []const u8,
    object: []const u8,
    name: []const u8,
    created_at: i64,
    archived_at: ?std.json.Value,
    status: []const u8,
};
pub const ProjectApiKey = struct {
    object: []const u8,
    redacted_value: []const u8,
    name: []const u8,
    created_at: i64,
    last_used_at: i64,
    id: []const u8,
    owner: struct {
        type: ?[]const u8,
        user: ?ProjectUser,
        service_account: ?ProjectServiceAccount,
    },
};
pub const ProjectApiKeyDeleteResponse = struct {
    object: []const u8,
    id: []const u8,
    deleted: bool,
};
pub const ProjectApiKeyListResponse = struct {
    object: []const u8,
    data: []const ProjectApiKey,
    first_id: []const u8,
    last_id: []const u8,
    has_more: bool,
};
pub const ProjectCreateRequest = struct {
    name: []const u8,
    geography: ?[]const u8,
};
pub const ProjectGroup = struct {
    object: []const u8,
    project_id: []const u8,
    group_id: []const u8,
    group_name: []const u8,
    created_at: i64,
};
pub const ProjectGroupDeletedResource = struct {
    object: []const u8,
    deleted: bool,
};
pub const ProjectGroupListResource = struct {
    object: []const u8,
    data: []const ProjectGroup,
    has_more: bool,
    next: std.json.Value,
};
pub const ProjectListResponse = struct {
    object: []const u8,
    data: []const Project,
    first_id: []const u8,
    last_id: []const u8,
    has_more: bool,
};
pub const ProjectRateLimit = struct {
    object: []const u8,
    id: []const u8,
    model: []const u8,
    max_requests_per_1_minute: i64,
    max_tokens_per_1_minute: i64,
    max_images_per_1_minute: ?i64,
    max_audio_megabytes_per_1_minute: ?i64,
    max_requests_per_1_day: ?i64,
    batch_1_day_max_input_tokens: ?i64,
};
pub const ProjectRateLimitListResponse = struct {
    object: []const u8,
    data: []const ProjectRateLimit,
    first_id: []const u8,
    last_id: []const u8,
    has_more: bool,
};
pub const ProjectRateLimitUpdateRequest = struct {
    max_requests_per_1_minute: ?i64,
    max_tokens_per_1_minute: ?i64,
    max_images_per_1_minute: ?i64,
    max_audio_megabytes_per_1_minute: ?i64,
    max_requests_per_1_day: ?i64,
    batch_1_day_max_input_tokens: ?i64,
};
pub const ProjectServiceAccount = struct {
    object: []const u8,
    id: []const u8,
    name: []const u8,
    role: []const u8,
    created_at: i64,
};
pub const ProjectServiceAccountApiKey = struct {
    object: []const u8,
    value: []const u8,
    name: []const u8,
    created_at: i64,
    id: []const u8,
};
pub const ProjectServiceAccountCreateRequest = struct {
    name: []const u8,
};
pub const ProjectServiceAccountCreateResponse = struct {
    object: []const u8,
    id: []const u8,
    name: []const u8,
    role: []const u8,
    created_at: i64,
    api_key: ProjectServiceAccountApiKey,
};
pub const ProjectServiceAccountDeleteResponse = struct {
    object: []const u8,
    id: []const u8,
    deleted: bool,
};
pub const ProjectServiceAccountListResponse = struct {
    object: []const u8,
    data: []const ProjectServiceAccount,
    first_id: []const u8,
    last_id: []const u8,
    has_more: bool,
};
pub const ProjectUpdateRequest = struct {
    name: []const u8,
};
pub const ProjectUser = struct {
    object: []const u8,
    id: []const u8,
    name: []const u8,
    email: []const u8,
    role: []const u8,
    added_at: i64,
};
pub const ProjectUserCreateRequest = struct {
    user_id: []const u8,
    role: []const u8,
};
pub const ProjectUserDeleteResponse = struct {
    object: []const u8,
    id: []const u8,
    deleted: bool,
};
pub const ProjectUserListResponse = struct {
    object: []const u8,
    data: []const ProjectUser,
    first_id: []const u8,
    last_id: []const u8,
    has_more: bool,
};
pub const ProjectUserUpdateRequest = struct {
    role: []const u8,
};
pub const Prompt = std.json.Value;
pub const PublicAssignOrganizationGroupRoleBody = struct {
    role_id: []const u8,
};
pub const PublicCreateOrganizationRoleBody = struct {
    role_name: []const u8,
    permissions: []const []const u8,
    description: ?std.json.Value,
};
pub const PublicRoleListResource = struct {
    object: []const u8,
    data: []const Role,
    has_more: bool,
    next: std.json.Value,
};
pub const PublicUpdateOrganizationRoleBody = struct {
    permissions: ?std.json.Value,
    description: ?std.json.Value,
    role_name: ?std.json.Value,
};
pub const RankerVersionType = []const u8;
pub const RankingOptions = struct {
    ranker: ?RankerVersionType,
    score_threshold: ?f64,
    hybrid_search: ?HybridSearchOptions,
};
pub const RateLimitsParam = struct {
    max_requests_per_1_minute: ?i64,
};
pub const RealtimeAudioFormats = std.json.Value;
pub const RealtimeBetaClientEventConversationItemCreate = struct {
    event_id: ?[]const u8,
    type: std.json.Value,
    previous_item_id: ?[]const u8,
    item: RealtimeConversationItem,
};
pub const RealtimeBetaClientEventConversationItemDelete = struct {
    event_id: ?[]const u8,
    type: std.json.Value,
    item_id: []const u8,
};
pub const RealtimeBetaClientEventConversationItemRetrieve = struct {
    event_id: ?[]const u8,
    type: std.json.Value,
    item_id: []const u8,
};
pub const RealtimeBetaClientEventConversationItemTruncate = struct {
    event_id: ?[]const u8,
    type: std.json.Value,
    item_id: []const u8,
    content_index: i64,
    audio_end_ms: i64,
};
pub const RealtimeBetaClientEventInputAudioBufferAppend = struct {
    event_id: ?[]const u8,
    type: std.json.Value,
    audio: []const u8,
};
pub const RealtimeBetaClientEventInputAudioBufferClear = struct {
    event_id: ?[]const u8,
    type: std.json.Value,
};
pub const RealtimeBetaClientEventInputAudioBufferCommit = struct {
    event_id: ?[]const u8,
    type: std.json.Value,
};
pub const RealtimeBetaClientEventOutputAudioBufferClear = struct {
    event_id: ?[]const u8,
    type: std.json.Value,
};
pub const RealtimeBetaClientEventResponseCancel = struct {
    event_id: ?[]const u8,
    type: std.json.Value,
    response_id: ?[]const u8,
};
pub const RealtimeBetaClientEventResponseCreate = struct {
    event_id: ?[]const u8,
    type: std.json.Value,
    response: ?RealtimeBetaResponseCreateParams,
};
pub const RealtimeBetaClientEventSessionUpdate = struct {
    event_id: ?[]const u8,
    type: std.json.Value,
    session: RealtimeSessionCreateRequest,
};
pub const RealtimeBetaClientEventTranscriptionSessionUpdate = struct {
    event_id: ?[]const u8,
    type: std.json.Value,
    session: RealtimeTranscriptionSessionCreateRequest,
};
pub const RealtimeBetaResponse = struct {
    id: ?[]const u8,
    object: ?std.json.Value,
    status: ?[]const u8,
    status_details: ?struct {
        type: ?[]const u8,
        reason: ?[]const u8,
        _error: ?struct {
            type: ?[]const u8,
            code: ?[]const u8,
        },
    },
    output: ?[]const RealtimeConversationItem,
    metadata: ?Metadata,
    usage: ?struct {
        total_tokens: ?i64,
        input_tokens: ?i64,
        output_tokens: ?i64,
        input_token_details: ?struct {
            cached_tokens: ?i64,
            text_tokens: ?i64,
            image_tokens: ?i64,
            audio_tokens: ?i64,
            cached_tokens_details: ?struct {
                text_tokens: ?i64,
                image_tokens: ?i64,
                audio_tokens: ?i64,
            },
        },
        output_token_details: ?struct {
            text_tokens: ?i64,
            audio_tokens: ?i64,
        },
    },
    conversation_id: ?[]const u8,
    voice: ?VoiceIdsShared,
    modalities: ?[]const []const u8,
    output_audio_format: ?[]const u8,
    temperature: ?f64,
    max_output_tokens: ?std.json.Value,
};
pub const RealtimeBetaResponseCreateParams = struct {
    modalities: ?[]const []const u8,
    instructions: ?[]const u8,
    voice: ?VoiceIdsShared,
    output_audio_format: ?[]const u8,
    tools: ?[]const struct {
        type: ?[]const u8,
        name: ?[]const u8,
        description: ?[]const u8,
        parameters: ?std.json.Value,
    },
    tool_choice: ?std.json.Value,
    temperature: ?f64,
    max_output_tokens: ?std.json.Value,
    conversation: ?std.json.Value,
    metadata: ?Metadata,
    prompt: ?Prompt,
    input: ?[]const RealtimeConversationItem,
};
pub const RealtimeBetaServerEventConversationItemCreated = struct {
    event_id: []const u8,
    type: std.json.Value,
    previous_item_id: ?std.json.Value,
    item: RealtimeConversationItem,
};
pub const RealtimeBetaServerEventConversationItemDeleted = struct {
    event_id: []const u8,
    type: std.json.Value,
    item_id: []const u8,
};
pub const RealtimeBetaServerEventConversationItemInputAudioTranscriptionCompleted = struct {
    event_id: []const u8,
    type: []const u8,
    item_id: []const u8,
    content_index: i64,
    transcript: []const u8,
    logprobs: ?std.json.Value,
    usage: std.json.Value,
};
pub const RealtimeBetaServerEventConversationItemInputAudioTranscriptionDelta = struct {
    event_id: []const u8,
    type: std.json.Value,
    item_id: []const u8,
    content_index: ?i64,
    delta: ?[]const u8,
    logprobs: ?std.json.Value,
};
pub const RealtimeBetaServerEventConversationItemInputAudioTranscriptionFailed = struct {
    event_id: []const u8,
    type: []const u8,
    item_id: []const u8,
    content_index: i64,
    _error: struct {
        type: ?[]const u8,
        code: ?[]const u8,
        message: ?[]const u8,
        param: ?[]const u8,
    },
};
pub const RealtimeBetaServerEventConversationItemInputAudioTranscriptionSegment = struct {
    event_id: []const u8,
    type: std.json.Value,
    item_id: []const u8,
    content_index: i64,
    text: []const u8,
    id: []const u8,
    speaker: []const u8,
    start: f64,
    end: f64,
};
pub const RealtimeBetaServerEventConversationItemRetrieved = struct {
    event_id: []const u8,
    type: std.json.Value,
    item: RealtimeConversationItem,
};
pub const RealtimeBetaServerEventConversationItemTruncated = struct {
    event_id: []const u8,
    type: std.json.Value,
    item_id: []const u8,
    content_index: i64,
    audio_end_ms: i64,
};
pub const RealtimeBetaServerEventError = struct {
    event_id: []const u8,
    type: std.json.Value,
    _error: struct {
        type: []const u8,
        code: ?std.json.Value,
        message: []const u8,
        param: ?std.json.Value,
        event_id: ?std.json.Value,
    },
};
pub const RealtimeBetaServerEventInputAudioBufferCleared = struct {
    event_id: []const u8,
    type: std.json.Value,
};
pub const RealtimeBetaServerEventInputAudioBufferCommitted = struct {
    event_id: []const u8,
    type: std.json.Value,
    previous_item_id: ?std.json.Value,
    item_id: []const u8,
};
pub const RealtimeBetaServerEventInputAudioBufferSpeechStarted = struct {
    event_id: []const u8,
    type: std.json.Value,
    audio_start_ms: i64,
    item_id: []const u8,
};
pub const RealtimeBetaServerEventInputAudioBufferSpeechStopped = struct {
    event_id: []const u8,
    type: std.json.Value,
    audio_end_ms: i64,
    item_id: []const u8,
};
pub const RealtimeBetaServerEventMCPListToolsCompleted = struct {
    event_id: []const u8,
    type: std.json.Value,
    item_id: []const u8,
};
pub const RealtimeBetaServerEventMCPListToolsFailed = struct {
    event_id: []const u8,
    type: std.json.Value,
    item_id: []const u8,
};
pub const RealtimeBetaServerEventMCPListToolsInProgress = struct {
    event_id: []const u8,
    type: std.json.Value,
    item_id: []const u8,
};
pub const RealtimeBetaServerEventRateLimitsUpdated = struct {
    event_id: []const u8,
    type: std.json.Value,
    rate_limits: []const struct {
        name: ?[]const u8,
        limit: ?i64,
        remaining: ?i64,
        reset_seconds: ?f64,
    },
};
pub const RealtimeBetaServerEventResponseAudioDelta = struct {
    event_id: []const u8,
    type: std.json.Value,
    response_id: []const u8,
    item_id: []const u8,
    output_index: i64,
    content_index: i64,
    delta: []const u8,
};
pub const RealtimeBetaServerEventResponseAudioDone = struct {
    event_id: []const u8,
    type: std.json.Value,
    response_id: []const u8,
    item_id: []const u8,
    output_index: i64,
    content_index: i64,
};
pub const RealtimeBetaServerEventResponseAudioTranscriptDelta = struct {
    event_id: []const u8,
    type: std.json.Value,
    response_id: []const u8,
    item_id: []const u8,
    output_index: i64,
    content_index: i64,
    delta: []const u8,
};
pub const RealtimeBetaServerEventResponseAudioTranscriptDone = struct {
    event_id: []const u8,
    type: std.json.Value,
    response_id: []const u8,
    item_id: []const u8,
    output_index: i64,
    content_index: i64,
    transcript: []const u8,
};
pub const RealtimeBetaServerEventResponseContentPartAdded = struct {
    event_id: []const u8,
    type: std.json.Value,
    response_id: []const u8,
    item_id: []const u8,
    output_index: i64,
    content_index: i64,
    part: struct {
        type: ?[]const u8,
        text: ?[]const u8,
        audio: ?[]const u8,
        transcript: ?[]const u8,
    },
};
pub const RealtimeBetaServerEventResponseContentPartDone = struct {
    event_id: []const u8,
    type: std.json.Value,
    response_id: []const u8,
    item_id: []const u8,
    output_index: i64,
    content_index: i64,
    part: struct {
        type: ?[]const u8,
        text: ?[]const u8,
        audio: ?[]const u8,
        transcript: ?[]const u8,
    },
};
pub const RealtimeBetaServerEventResponseCreated = struct {
    event_id: []const u8,
    type: std.json.Value,
    response: RealtimeBetaResponse,
};
pub const RealtimeBetaServerEventResponseDone = struct {
    event_id: []const u8,
    type: std.json.Value,
    response: RealtimeBetaResponse,
};
pub const RealtimeBetaServerEventResponseFunctionCallArgumentsDelta = struct {
    event_id: []const u8,
    type: std.json.Value,
    response_id: []const u8,
    item_id: []const u8,
    output_index: i64,
    call_id: []const u8,
    delta: []const u8,
};
pub const RealtimeBetaServerEventResponseFunctionCallArgumentsDone = struct {
    event_id: []const u8,
    type: std.json.Value,
    response_id: []const u8,
    item_id: []const u8,
    output_index: i64,
    call_id: []const u8,
    arguments: []const u8,
};
pub const RealtimeBetaServerEventResponseMCPCallArgumentsDelta = struct {
    event_id: []const u8,
    type: std.json.Value,
    response_id: []const u8,
    item_id: []const u8,
    output_index: i64,
    delta: []const u8,
    obfuscation: ?std.json.Value,
};
pub const RealtimeBetaServerEventResponseMCPCallArgumentsDone = struct {
    event_id: []const u8,
    type: std.json.Value,
    response_id: []const u8,
    item_id: []const u8,
    output_index: i64,
    arguments: []const u8,
};
pub const RealtimeBetaServerEventResponseMCPCallCompleted = struct {
    event_id: []const u8,
    type: std.json.Value,
    output_index: i64,
    item_id: []const u8,
};
pub const RealtimeBetaServerEventResponseMCPCallFailed = struct {
    event_id: []const u8,
    type: std.json.Value,
    output_index: i64,
    item_id: []const u8,
};
pub const RealtimeBetaServerEventResponseMCPCallInProgress = struct {
    event_id: []const u8,
    type: std.json.Value,
    output_index: i64,
    item_id: []const u8,
};
pub const RealtimeBetaServerEventResponseOutputItemAdded = struct {
    event_id: []const u8,
    type: std.json.Value,
    response_id: []const u8,
    output_index: i64,
    item: RealtimeConversationItem,
};
pub const RealtimeBetaServerEventResponseOutputItemDone = struct {
    event_id: []const u8,
    type: std.json.Value,
    response_id: []const u8,
    output_index: i64,
    item: RealtimeConversationItem,
};
pub const RealtimeBetaServerEventResponseTextDelta = struct {
    event_id: []const u8,
    type: std.json.Value,
    response_id: []const u8,
    item_id: []const u8,
    output_index: i64,
    content_index: i64,
    delta: []const u8,
};
pub const RealtimeBetaServerEventResponseTextDone = struct {
    event_id: []const u8,
    type: std.json.Value,
    response_id: []const u8,
    item_id: []const u8,
    output_index: i64,
    content_index: i64,
    text: []const u8,
};
pub const RealtimeBetaServerEventSessionCreated = struct {
    event_id: []const u8,
    type: std.json.Value,
    session: RealtimeSession,
};
pub const RealtimeBetaServerEventSessionUpdated = struct {
    event_id: []const u8,
    type: std.json.Value,
    session: RealtimeSession,
};
pub const RealtimeBetaServerEventTranscriptionSessionCreated = struct {
    event_id: []const u8,
    type: std.json.Value,
    session: RealtimeTranscriptionSessionCreateResponse,
};
pub const RealtimeBetaServerEventTranscriptionSessionUpdated = struct {
    event_id: []const u8,
    type: std.json.Value,
    session: RealtimeTranscriptionSessionCreateResponse,
};
pub const RealtimeCallCreateRequest = struct {
    sdp: []const u8,
    session: ?std.json.Value,
};
pub const RealtimeCallReferRequest = struct {
    target_uri: []const u8,
};
pub const RealtimeCallRejectRequest = struct {
    status_code: ?i64,
};
pub const RealtimeClientEvent = std.json.Value;
pub const RealtimeClientEventConversationItemCreate = struct {
    event_id: ?[]const u8,
    type: std.json.Value,
    previous_item_id: ?[]const u8,
    item: RealtimeConversationItem,
};
pub const RealtimeClientEventConversationItemDelete = struct {
    event_id: ?[]const u8,
    type: std.json.Value,
    item_id: []const u8,
};
pub const RealtimeClientEventConversationItemRetrieve = struct {
    event_id: ?[]const u8,
    type: std.json.Value,
    item_id: []const u8,
};
pub const RealtimeClientEventConversationItemTruncate = struct {
    event_id: ?[]const u8,
    type: std.json.Value,
    item_id: []const u8,
    content_index: i64,
    audio_end_ms: i64,
};
pub const RealtimeClientEventInputAudioBufferAppend = struct {
    event_id: ?[]const u8,
    type: std.json.Value,
    audio: []const u8,
};
pub const RealtimeClientEventInputAudioBufferClear = struct {
    event_id: ?[]const u8,
    type: std.json.Value,
};
pub const RealtimeClientEventInputAudioBufferCommit = struct {
    event_id: ?[]const u8,
    type: std.json.Value,
};
pub const RealtimeClientEventOutputAudioBufferClear = struct {
    event_id: ?[]const u8,
    type: std.json.Value,
};
pub const RealtimeClientEventResponseCancel = struct {
    event_id: ?[]const u8,
    type: std.json.Value,
    response_id: ?[]const u8,
};
pub const RealtimeClientEventResponseCreate = struct {
    event_id: ?[]const u8,
    type: std.json.Value,
    response: ?RealtimeResponseCreateParams,
};
pub const RealtimeClientEventSessionUpdate = struct {
    event_id: ?[]const u8,
    type: std.json.Value,
    session: std.json.Value,
};
pub const RealtimeClientEventTranscriptionSessionUpdate = struct {
    event_id: ?[]const u8,
    type: std.json.Value,
    session: RealtimeTranscriptionSessionCreateRequest,
};
pub const RealtimeConnectParams = struct {
    model: ?[]const u8,
    call_id: ?[]const u8,
};
pub const RealtimeConversationItem = std.json.Value;
pub const RealtimeConversationItemFunctionCall = struct {
    id: ?[]const u8,
    object: ?[]const u8,
    type: []const u8,
    status: ?[]const u8,
    call_id: ?[]const u8,
    name: []const u8,
    arguments: []const u8,
};
pub const RealtimeConversationItemFunctionCallOutput = struct {
    id: ?[]const u8,
    object: ?[]const u8,
    type: []const u8,
    status: ?[]const u8,
    call_id: []const u8,
    output: []const u8,
};
pub const RealtimeConversationItemMessageAssistant = struct {
    id: ?[]const u8,
    object: ?[]const u8,
    type: []const u8,
    status: ?[]const u8,
    role: []const u8,
    content: []const struct {
        type: ?[]const u8,
        text: ?[]const u8,
        audio: ?[]const u8,
        transcript: ?[]const u8,
    },
};
pub const RealtimeConversationItemMessageSystem = struct {
    id: ?[]const u8,
    object: ?[]const u8,
    type: []const u8,
    status: ?[]const u8,
    role: []const u8,
    content: []const struct {
        type: ?[]const u8,
        text: ?[]const u8,
    },
};
pub const RealtimeConversationItemMessageUser = struct {
    id: ?[]const u8,
    object: ?[]const u8,
    type: []const u8,
    status: ?[]const u8,
    role: []const u8,
    content: []const struct {
        type: ?[]const u8,
        text: ?[]const u8,
        audio: ?[]const u8,
        image_url: ?[]const u8,
        detail: ?[]const u8,
        transcript: ?[]const u8,
    },
};
pub const RealtimeConversationItemWithReference = struct {
    id: ?[]const u8,
    type: ?[]const u8,
    object: ?[]const u8,
    status: ?[]const u8,
    role: ?[]const u8,
    content: ?[]const struct {
        type: ?[]const u8,
        text: ?[]const u8,
        id: ?[]const u8,
        audio: ?[]const u8,
        transcript: ?[]const u8,
    },
    call_id: ?[]const u8,
    name: ?[]const u8,
    arguments: ?[]const u8,
    output: ?[]const u8,
};
pub const RealtimeCreateClientSecretRequest = struct {
    expires_after: ?struct {
        anchor: ?[]const u8,
        seconds: ?i64,
    },
    session: ?std.json.Value,
};
pub const RealtimeCreateClientSecretResponse = struct {
    value: []const u8,
    expires_at: i64,
    session: std.json.Value,
};
pub const RealtimeFunctionTool = struct {
    type: ?[]const u8,
    name: ?[]const u8,
    description: ?[]const u8,
    parameters: ?std.json.Value,
};
pub const RealtimeMCPApprovalRequest = struct {
    type: []const u8,
    id: []const u8,
    server_label: []const u8,
    name: []const u8,
    arguments: []const u8,
};
pub const RealtimeMCPApprovalResponse = struct {
    type: []const u8,
    id: []const u8,
    approval_request_id: []const u8,
    approve: bool,
    reason: ?std.json.Value,
};
pub const RealtimeMCPHTTPError = struct {
    type: []const u8,
    code: i64,
    message: []const u8,
};
pub const RealtimeMCPListTools = struct {
    type: []const u8,
    id: ?[]const u8,
    server_label: []const u8,
    tools: []const MCPListToolsTool,
};
pub const RealtimeMCPProtocolError = struct {
    type: []const u8,
    code: i64,
    message: []const u8,
};
pub const RealtimeMCPToolCall = struct {
    type: []const u8,
    id: []const u8,
    server_label: []const u8,
    name: []const u8,
    arguments: []const u8,
    approval_request_id: ?std.json.Value,
    output: ?std.json.Value,
    _error: ?std.json.Value,
};
pub const RealtimeMCPToolExecutionError = struct {
    type: []const u8,
    message: []const u8,
};
pub const RealtimeResponse = struct {
    id: ?[]const u8,
    object: ?std.json.Value,
    status: ?[]const u8,
    status_details: ?struct {
        type: ?[]const u8,
        reason: ?[]const u8,
        _error: ?struct {
            type: ?[]const u8,
            code: ?[]const u8,
        },
    },
    output: ?[]const RealtimeConversationItem,
    metadata: ?Metadata,
    audio: ?struct {
        output: ?struct {
            format: ?RealtimeAudioFormats,
            voice: ?VoiceIdsShared,
        },
    },
    usage: ?struct {
        total_tokens: ?i64,
        input_tokens: ?i64,
        output_tokens: ?i64,
        input_token_details: ?struct {
            cached_tokens: ?i64,
            text_tokens: ?i64,
            image_tokens: ?i64,
            audio_tokens: ?i64,
            cached_tokens_details: ?struct {
                text_tokens: ?i64,
                image_tokens: ?i64,
                audio_tokens: ?i64,
            },
        },
        output_token_details: ?struct {
            text_tokens: ?i64,
            audio_tokens: ?i64,
        },
    },
    conversation_id: ?[]const u8,
    output_modalities: ?[]const []const u8,
    max_output_tokens: ?std.json.Value,
};
pub const RealtimeResponseCreateParams = struct {
    output_modalities: ?[]const []const u8,
    instructions: ?[]const u8,
    audio: ?struct {
        output: ?struct {
            format: ?RealtimeAudioFormats,
            voice: ?VoiceIdsShared,
        },
    },
    tools: ?[]const std.json.Value,
    tool_choice: ?std.json.Value,
    max_output_tokens: ?std.json.Value,
    conversation: ?std.json.Value,
    metadata: ?Metadata,
    prompt: ?Prompt,
    input: ?[]const RealtimeConversationItem,
};
pub const RealtimeServerEvent = std.json.Value;
pub const RealtimeServerEventConversationCreated = struct {
    event_id: []const u8,
    type: std.json.Value,
    conversation: struct {
        id: ?[]const u8,
        object: ?std.json.Value,
    },
};
pub const RealtimeServerEventConversationItemAdded = struct {
    event_id: []const u8,
    type: std.json.Value,
    previous_item_id: ?std.json.Value,
    item: RealtimeConversationItem,
};
pub const RealtimeServerEventConversationItemCreated = struct {
    event_id: []const u8,
    type: std.json.Value,
    previous_item_id: ?std.json.Value,
    item: RealtimeConversationItem,
};
pub const RealtimeServerEventConversationItemDeleted = struct {
    event_id: []const u8,
    type: std.json.Value,
    item_id: []const u8,
};
pub const RealtimeServerEventConversationItemDone = struct {
    event_id: []const u8,
    type: std.json.Value,
    previous_item_id: ?std.json.Value,
    item: RealtimeConversationItem,
};
pub const RealtimeServerEventConversationItemInputAudioTranscriptionCompleted = struct {
    event_id: []const u8,
    type: []const u8,
    item_id: []const u8,
    content_index: i64,
    transcript: []const u8,
    logprobs: ?std.json.Value,
    usage: std.json.Value,
};
pub const RealtimeServerEventConversationItemInputAudioTranscriptionDelta = struct {
    event_id: []const u8,
    type: std.json.Value,
    item_id: []const u8,
    content_index: ?i64,
    delta: ?[]const u8,
    logprobs: ?std.json.Value,
};
pub const RealtimeServerEventConversationItemInputAudioTranscriptionFailed = struct {
    event_id: []const u8,
    type: []const u8,
    item_id: []const u8,
    content_index: i64,
    _error: struct {
        type: ?[]const u8,
        code: ?[]const u8,
        message: ?[]const u8,
        param: ?[]const u8,
    },
};
pub const RealtimeServerEventConversationItemInputAudioTranscriptionSegment = struct {
    event_id: []const u8,
    type: std.json.Value,
    item_id: []const u8,
    content_index: i64,
    text: []const u8,
    id: []const u8,
    speaker: []const u8,
    start: f64,
    end: f64,
};
pub const RealtimeServerEventConversationItemRetrieved = struct {
    event_id: []const u8,
    type: std.json.Value,
    item: RealtimeConversationItem,
};
pub const RealtimeServerEventConversationItemTruncated = struct {
    event_id: []const u8,
    type: std.json.Value,
    item_id: []const u8,
    content_index: i64,
    audio_end_ms: i64,
};
pub const RealtimeServerEventError = struct {
    event_id: []const u8,
    type: std.json.Value,
    _error: struct {
        type: []const u8,
        code: ?std.json.Value,
        message: []const u8,
        param: ?std.json.Value,
        event_id: ?std.json.Value,
    },
};
pub const RealtimeServerEventInputAudioBufferCleared = struct {
    event_id: []const u8,
    type: std.json.Value,
};
pub const RealtimeServerEventInputAudioBufferCommitted = struct {
    event_id: []const u8,
    type: std.json.Value,
    previous_item_id: ?std.json.Value,
    item_id: []const u8,
};
pub const RealtimeServerEventInputAudioBufferDtmfEventReceived = struct {
    type: std.json.Value,
    event: []const u8,
    received_at: i64,
};
pub const RealtimeServerEventInputAudioBufferSpeechStarted = struct {
    event_id: []const u8,
    type: std.json.Value,
    audio_start_ms: i64,
    item_id: []const u8,
};
pub const RealtimeServerEventInputAudioBufferSpeechStopped = struct {
    event_id: []const u8,
    type: std.json.Value,
    audio_end_ms: i64,
    item_id: []const u8,
};
pub const RealtimeServerEventInputAudioBufferTimeoutTriggered = struct {
    event_id: []const u8,
    type: std.json.Value,
    audio_start_ms: i64,
    audio_end_ms: i64,
    item_id: []const u8,
};
pub const RealtimeServerEventMCPListToolsCompleted = struct {
    event_id: []const u8,
    type: std.json.Value,
    item_id: []const u8,
};
pub const RealtimeServerEventMCPListToolsFailed = struct {
    event_id: []const u8,
    type: std.json.Value,
    item_id: []const u8,
};
pub const RealtimeServerEventMCPListToolsInProgress = struct {
    event_id: []const u8,
    type: std.json.Value,
    item_id: []const u8,
};
pub const RealtimeServerEventOutputAudioBufferCleared = struct {
    event_id: []const u8,
    type: std.json.Value,
    response_id: []const u8,
};
pub const RealtimeServerEventOutputAudioBufferStarted = struct {
    event_id: []const u8,
    type: std.json.Value,
    response_id: []const u8,
};
pub const RealtimeServerEventOutputAudioBufferStopped = struct {
    event_id: []const u8,
    type: std.json.Value,
    response_id: []const u8,
};
pub const RealtimeServerEventRateLimitsUpdated = struct {
    event_id: []const u8,
    type: std.json.Value,
    rate_limits: []const struct {
        name: ?[]const u8,
        limit: ?i64,
        remaining: ?i64,
        reset_seconds: ?f64,
    },
};
pub const RealtimeServerEventResponseAudioDelta = struct {
    event_id: []const u8,
    type: std.json.Value,
    response_id: []const u8,
    item_id: []const u8,
    output_index: i64,
    content_index: i64,
    delta: []const u8,
};
pub const RealtimeServerEventResponseAudioDone = struct {
    event_id: []const u8,
    type: std.json.Value,
    response_id: []const u8,
    item_id: []const u8,
    output_index: i64,
    content_index: i64,
};
pub const RealtimeServerEventResponseAudioTranscriptDelta = struct {
    event_id: []const u8,
    type: std.json.Value,
    response_id: []const u8,
    item_id: []const u8,
    output_index: i64,
    content_index: i64,
    delta: []const u8,
};
pub const RealtimeServerEventResponseAudioTranscriptDone = struct {
    event_id: []const u8,
    type: std.json.Value,
    response_id: []const u8,
    item_id: []const u8,
    output_index: i64,
    content_index: i64,
    transcript: []const u8,
};
pub const RealtimeServerEventResponseContentPartAdded = struct {
    event_id: []const u8,
    type: std.json.Value,
    response_id: []const u8,
    item_id: []const u8,
    output_index: i64,
    content_index: i64,
    part: struct {
        type: ?[]const u8,
        text: ?[]const u8,
        audio: ?[]const u8,
        transcript: ?[]const u8,
    },
};
pub const RealtimeServerEventResponseContentPartDone = struct {
    event_id: []const u8,
    type: std.json.Value,
    response_id: []const u8,
    item_id: []const u8,
    output_index: i64,
    content_index: i64,
    part: struct {
        type: ?[]const u8,
        text: ?[]const u8,
        audio: ?[]const u8,
        transcript: ?[]const u8,
    },
};
pub const RealtimeServerEventResponseCreated = struct {
    event_id: []const u8,
    type: std.json.Value,
    response: RealtimeResponse,
};
pub const RealtimeServerEventResponseDone = struct {
    event_id: []const u8,
    type: std.json.Value,
    response: RealtimeResponse,
};
pub const RealtimeServerEventResponseFunctionCallArgumentsDelta = struct {
    event_id: []const u8,
    type: std.json.Value,
    response_id: []const u8,
    item_id: []const u8,
    output_index: i64,
    call_id: []const u8,
    delta: []const u8,
};
pub const RealtimeServerEventResponseFunctionCallArgumentsDone = struct {
    event_id: []const u8,
    type: std.json.Value,
    response_id: []const u8,
    item_id: []const u8,
    output_index: i64,
    call_id: []const u8,
    arguments: []const u8,
};
pub const RealtimeServerEventResponseMCPCallArgumentsDelta = struct {
    event_id: []const u8,
    type: std.json.Value,
    response_id: []const u8,
    item_id: []const u8,
    output_index: i64,
    delta: []const u8,
    obfuscation: ?std.json.Value,
};
pub const RealtimeServerEventResponseMCPCallArgumentsDone = struct {
    event_id: []const u8,
    type: std.json.Value,
    response_id: []const u8,
    item_id: []const u8,
    output_index: i64,
    arguments: []const u8,
};
pub const RealtimeServerEventResponseMCPCallCompleted = struct {
    event_id: []const u8,
    type: std.json.Value,
    output_index: i64,
    item_id: []const u8,
};
pub const RealtimeServerEventResponseMCPCallFailed = struct {
    event_id: []const u8,
    type: std.json.Value,
    output_index: i64,
    item_id: []const u8,
};
pub const RealtimeServerEventResponseMCPCallInProgress = struct {
    event_id: []const u8,
    type: std.json.Value,
    output_index: i64,
    item_id: []const u8,
};
pub const RealtimeServerEventResponseOutputItemAdded = struct {
    event_id: []const u8,
    type: std.json.Value,
    response_id: []const u8,
    output_index: i64,
    item: RealtimeConversationItem,
};
pub const RealtimeServerEventResponseOutputItemDone = struct {
    event_id: []const u8,
    type: std.json.Value,
    response_id: []const u8,
    output_index: i64,
    item: RealtimeConversationItem,
};
pub const RealtimeServerEventResponseTextDelta = struct {
    event_id: []const u8,
    type: std.json.Value,
    response_id: []const u8,
    item_id: []const u8,
    output_index: i64,
    content_index: i64,
    delta: []const u8,
};
pub const RealtimeServerEventResponseTextDone = struct {
    event_id: []const u8,
    type: std.json.Value,
    response_id: []const u8,
    item_id: []const u8,
    output_index: i64,
    content_index: i64,
    text: []const u8,
};
pub const RealtimeServerEventSessionCreated = struct {
    event_id: []const u8,
    type: std.json.Value,
    session: std.json.Value,
};
pub const RealtimeServerEventSessionUpdated = struct {
    event_id: []const u8,
    type: std.json.Value,
    session: std.json.Value,
};
pub const RealtimeServerEventTranscriptionSessionUpdated = struct {
    event_id: []const u8,
    type: std.json.Value,
    session: RealtimeTranscriptionSessionCreateResponse,
};
pub const RealtimeSession = struct {
    id: ?[]const u8,
    object: ?[]const u8,
    modalities: ?std.json.Value,
    model: ?[]const u8,
    instructions: ?[]const u8,
    voice: ?VoiceIdsShared,
    input_audio_format: ?[]const u8,
    output_audio_format: ?[]const u8,
    input_audio_transcription: ?std.json.Value,
    turn_detection: ?RealtimeTurnDetection,
    input_audio_noise_reduction: ?struct {
        type: ?NoiseReductionType,
    },
    speed: ?f64,
    tracing: ?std.json.Value,
    tools: ?[]const RealtimeFunctionTool,
    tool_choice: ?[]const u8,
    temperature: ?f64,
    max_response_output_tokens: ?std.json.Value,
    expires_at: ?i64,
    prompt: ?std.json.Value,
    include: ?std.json.Value,
};
pub const RealtimeSessionCreateRequest = struct {
    client_secret: struct {
        value: []const u8,
        expires_at: i64,
    },
    modalities: ?std.json.Value,
    instructions: ?[]const u8,
    voice: ?VoiceIdsShared,
    input_audio_format: ?[]const u8,
    output_audio_format: ?[]const u8,
    input_audio_transcription: ?struct {
        model: ?[]const u8,
    },
    speed: ?f64,
    tracing: ?std.json.Value,
    turn_detection: ?struct {
        type: ?[]const u8,
        threshold: ?f64,
        prefix_padding_ms: ?i64,
        silence_duration_ms: ?i64,
    },
    tools: ?[]const struct {
        type: ?[]const u8,
        name: ?[]const u8,
        description: ?[]const u8,
        parameters: ?std.json.Value,
    },
    tool_choice: ?[]const u8,
    temperature: ?f64,
    max_response_output_tokens: ?std.json.Value,
    truncation: ?RealtimeTruncation,
    prompt: ?Prompt,
};
pub const RealtimeSessionCreateRequestGA = struct {
    type: []const u8,
    output_modalities: ?[]const []const u8,
    model: ?std.json.Value,
    instructions: ?[]const u8,
    audio: ?struct {
        input: ?struct {
            format: ?RealtimeAudioFormats,
            transcription: ?AudioTranscription,
            noise_reduction: ?struct {
                type: ?NoiseReductionType,
            },
            turn_detection: ?RealtimeTurnDetection,
        },
        output: ?struct {
            format: ?RealtimeAudioFormats,
            voice: ?VoiceIdsShared,
            speed: ?f64,
        },
    },
    include: ?[]const []const u8,
    tracing: ?std.json.Value,
    tools: ?[]const std.json.Value,
    tool_choice: ?std.json.Value,
    max_output_tokens: ?std.json.Value,
    truncation: ?RealtimeTruncation,
    prompt: ?Prompt,
};
pub const RealtimeSessionCreateResponse = struct {
    id: ?[]const u8,
    object: ?[]const u8,
    expires_at: ?i64,
    include: ?[]const []const u8,
    model: ?[]const u8,
    output_modalities: ?std.json.Value,
    instructions: ?[]const u8,
    audio: ?struct {
        input: ?struct {
            format: ?RealtimeAudioFormats,
            transcription: ?AudioTranscription,
            noise_reduction: ?struct {
                type: ?NoiseReductionType,
            },
            turn_detection: ?struct {
                type: ?[]const u8,
                threshold: ?f64,
                prefix_padding_ms: ?i64,
                silence_duration_ms: ?i64,
            },
        },
        output: ?struct {
            format: ?RealtimeAudioFormats,
            voice: ?VoiceIdsShared,
            speed: ?f64,
        },
    },
    tracing: ?std.json.Value,
    turn_detection: ?struct {
        type: ?[]const u8,
        threshold: ?f64,
        prefix_padding_ms: ?i64,
        silence_duration_ms: ?i64,
    },
    tools: ?[]const RealtimeFunctionTool,
    tool_choice: ?[]const u8,
    max_output_tokens: ?std.json.Value,
};
pub const RealtimeSessionCreateResponseGA = struct {
    client_secret: struct {
        value: []const u8,
        expires_at: i64,
    },
    type: []const u8,
    output_modalities: ?[]const []const u8,
    model: ?std.json.Value,
    instructions: ?[]const u8,
    audio: ?struct {
        input: ?struct {
            format: ?RealtimeAudioFormats,
            transcription: ?AudioTranscription,
            noise_reduction: ?struct {
                type: ?NoiseReductionType,
            },
            turn_detection: ?RealtimeTurnDetection,
        },
        output: ?struct {
            format: ?RealtimeAudioFormats,
            voice: ?VoiceIdsShared,
            speed: ?f64,
        },
    },
    include: ?[]const []const u8,
    tracing: ?std.json.Value,
    tools: ?[]const std.json.Value,
    tool_choice: ?std.json.Value,
    max_output_tokens: ?std.json.Value,
    truncation: ?RealtimeTruncation,
    prompt: ?Prompt,
};
pub const RealtimeTranscriptionSessionCreateRequest = struct {
    turn_detection: ?struct {
        type: ?[]const u8,
        threshold: ?f64,
        prefix_padding_ms: ?i64,
        silence_duration_ms: ?i64,
    },
    input_audio_noise_reduction: ?struct {
        type: ?NoiseReductionType,
    },
    input_audio_format: ?[]const u8,
    input_audio_transcription: ?AudioTranscription,
    include: ?[]const []const u8,
};
pub const RealtimeTranscriptionSessionCreateRequestGA = struct {
    type: []const u8,
    audio: ?struct {
        input: ?struct {
            format: ?RealtimeAudioFormats,
            transcription: ?AudioTranscription,
            noise_reduction: ?struct {
                type: ?NoiseReductionType,
            },
            turn_detection: ?RealtimeTurnDetection,
        },
    },
    include: ?[]const []const u8,
};
pub const RealtimeTranscriptionSessionCreateResponse = struct {
    client_secret: struct {
        value: []const u8,
        expires_at: i64,
    },
    modalities: ?std.json.Value,
    input_audio_format: ?[]const u8,
    input_audio_transcription: ?AudioTranscription,
    turn_detection: ?struct {
        type: ?[]const u8,
        threshold: ?f64,
        prefix_padding_ms: ?i64,
        silence_duration_ms: ?i64,
    },
};
pub const RealtimeTranscriptionSessionCreateResponseGA = struct {
    type: []const u8,
    id: []const u8,
    object: []const u8,
    expires_at: ?i64,
    include: ?[]const []const u8,
    audio: ?struct {
        input: ?struct {
            format: ?RealtimeAudioFormats,
            transcription: ?AudioTranscription,
            noise_reduction: ?struct {
                type: ?NoiseReductionType,
            },
            turn_detection: ?struct {
                type: ?[]const u8,
                threshold: ?f64,
                prefix_padding_ms: ?i64,
                silence_duration_ms: ?i64,
            },
        },
    },
};
pub const RealtimeTruncation = std.json.Value;
pub const RealtimeTurnDetection = std.json.Value;
pub const Reasoning = struct {
    effort: ?ReasoningEffort,
    summary: ?std.json.Value,
    generate_summary: ?std.json.Value,
};
pub const ReasoningEffort = std.json.Value;
pub const ReasoningItem = struct {
    type: []const u8,
    id: []const u8,
    encrypted_content: ?std.json.Value,
    summary: []const Summary,
    content: ?[]const ReasoningTextContent,
    status: ?[]const u8,
};
pub const ReasoningTextContent = struct {
    type: []const u8,
    text: []const u8,
};
pub const RefusalContent = struct {
    type: []const u8,
    refusal: []const u8,
};
pub const Response = std.json.Value;
pub const ResponseAudioDeltaEvent = struct {
    type: []const u8,
    sequence_number: i64,
    delta: []const u8,
};
pub const ResponseAudioDoneEvent = struct {
    type: []const u8,
    sequence_number: i64,
};
pub const ResponseAudioTranscriptDeltaEvent = struct {
    type: []const u8,
    delta: []const u8,
    sequence_number: i64,
};
pub const ResponseAudioTranscriptDoneEvent = struct {
    type: []const u8,
    sequence_number: i64,
};
pub const ResponseCodeInterpreterCallCodeDeltaEvent = struct {
    type: []const u8,
    output_index: i64,
    item_id: []const u8,
    delta: []const u8,
    sequence_number: i64,
};
pub const ResponseCodeInterpreterCallCodeDoneEvent = struct {
    type: []const u8,
    output_index: i64,
    item_id: []const u8,
    code: []const u8,
    sequence_number: i64,
};
pub const ResponseCodeInterpreterCallCompletedEvent = struct {
    type: []const u8,
    output_index: i64,
    item_id: []const u8,
    sequence_number: i64,
};
pub const ResponseCodeInterpreterCallInProgressEvent = struct {
    type: []const u8,
    output_index: i64,
    item_id: []const u8,
    sequence_number: i64,
};
pub const ResponseCodeInterpreterCallInterpretingEvent = struct {
    type: []const u8,
    output_index: i64,
    item_id: []const u8,
    sequence_number: i64,
};
pub const ResponseCompletedEvent = struct {
    type: []const u8,
    response: Response,
    sequence_number: i64,
};
pub const ResponseContentPartAddedEvent = struct {
    type: []const u8,
    item_id: []const u8,
    output_index: i64,
    content_index: i64,
    part: OutputContent,
    sequence_number: i64,
};
pub const ResponseContentPartDoneEvent = struct {
    type: []const u8,
    item_id: []const u8,
    output_index: i64,
    content_index: i64,
    sequence_number: i64,
    part: OutputContent,
};
pub const ResponseCreatedEvent = struct {
    type: []const u8,
    response: Response,
    sequence_number: i64,
};
pub const ResponseCustomToolCallInputDeltaEvent = struct {
    type: []const u8,
    sequence_number: i64,
    output_index: i64,
    item_id: []const u8,
    delta: []const u8,
};
pub const ResponseCustomToolCallInputDoneEvent = struct {
    type: []const u8,
    sequence_number: i64,
    output_index: i64,
    item_id: []const u8,
    input: []const u8,
};
pub const ResponseError = std.json.Value;
pub const ResponseErrorCode = []const u8;
pub const ResponseErrorEvent = struct {
    type: []const u8,
    code: std.json.Value,
    message: []const u8,
    param: std.json.Value,
    sequence_number: i64,
};
pub const ResponseFailedEvent = struct {
    type: []const u8,
    sequence_number: i64,
    response: Response,
};
pub const ResponseFileSearchCallCompletedEvent = struct {
    type: []const u8,
    output_index: i64,
    item_id: []const u8,
    sequence_number: i64,
};
pub const ResponseFileSearchCallInProgressEvent = struct {
    type: []const u8,
    output_index: i64,
    item_id: []const u8,
    sequence_number: i64,
};
pub const ResponseFileSearchCallSearchingEvent = struct {
    type: []const u8,
    output_index: i64,
    item_id: []const u8,
    sequence_number: i64,
};
pub const ResponseFormatJsonObject = struct {
    type: []const u8,
};
pub const ResponseFormatJsonSchema = struct {
    type: []const u8,
    json_schema: struct {
        description: ?[]const u8,
        name: []const u8,
        schema: ?ResponseFormatJsonSchemaSchema,
        strict: ?std.json.Value,
    },
};
pub const ResponseFormatJsonSchemaSchema = std.json.Value;
pub const ResponseFormatText = struct {
    type: []const u8,
};
pub const ResponseFormatTextGrammar = struct {
    type: []const u8,
    grammar: []const u8,
};
pub const ResponseFormatTextPython = struct {
    type: []const u8,
};
pub const ResponseFunctionCallArgumentsDeltaEvent = struct {
    type: []const u8,
    item_id: []const u8,
    output_index: i64,
    sequence_number: i64,
    delta: []const u8,
};
pub const ResponseFunctionCallArgumentsDoneEvent = struct {
    type: []const u8,
    item_id: []const u8,
    name: []const u8,
    output_index: i64,
    sequence_number: i64,
    arguments: []const u8,
};
pub const ResponseImageGenCallCompletedEvent = struct {
    type: []const u8,
    output_index: i64,
    sequence_number: i64,
    item_id: []const u8,
};
pub const ResponseImageGenCallGeneratingEvent = struct {
    type: []const u8,
    output_index: i64,
    item_id: []const u8,
    sequence_number: i64,
};
pub const ResponseImageGenCallInProgressEvent = struct {
    type: []const u8,
    output_index: i64,
    item_id: []const u8,
    sequence_number: i64,
};
pub const ResponseImageGenCallPartialImageEvent = struct {
    type: []const u8,
    output_index: i64,
    item_id: []const u8,
    sequence_number: i64,
    partial_image_index: i64,
    partial_image_b64: []const u8,
};
pub const ResponseInProgressEvent = struct {
    type: []const u8,
    response: Response,
    sequence_number: i64,
};
pub const ResponseIncompleteEvent = struct {
    type: []const u8,
    response: Response,
    sequence_number: i64,
};
pub const ResponseItemList = struct {
    object: std.json.Value,
    data: []const ItemResource,
    has_more: bool,
    first_id: []const u8,
    last_id: []const u8,
};
pub const ResponseLogProb = struct {
    token: []const u8,
    logprob: f64,
    top_logprobs: ?[]const struct {
        token: ?[]const u8,
        logprob: ?f64,
    },
};
pub const ResponseMCPCallArgumentsDeltaEvent = struct {
    type: []const u8,
    output_index: i64,
    item_id: []const u8,
    delta: []const u8,
    sequence_number: i64,
};
pub const ResponseMCPCallArgumentsDoneEvent = struct {
    type: []const u8,
    output_index: i64,
    item_id: []const u8,
    arguments: []const u8,
    sequence_number: i64,
};
pub const ResponseMCPCallCompletedEvent = struct {
    type: []const u8,
    item_id: []const u8,
    output_index: i64,
    sequence_number: i64,
};
pub const ResponseMCPCallFailedEvent = struct {
    type: []const u8,
    item_id: []const u8,
    output_index: i64,
    sequence_number: i64,
};
pub const ResponseMCPCallInProgressEvent = struct {
    type: []const u8,
    sequence_number: i64,
    output_index: i64,
    item_id: []const u8,
};
pub const ResponseMCPListToolsCompletedEvent = struct {
    type: []const u8,
    item_id: []const u8,
    output_index: i64,
    sequence_number: i64,
};
pub const ResponseMCPListToolsFailedEvent = struct {
    type: []const u8,
    item_id: []const u8,
    output_index: i64,
    sequence_number: i64,
};
pub const ResponseMCPListToolsInProgressEvent = struct {
    type: []const u8,
    item_id: []const u8,
    output_index: i64,
    sequence_number: i64,
};
pub const ResponseModalities = std.json.Value;
pub const ResponseOutputItemAddedEvent = struct {
    type: []const u8,
    output_index: i64,
    sequence_number: i64,
    item: OutputItem,
};
pub const ResponseOutputItemDoneEvent = struct {
    type: []const u8,
    output_index: i64,
    sequence_number: i64,
    item: OutputItem,
};
pub const ResponseOutputText = struct {
    type: []const u8,
    text: []const u8,
    annotations: []const std.json.Value,
};
pub const ResponseOutputTextAnnotationAddedEvent = struct {
    type: []const u8,
    item_id: []const u8,
    output_index: i64,
    content_index: i64,
    annotation_index: i64,
    sequence_number: i64,
    annotation: std.json.Value,
};
pub const ResponsePromptVariables = std.json.Value;
pub const ResponseProperties = struct {
    previous_response_id: ?std.json.Value,
    model: ?ModelIdsResponses,
    reasoning: ?std.json.Value,
    background: ?std.json.Value,
    max_output_tokens: ?std.json.Value,
    max_tool_calls: ?std.json.Value,
    text: ?ResponseTextParam,
    tools: ?ToolsArray,
    tool_choice: ?ToolChoiceParam,
    prompt: ?Prompt,
    truncation: ?std.json.Value,
};
pub const ResponseQueuedEvent = struct {
    type: []const u8,
    response: Response,
    sequence_number: i64,
};
pub const ResponseReasoningSummaryPartAddedEvent = struct {
    type: []const u8,
    item_id: []const u8,
    output_index: i64,
    summary_index: i64,
    sequence_number: i64,
    part: struct {
        type: []const u8,
        text: []const u8,
    },
};
pub const ResponseReasoningSummaryPartDoneEvent = struct {
    type: []const u8,
    item_id: []const u8,
    output_index: i64,
    summary_index: i64,
    sequence_number: i64,
    part: struct {
        type: []const u8,
        text: []const u8,
    },
};
pub const ResponseReasoningSummaryTextDeltaEvent = struct {
    type: []const u8,
    item_id: []const u8,
    output_index: i64,
    summary_index: i64,
    delta: []const u8,
    sequence_number: i64,
};
pub const ResponseReasoningSummaryTextDoneEvent = struct {
    type: []const u8,
    item_id: []const u8,
    output_index: i64,
    summary_index: i64,
    text: []const u8,
    sequence_number: i64,
};
pub const ResponseReasoningTextDeltaEvent = struct {
    type: []const u8,
    item_id: []const u8,
    output_index: i64,
    content_index: i64,
    delta: []const u8,
    sequence_number: i64,
};
pub const ResponseReasoningTextDoneEvent = struct {
    type: []const u8,
    item_id: []const u8,
    output_index: i64,
    content_index: i64,
    text: []const u8,
    sequence_number: i64,
};
pub const ResponseRefusalDeltaEvent = struct {
    type: []const u8,
    item_id: []const u8,
    output_index: i64,
    content_index: i64,
    delta: []const u8,
    sequence_number: i64,
};
pub const ResponseRefusalDoneEvent = struct {
    type: []const u8,
    item_id: []const u8,
    output_index: i64,
    content_index: i64,
    refusal: []const u8,
    sequence_number: i64,
};
pub const ResponseStreamEvent = std.json.Value;
pub const ResponseStreamOptions = std.json.Value;
pub const ResponseTextDeltaEvent = struct {
    type: []const u8,
    item_id: []const u8,
    output_index: i64,
    content_index: i64,
    delta: []const u8,
    sequence_number: i64,
    logprobs: []const ResponseLogProb,
};
pub const ResponseTextDoneEvent = struct {
    type: []const u8,
    item_id: []const u8,
    output_index: i64,
    content_index: i64,
    text: []const u8,
    sequence_number: i64,
    logprobs: []const ResponseLogProb,
};
pub const ResponseTextParam = struct {
    format: ?TextResponseFormatConfiguration,
    verbosity: ?Verbosity,
};
pub const ResponseUsage = struct {
    input_tokens: i64,
    input_tokens_details: struct {
        cached_tokens: i64,
    },
    output_tokens: i64,
    output_tokens_details: struct {
        reasoning_tokens: i64,
    },
    total_tokens: i64,
};
pub const ResponseWebSearchCallCompletedEvent = struct {
    type: []const u8,
    output_index: i64,
    item_id: []const u8,
    sequence_number: i64,
};
pub const ResponseWebSearchCallInProgressEvent = struct {
    type: []const u8,
    output_index: i64,
    item_id: []const u8,
    sequence_number: i64,
};
pub const ResponseWebSearchCallSearchingEvent = struct {
    type: []const u8,
    output_index: i64,
    item_id: []const u8,
    sequence_number: i64,
};
pub const Role = struct {
    object: []const u8,
    id: []const u8,
    name: []const u8,
    description: std.json.Value,
    permissions: []const []const u8,
    resource_type: []const u8,
    predefined_role: bool,
};
pub const RoleDeletedResource = struct {
    object: []const u8,
    id: []const u8,
    deleted: bool,
};
pub const RoleListResource = struct {
    object: []const u8,
    data: []const AssignedRoleDetails,
    has_more: bool,
    next: std.json.Value,
};
pub const RunCompletionUsage = std.json.Value;
pub const RunGraderRequest = struct {
    grader: std.json.Value,
    item: ?std.json.Value,
    model_sample: []const u8,
};
pub const RunGraderResponse = struct {
    reward: f64,
    metadata: struct {
        name: []const u8,
        type: []const u8,
        errors: struct {
            formula_parse_error: bool,
            sample_parse_error: bool,
            truncated_observation_error: bool,
            unresponsive_reward_error: bool,
            invalid_variable_error: bool,
            other_error: bool,
            python_grader_server_error: bool,
            python_grader_server_error_type: std.json.Value,
            python_grader_runtime_error: bool,
            python_grader_runtime_error_details: std.json.Value,
            model_grader_server_error: bool,
            model_grader_refusal_error: bool,
            model_grader_parse_error: bool,
            model_grader_server_error_details: std.json.Value,
        },
        execution_time: f64,
        scores: std.json.Value,
        token_usage: std.json.Value,
        sampled_model_name: std.json.Value,
    },
    sub_rewards: std.json.Value,
    model_grader_token_usage_per_model: std.json.Value,
};
pub const RunObject = struct {
    id: []const u8,
    object: []const u8,
    created_at: i64,
    thread_id: []const u8,
    assistant_id: []const u8,
    status: RunStatus,
    required_action: struct {
        type: []const u8,
        submit_tool_outputs: struct {
            tool_calls: []const RunToolCallObject,
        },
    },
    last_error: struct {
        code: []const u8,
        message: []const u8,
    },
    expires_at: i64,
    started_at: i64,
    cancelled_at: i64,
    failed_at: i64,
    completed_at: i64,
    incomplete_details: struct {
        reason: ?[]const u8,
    },
    model: []const u8,
    instructions: []const u8,
    tools: []const AssistantTool,
    metadata: Metadata,
    usage: RunCompletionUsage,
    temperature: ?f64,
    top_p: ?f64,
    max_prompt_tokens: i64,
    max_completion_tokens: i64,
    truncation_strategy: std.json.Value,
    tool_choice: std.json.Value,
    parallel_tool_calls: ParallelToolCalls,
    response_format: AssistantsApiResponseFormatOption,
};
pub const RunStatus = []const u8;
pub const RunStepCompletionUsage = std.json.Value;
pub const RunStepDeltaObject = struct {
    id: []const u8,
    object: []const u8,
    delta: RunStepDeltaObjectDelta,
};
pub const RunStepDeltaObjectDelta = struct {
    step_details: ?std.json.Value,
};
pub const RunStepDeltaStepDetailsMessageCreationObject = struct {
    type: []const u8,
    message_creation: ?struct {
        message_id: ?[]const u8,
    },
};
pub const RunStepDeltaStepDetailsToolCall = std.json.Value;
pub const RunStepDeltaStepDetailsToolCallsCodeObject = struct {
    index: i64,
    id: ?[]const u8,
    type: []const u8,
    code_interpreter: ?struct {
        input: ?[]const u8,
        outputs: ?[]const std.json.Value,
    },
};
pub const RunStepDeltaStepDetailsToolCallsCodeOutputImageObject = struct {
    index: i64,
    type: []const u8,
    image: ?struct {
        file_id: ?[]const u8,
    },
};
pub const RunStepDeltaStepDetailsToolCallsCodeOutputLogsObject = struct {
    index: i64,
    type: []const u8,
    logs: ?[]const u8,
};
pub const RunStepDeltaStepDetailsToolCallsFileSearchObject = struct {
    index: i64,
    id: ?[]const u8,
    type: []const u8,
    file_search: std.json.Value,
};
pub const RunStepDeltaStepDetailsToolCallsFunctionObject = struct {
    index: i64,
    id: ?[]const u8,
    type: []const u8,
    function: ?struct {
        name: ?[]const u8,
        arguments: ?[]const u8,
        output: ?std.json.Value,
    },
};
pub const RunStepDeltaStepDetailsToolCallsObject = struct {
    type: []const u8,
    tool_calls: ?[]const RunStepDeltaStepDetailsToolCall,
};
pub const RunStepDetailsMessageCreationObject = struct {
    type: []const u8,
    message_creation: struct {
        message_id: []const u8,
    },
};
pub const RunStepDetailsToolCall = std.json.Value;
pub const RunStepDetailsToolCallsCodeObject = struct {
    id: []const u8,
    type: []const u8,
    code_interpreter: struct {
        input: []const u8,
        outputs: []const std.json.Value,
    },
};
pub const RunStepDetailsToolCallsCodeOutputImageObject = struct {
    type: []const u8,
    image: struct {
        file_id: []const u8,
    },
};
pub const RunStepDetailsToolCallsCodeOutputLogsObject = struct {
    type: []const u8,
    logs: []const u8,
};
pub const RunStepDetailsToolCallsFileSearchObject = struct {
    id: []const u8,
    type: []const u8,
    file_search: struct {
        ranking_options: ?RunStepDetailsToolCallsFileSearchRankingOptionsObject,
        results: ?[]const RunStepDetailsToolCallsFileSearchResultObject,
    },
};
pub const RunStepDetailsToolCallsFileSearchRankingOptionsObject = struct {
    ranker: FileSearchRanker,
    score_threshold: f64,
};
pub const RunStepDetailsToolCallsFileSearchResultObject = struct {
    file_id: []const u8,
    file_name: []const u8,
    score: f64,
    content: ?[]const struct {
        type: ?[]const u8,
        text: ?[]const u8,
    },
};
pub const RunStepDetailsToolCallsFunctionObject = struct {
    id: []const u8,
    type: []const u8,
    function: struct {
        name: []const u8,
        arguments: []const u8,
        output: std.json.Value,
    },
};
pub const RunStepDetailsToolCallsObject = struct {
    type: []const u8,
    tool_calls: []const RunStepDetailsToolCall,
};
pub const RunStepObject = struct {
    id: []const u8,
    object: []const u8,
    created_at: i64,
    assistant_id: []const u8,
    thread_id: []const u8,
    run_id: []const u8,
    type: []const u8,
    status: []const u8,
    step_details: std.json.Value,
    last_error: std.json.Value,
    expired_at: std.json.Value,
    cancelled_at: std.json.Value,
    failed_at: std.json.Value,
    completed_at: std.json.Value,
    metadata: Metadata,
    usage: RunStepCompletionUsage,
};
pub const RunStepStreamEvent = std.json.Value;
pub const RunStreamEvent = std.json.Value;
pub const RunToolCallObject = struct {
    id: []const u8,
    type: []const u8,
    function: struct {
        name: []const u8,
        arguments: []const u8,
    },
};
pub const Screenshot = struct {
    type: []const u8,
};
pub const Scroll = struct {
    type: []const u8,
    x: i64,
    y: i64,
    scroll_x: i64,
    scroll_y: i64,
};
pub const SearchContextSize = []const u8;
pub const ServiceTier = std.json.Value;
pub const SpecificApplyPatchParam = struct {
    type: []const u8,
};
pub const SpecificFunctionShellParam = struct {
    type: []const u8,
};
pub const SpeechAudioDeltaEvent = struct {
    type: []const u8,
    audio: []const u8,
};
pub const SpeechAudioDoneEvent = struct {
    type: []const u8,
    usage: struct {
        input_tokens: i64,
        output_tokens: i64,
        total_tokens: i64,
    },
};
pub const StaticChunkingStrategy = struct {
    max_chunk_size_tokens: i64,
    chunk_overlap_tokens: i64,
};
pub const StaticChunkingStrategyRequestParam = struct {
    type: []const u8,
    static: StaticChunkingStrategy,
};
pub const StaticChunkingStrategyResponseParam = struct {
    type: []const u8,
    static: StaticChunkingStrategy,
};
pub const StopConfiguration = std.json.Value;
pub const SubmitToolOutputsRunRequest = struct {
    tool_outputs: []const struct {
        tool_call_id: ?[]const u8,
        output: ?[]const u8,
    },
    stream: ?std.json.Value,
};
pub const SubmitToolOutputsRunRequestWithoutStream = struct {
    tool_outputs: []const struct {
        tool_call_id: ?[]const u8,
        output: ?[]const u8,
    },
};
pub const Summary = struct {
    type: []const u8,
    text: []const u8,
};
pub const SummaryTextContent = struct {
    type: []const u8,
    text: []const u8,
};
pub const TaskGroupItem = struct {
    id: []const u8,
    object: []const u8,
    created_at: i64,
    thread_id: []const u8,
    type: []const u8,
    tasks: []const TaskGroupTask,
};
pub const TaskGroupTask = struct {
    type: TaskType,
    heading: std.json.Value,
    summary: std.json.Value,
};
pub const TaskItem = struct {
    id: []const u8,
    object: []const u8,
    created_at: i64,
    thread_id: []const u8,
    type: []const u8,
    task_type: TaskType,
    heading: std.json.Value,
    summary: std.json.Value,
};
pub const TaskType = []const u8;
pub const TextAnnotation = std.json.Value;
pub const TextAnnotationDelta = std.json.Value;
pub const TextContent = struct {
    type: []const u8,
    text: []const u8,
};
pub const TextResponseFormatConfiguration = std.json.Value;
pub const TextResponseFormatJsonSchema = struct {
    type: []const u8,
    description: ?[]const u8,
    name: []const u8,
    schema: ResponseFormatJsonSchemaSchema,
    strict: ?std.json.Value,
};
pub const ThreadItem = std.json.Value;
pub const ThreadItemListResource = struct {
    object: std.json.Value,
    data: []const ThreadItem,
    first_id: std.json.Value,
    last_id: std.json.Value,
    has_more: bool,
};
pub const ThreadListResource = struct {
    object: std.json.Value,
    data: []const ThreadResource,
    first_id: std.json.Value,
    last_id: std.json.Value,
    has_more: bool,
};
pub const ThreadObject = struct {
    id: []const u8,
    object: []const u8,
    created_at: i64,
    tool_resources: std.json.Value,
    metadata: Metadata,
};
pub const ThreadResource = struct {
    id: []const u8,
    object: []const u8,
    created_at: i64,
    title: std.json.Value,
    status: std.json.Value,
    user: []const u8,
};
pub const ThreadStreamEvent = std.json.Value;
pub const ToggleCertificatesRequest = struct {
    certificate_ids: []const []const u8,
};
pub const TokenCountsBody = struct {
    model: ?std.json.Value,
    input: ?std.json.Value,
    previous_response_id: ?std.json.Value,
    tools: ?std.json.Value,
    text: ?std.json.Value,
    reasoning: ?std.json.Value,
    truncation: ?TruncationEnum,
    instructions: ?std.json.Value,
    conversation: ?std.json.Value,
    tool_choice: ?std.json.Value,
    parallel_tool_calls: ?std.json.Value,
};
pub const TokenCountsResource = struct {
    object: []const u8,
    input_tokens: i64,
};
pub const Tool = std.json.Value;
pub const ToolChoice = struct {
    id: []const u8,
};
pub const ToolChoiceAllowed = struct {
    type: []const u8,
    mode: []const u8,
    tools: []const std.json.Value,
};
pub const ToolChoiceCustom = struct {
    type: []const u8,
    name: []const u8,
};
pub const ToolChoiceFunction = struct {
    type: []const u8,
    name: []const u8,
};
pub const ToolChoiceMCP = struct {
    type: []const u8,
    server_label: []const u8,
    name: ?std.json.Value,
};
pub const ToolChoiceOptions = []const u8;
pub const ToolChoiceParam = std.json.Value;
pub const ToolChoiceTypes = struct {
    type: []const u8,
};
pub const ToolsArray = []const Tool;
pub const TopLogProb = struct {
    token: []const u8,
    logprob: f64,
    bytes: []const i64,
};
pub const TranscriptTextDeltaEvent = struct {
    type: []const u8,
    delta: []const u8,
    logprobs: ?[]const struct {
        token: ?[]const u8,
        logprob: ?f64,
        bytes: ?[]const i64,
    },
    segment_id: ?[]const u8,
};
pub const TranscriptTextDoneEvent = struct {
    type: []const u8,
    text: []const u8,
    logprobs: ?[]const struct {
        token: ?[]const u8,
        logprob: ?f64,
        bytes: ?[]const i64,
    },
    usage: ?TranscriptTextUsageTokens,
};
pub const TranscriptTextSegmentEvent = struct {
    type: []const u8,
    id: []const u8,
    start: f64,
    end: f64,
    text: []const u8,
    speaker: []const u8,
};
pub const TranscriptTextUsageDuration = struct {
    type: []const u8,
    seconds: f64,
};
pub const TranscriptTextUsageTokens = struct {
    type: []const u8,
    input_tokens: i64,
    input_token_details: ?struct {
        text_tokens: ?i64,
        audio_tokens: ?i64,
    },
    output_tokens: i64,
    total_tokens: i64,
};
pub const TranscriptionChunkingStrategy = std.json.Value;
pub const TranscriptionDiarizedSegment = struct {
    type: []const u8,
    id: []const u8,
    start: f64,
    end: f64,
    text: []const u8,
    speaker: []const u8,
};
pub const TranscriptionInclude = []const u8;
pub const TranscriptionSegment = struct {
    id: i64,
    seek: i64,
    start: f64,
    end: f64,
    text: []const u8,
    tokens: []const i64,
    temperature: f64,
    avg_logprob: f64,
    compression_ratio: f64,
    no_speech_prob: f64,
};
pub const TranscriptionWord = struct {
    word: []const u8,
    start: f64,
    end: f64,
};
pub const TruncationEnum = []const u8;
pub const TruncationObject = struct {
    type: []const u8,
    last_messages: ?std.json.Value,
};
pub const Type = struct {
    type: []const u8,
    text: []const u8,
};
pub const UpdateConversationBody = struct {
    metadata: Metadata,
};
pub const UpdateGroupBody = struct {
    name: []const u8,
};
pub const UpdateVectorStoreFileAttributesRequest = struct {
    attributes: VectorStoreFileAttributes,
};
pub const UpdateVectorStoreRequest = struct {
    name: ?[]const u8,
    expires_after: ?std.json.Value,
    metadata: ?Metadata,
};
pub const UpdateVoiceConsentRequest = struct {
    name: []const u8,
};
pub const Upload = struct {
    id: []const u8,
    created_at: i64,
    filename: []const u8,
    bytes: i64,
    purpose: []const u8,
    status: []const u8,
    expires_at: i64,
    object: []const u8,
    file: ?std.json.Value,
};
pub const UploadCertificateRequest = struct {
    name: ?[]const u8,
    content: []const u8,
};
pub const UploadPart = struct {
    id: []const u8,
    created_at: i64,
    upload_id: []const u8,
    object: []const u8,
};
pub const UrlAnnotation = struct {
    type: []const u8,
    source: UrlAnnotationSource,
};
pub const UrlAnnotationSource = struct {
    type: []const u8,
    url: []const u8,
};
pub const UrlCitationBody = struct {
    type: []const u8,
    url: []const u8,
    start_index: i64,
    end_index: i64,
    title: []const u8,
};
pub const UsageAudioSpeechesResult = struct {
    object: []const u8,
    characters: i64,
    num_model_requests: i64,
    project_id: ?std.json.Value,
    user_id: ?std.json.Value,
    api_key_id: ?std.json.Value,
    model: ?std.json.Value,
};
pub const UsageAudioTranscriptionsResult = struct {
    object: []const u8,
    seconds: i64,
    num_model_requests: i64,
    project_id: ?std.json.Value,
    user_id: ?std.json.Value,
    api_key_id: ?std.json.Value,
    model: ?std.json.Value,
};
pub const UsageCodeInterpreterSessionsResult = struct {
    object: []const u8,
    num_sessions: ?i64,
    project_id: ?std.json.Value,
};
pub const UsageCompletionsResult = struct {
    object: []const u8,
    input_tokens: i64,
    input_cached_tokens: ?i64,
    output_tokens: i64,
    input_audio_tokens: ?i64,
    output_audio_tokens: ?i64,
    num_model_requests: i64,
    project_id: ?std.json.Value,
    user_id: ?std.json.Value,
    api_key_id: ?std.json.Value,
    model: ?std.json.Value,
    batch: ?std.json.Value,
    service_tier: ?std.json.Value,
};
pub const UsageEmbeddingsResult = struct {
    object: []const u8,
    input_tokens: i64,
    num_model_requests: i64,
    project_id: ?std.json.Value,
    user_id: ?std.json.Value,
    api_key_id: ?std.json.Value,
    model: ?std.json.Value,
};
pub const UsageImagesResult = struct {
    object: []const u8,
    images: i64,
    num_model_requests: i64,
    source: ?std.json.Value,
    size: ?std.json.Value,
    project_id: ?std.json.Value,
    user_id: ?std.json.Value,
    api_key_id: ?std.json.Value,
    model: ?std.json.Value,
};
pub const UsageModerationsResult = struct {
    object: []const u8,
    input_tokens: i64,
    num_model_requests: i64,
    project_id: ?std.json.Value,
    user_id: ?std.json.Value,
    api_key_id: ?std.json.Value,
    model: ?std.json.Value,
};
pub const UsageResponse = struct {
    object: []const u8,
    data: []const UsageTimeBucket,
    has_more: bool,
    next_page: []const u8,
};
pub const UsageTimeBucket = struct {
    object: []const u8,
    start_time: i64,
    end_time: i64,
    result: []const std.json.Value,
};
pub const UsageVectorStoresResult = struct {
    object: []const u8,
    usage_bytes: i64,
    project_id: ?std.json.Value,
};
pub const User = struct {
    object: []const u8,
    id: []const u8,
    name: []const u8,
    email: []const u8,
    role: []const u8,
    added_at: i64,
};
pub const UserDeleteResponse = struct {
    object: []const u8,
    id: []const u8,
    deleted: bool,
};
pub const UserListResource = struct {
    object: []const u8,
    data: []const User,
    has_more: bool,
    next: std.json.Value,
};
pub const UserListResponse = struct {
    object: []const u8,
    data: []const User,
    first_id: []const u8,
    last_id: []const u8,
    has_more: bool,
};
pub const UserMessageInputText = struct {
    type: []const u8,
    text: []const u8,
};
pub const UserMessageItem = struct {
    id: []const u8,
    object: []const u8,
    created_at: i64,
    thread_id: []const u8,
    type: []const u8,
    content: []const std.json.Value,
    attachments: []const Attachment,
    inference_options: std.json.Value,
};
pub const UserMessageQuotedText = struct {
    type: []const u8,
    text: []const u8,
};
pub const UserRoleAssignment = struct {
    object: []const u8,
    user: User,
    role: Role,
};
pub const UserRoleUpdateRequest = struct {
    role: []const u8,
};
pub const VadConfig = struct {
    type: []const u8,
    prefix_padding_ms: ?i64,
    silence_duration_ms: ?i64,
    threshold: ?f64,
};
pub const ValidateGraderRequest = struct {
    grader: std.json.Value,
};
pub const ValidateGraderResponse = struct {
    grader: ?std.json.Value,
};
pub const VectorStoreExpirationAfter = struct {
    anchor: []const u8,
    days: i64,
};
pub const VectorStoreFileAttributes = std.json.Value;
pub const VectorStoreFileBatchObject = struct {
    id: []const u8,
    object: []const u8,
    created_at: i64,
    vector_store_id: []const u8,
    status: []const u8,
    file_counts: struct {
        in_progress: i64,
        completed: i64,
        failed: i64,
        cancelled: i64,
        total: i64,
    },
};
pub const VectorStoreFileContentResponse = struct {
    object: []const u8,
    data: []const struct {
        type: ?[]const u8,
        text: ?[]const u8,
    },
    has_more: bool,
    next_page: std.json.Value,
};
pub const VectorStoreFileObject = struct {
    id: []const u8,
    object: []const u8,
    usage_bytes: i64,
    created_at: i64,
    vector_store_id: []const u8,
    status: []const u8,
    last_error: std.json.Value,
    chunking_strategy: ?ChunkingStrategyResponse,
    attributes: ?VectorStoreFileAttributes,
};
pub const VectorStoreObject = struct {
    id: []const u8,
    object: []const u8,
    created_at: i64,
    name: []const u8,
    usage_bytes: i64,
    file_counts: struct {
        in_progress: i64,
        completed: i64,
        failed: i64,
        cancelled: i64,
        total: i64,
    },
    status: []const u8,
    expires_after: ?VectorStoreExpirationAfter,
    expires_at: ?std.json.Value,
    last_active_at: std.json.Value,
    metadata: Metadata,
};
pub const VectorStoreSearchRequest = struct {
    query: std.json.Value,
    rewrite_query: ?bool,
    max_num_results: ?i64,
    filters: ?std.json.Value,
    ranking_options: ?struct {
        ranker: ?[]const u8,
        score_threshold: ?f64,
    },
};
pub const VectorStoreSearchResultContentObject = struct {
    type: []const u8,
    text: []const u8,
};
pub const VectorStoreSearchResultItem = struct {
    file_id: []const u8,
    filename: []const u8,
    score: f64,
    attributes: VectorStoreFileAttributes,
    content: []const VectorStoreSearchResultContentObject,
};
pub const VectorStoreSearchResultsPage = struct {
    object: []const u8,
    search_query: []const []const u8,
    data: []const VectorStoreSearchResultItem,
    has_more: bool,
    next_page: std.json.Value,
};
pub const Verbosity = std.json.Value;
pub const VideoContentVariant = []const u8;
pub const VideoListResource = struct {
    object: std.json.Value,
    data: []const VideoResource,
    first_id: std.json.Value,
    last_id: std.json.Value,
    has_more: bool,
};
pub const VideoModel = []const u8;
pub const VideoResource = struct {
    id: []const u8,
    object: []const u8,
    model: VideoModel,
    status: VideoStatus,
    progress: i64,
    created_at: i64,
    completed_at: std.json.Value,
    expires_at: std.json.Value,
    prompt: std.json.Value,
    size: VideoSize,
    seconds: VideoSeconds,
    remixed_from_video_id: std.json.Value,
    _error: std.json.Value,
};
pub const VideoSeconds = []const u8;
pub const VideoSize = []const u8;
pub const VideoStatus = []const u8;
pub const VoiceConsentDeletedResource = struct {
    id: []const u8,
    object: []const u8,
    deleted: bool,
};
pub const VoiceConsentListResource = struct {
    object: []const u8,
    data: []const VoiceConsentResource,
    first_id: ?std.json.Value,
    last_id: ?std.json.Value,
    has_more: bool,
};
pub const VoiceConsentResource = struct {
    object: []const u8,
    id: []const u8,
    name: []const u8,
    language: []const u8,
    created_at: i64,
};
pub const VoiceIdsShared = std.json.Value;
pub const VoiceResource = struct {
    object: []const u8,
    id: []const u8,
    name: []const u8,
    created_at: i64,
};
pub const Wait = struct {
    type: []const u8,
};
pub const WebSearchActionFind = struct {
    type: []const u8,
    url: []const u8,
    pattern: []const u8,
};
pub const WebSearchActionOpenPage = struct {
    type: []const u8,
    url: []const u8,
};
pub const WebSearchActionSearch = struct {
    type: []const u8,
    query: []const u8,
    sources: ?[]const struct {
        type: []const u8,
        url: []const u8,
    },
};
pub const WebSearchApproximateLocation = std.json.Value;
pub const WebSearchContextSize = []const u8;
pub const WebSearchLocation = struct {
    country: ?[]const u8,
    region: ?[]const u8,
    city: ?[]const u8,
    timezone: ?[]const u8,
};
pub const WebSearchPreviewTool = struct {
    type: []const u8,
    user_location: ?std.json.Value,
    search_context_size: ?SearchContextSize,
};
pub const WebSearchTool = struct {
    type: []const u8,
    filters: ?std.json.Value,
    user_location: ?WebSearchApproximateLocation,
    search_context_size: ?[]const u8,
};
pub const WebSearchToolCall = struct {
    id: []const u8,
    type: []const u8,
    status: []const u8,
    action: std.json.Value,
};
pub const WebhookBatchCancelled = struct {
    created_at: i64,
    id: []const u8,
    data: struct {
        id: []const u8,
    },
    object: ?[]const u8,
    type: []const u8,
};
pub const WebhookBatchCompleted = struct {
    created_at: i64,
    id: []const u8,
    data: struct {
        id: []const u8,
    },
    object: ?[]const u8,
    type: []const u8,
};
pub const WebhookBatchExpired = struct {
    created_at: i64,
    id: []const u8,
    data: struct {
        id: []const u8,
    },
    object: ?[]const u8,
    type: []const u8,
};
pub const WebhookBatchFailed = struct {
    created_at: i64,
    id: []const u8,
    data: struct {
        id: []const u8,
    },
    object: ?[]const u8,
    type: []const u8,
};
pub const WebhookEvalRunCanceled = struct {
    created_at: i64,
    id: []const u8,
    data: struct {
        id: []const u8,
    },
    object: ?[]const u8,
    type: []const u8,
};
pub const WebhookEvalRunFailed = struct {
    created_at: i64,
    id: []const u8,
    data: struct {
        id: []const u8,
    },
    object: ?[]const u8,
    type: []const u8,
};
pub const WebhookEvalRunSucceeded = struct {
    created_at: i64,
    id: []const u8,
    data: struct {
        id: []const u8,
    },
    object: ?[]const u8,
    type: []const u8,
};
pub const WebhookFineTuningJobCancelled = struct {
    created_at: i64,
    id: []const u8,
    data: struct {
        id: []const u8,
    },
    object: ?[]const u8,
    type: []const u8,
};
pub const WebhookFineTuningJobFailed = struct {
    created_at: i64,
    id: []const u8,
    data: struct {
        id: []const u8,
    },
    object: ?[]const u8,
    type: []const u8,
};
pub const WebhookFineTuningJobSucceeded = struct {
    created_at: i64,
    id: []const u8,
    data: struct {
        id: []const u8,
    },
    object: ?[]const u8,
    type: []const u8,
};
pub const WebhookRealtimeCallIncoming = struct {
    created_at: i64,
    id: []const u8,
    data: struct {
        call_id: []const u8,
        sip_headers: []const struct {
            name: []const u8,
            value: []const u8,
        },
    },
    object: ?[]const u8,
    type: []const u8,
};
pub const WebhookResponseCancelled = struct {
    created_at: i64,
    id: []const u8,
    data: struct {
        id: []const u8,
    },
    object: ?[]const u8,
    type: []const u8,
};
pub const WebhookResponseCompleted = struct {
    created_at: i64,
    id: []const u8,
    data: struct {
        id: []const u8,
    },
    object: ?[]const u8,
    type: []const u8,
};
pub const WebhookResponseFailed = struct {
    created_at: i64,
    id: []const u8,
    data: struct {
        id: []const u8,
    },
    object: ?[]const u8,
    type: []const u8,
};
pub const WebhookResponseIncomplete = struct {
    created_at: i64,
    id: []const u8,
    data: struct {
        id: []const u8,
    },
    object: ?[]const u8,
    type: []const u8,
};
pub const WidgetMessageItem = struct {
    id: []const u8,
    object: []const u8,
    created_at: i64,
    thread_id: []const u8,
    type: []const u8,
    widget: []const u8,
};
pub const WorkflowParam = struct {
    id: []const u8,
    version: ?[]const u8,
    state_variables: ?std.json.Value,
    tracing: ?WorkflowTracingParam,
};
pub const WorkflowTracingParam = struct {
    enabled: ?bool,
};
