const std = @import("std");

pub const JsonObject = std.json.Value;
pub const JsonObjectArray = []const JsonObject;
pub const EvalDataSourceConfig = JsonObject;
pub const EvalTestingCriterion = JsonObject;
pub const EvalSchema = JsonObject;
pub const EvalSample = JsonObject;
pub const EvalDatasourceItem = JsonObject;
pub const GenericContent = union(enum) {
    text: []const u8,
    items: JsonObjectArray,
    raw: JsonObject,

    pub fn forText(value: []const u8) GenericContent {
        return .{ .text = value };
    }

    pub fn forItems(value: JsonObjectArray) GenericContent {
        return .{ .items = value };
    }

    pub fn forRaw(value: JsonObject) GenericContent {
        return .{ .raw = value };
    }

    pub fn jsonStringify(self: GenericContent, writer: anytype) !void {
        switch (self) {
            .text => |value| try writer.write(value),
            .items => |value| try writer.write(value),
            .raw => |value| try writer.write(value),
        }
    }

    pub fn jsonParse(allocator: std.mem.Allocator, source: anytype, options: std.json.ParseOptions) !GenericContent {
        const parsed = try std.json.Value.jsonParse(allocator, source, options);
        return try jsonParseFromValue(allocator, parsed, options);
    }

    pub fn jsonParseFromValue(
        allocator: std.mem.Allocator,
        source: std.json.Value,
        options: std.json.ParseOptions,
    ) !GenericContent {
        switch (source) {
            .string => return .{ .text = source.string },
            .array => {
                const parsed = std.json.parseFromValue(JsonObjectArray, allocator, source, options) catch return .{ .raw = source };
                defer parsed.deinit();
                return .{ .items = parsed.value };
            },
            else => return .{ .raw = source },
        }
    }
};
pub const EvalGraderConfig = union(enum) {
    label_model: GraderLabelModel,
    multi: GraderMulti,
    python: GraderPython,
    score_model: GraderScoreModel,
    string_check: GraderStringCheck,
    text_similarity: GraderTextSimilarity,
    raw: JsonObject,

    pub fn forRaw(value: JsonObject) EvalGraderConfig {
        return .{ .raw = value };
    }

    pub fn jsonStringify(self: EvalGraderConfig, writer: anytype) !void {
        switch (self) {
            .label_model => |value| try writer.write(value),
            .multi => |value| try writer.write(value),
            .python => |value| try writer.write(value),
            .score_model => |value| try writer.write(value),
            .string_check => |value| try writer.write(value),
            .text_similarity => |value| try writer.write(value),
            .raw => |value| try writer.write(value),
        }
    }

    pub fn jsonParse(allocator: std.mem.Allocator, source: anytype, options: std.json.ParseOptions) !EvalGraderConfig {
        const parsed = try std.json.Value.jsonParse(allocator, source, options);
        return jsonParseFromValue(allocator, parsed, options);
    }

    pub fn jsonParseFromValue(
        allocator: std.mem.Allocator,
        source: std.json.Value,
        options: std.json.ParseOptions,
    ) !EvalGraderConfig {
        switch (source) {
            .object => |root| {
                if (root.get("type")) |kind| {
                    if (kind == .string) {
                        if (std.mem.eql(u8, kind.string, "label_model")) {
                            const parsed = std.json.parseFromValue(GraderLabelModel, allocator, source, options) catch return .{ .raw = source };
                            defer parsed.deinit();
                            return .{ .label_model = parsed.value };
                        }

                        if (std.mem.eql(u8, kind.string, "multi")) {
                            const parsed = std.json.parseFromValue(GraderMulti, allocator, source, options) catch return .{ .raw = source };
                            defer parsed.deinit();
                            return .{ .multi = parsed.value };
                        }

                        if (std.mem.eql(u8, kind.string, "python")) {
                            const parsed = std.json.parseFromValue(GraderPython, allocator, source, options) catch return .{ .raw = source };
                            defer parsed.deinit();
                            return .{ .python = parsed.value };
                        }

                        if (std.mem.eql(u8, kind.string, "score_model")) {
                            const parsed = std.json.parseFromValue(GraderScoreModel, allocator, source, options) catch return .{ .raw = source };
                            defer parsed.deinit();
                            return .{ .score_model = parsed.value };
                        }

                        if (std.mem.eql(u8, kind.string, "string_check")) {
                            const parsed = std.json.parseFromValue(GraderStringCheck, allocator, source, options) catch return .{ .raw = source };
                            defer parsed.deinit();
                            return .{ .string_check = parsed.value };
                        }

                        if (std.mem.eql(u8, kind.string, "text_similarity")) {
                            const parsed = std.json.parseFromValue(GraderTextSimilarity, allocator, source, options) catch return .{ .raw = source };
                            defer parsed.deinit();
                            return .{ .text_similarity = parsed.value };
                        }
                    }
                }

                if (std.json.parseFromValue(GraderMulti, allocator, source, options)) |parsed| {
                    defer parsed.deinit();
                    return .{ .multi = parsed.value };
                } else |_| {}

                if (std.json.parseFromValue(GraderLabelModel, allocator, source, options)) |parsed| {
                    defer parsed.deinit();
                    return .{ .label_model = parsed.value };
                } else |_| {}

                if (std.json.parseFromValue(GraderScoreModel, allocator, source, options)) |parsed| {
                    defer parsed.deinit();
                    return .{ .score_model = parsed.value };
                } else |_| {}

                if (std.json.parseFromValue(GraderPython, allocator, source, options)) |parsed| {
                    defer parsed.deinit();
                    return .{ .python = parsed.value };
                } else |_| {}

                if (std.json.parseFromValue(GraderStringCheck, allocator, source, options)) |parsed| {
                    defer parsed.deinit();
                    return .{ .string_check = parsed.value };
                } else |_| {}

                if (std.json.parseFromValue(GraderTextSimilarity, allocator, source, options)) |parsed| {
                    defer parsed.deinit();
                    return .{ .text_similarity = parsed.value };
                } else |_| {}

                return .{ .raw = source };
            },
            else => return .{ .raw = source },
        }
    }
};
pub const ToolOutputPayload = JsonObject;
pub const RealtimeObfuscation = JsonObject;

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
    last_used_at: ?i64,
    owner: struct {
        type: ?[]const u8,
        object: ?[]const u8,
        id: ?[]const u8,
        name: ?[]const u8,
        created_at: ?i64,
        role: ?[]const u8,
    },
};
pub const UrlCitation = struct {
    end_index: i64,
    start_index: i64,
    url: []const u8,
    title: []const u8,
};

pub const Annotation = struct {
    type: []const u8,
    url_citation: UrlCitation,
};
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
pub const ApplyPatchOperationParam = struct {
    type: []const u8,
    path: []const u8,
    diff: ?[]const u8 = null,
};
pub const ApplyPatchToolCall = struct {
    type: []const u8,
    id: []const u8,
    call_id: []const u8,
    status: ApplyPatchCallStatus,
    operation: ApplyPatchOperationParam,
    created_by: ?[]const u8,
};
pub const ApplyPatchToolCallItemParam = struct {
    type: []const u8,
    id: ?[]const u8,
    call_id: []const u8,
    status: ApplyPatchCallStatusParam,
    operation: ApplyPatchOperationParam,
};
pub const ApplyPatchToolCallOutput = struct {
    type: []const u8,
    id: []const u8,
    call_id: []const u8,
    status: ApplyPatchCallOutputStatus,
    output: ?[]const u8,
    created_by: ?[]const u8,
};
pub const ApplyPatchToolCallOutputItemParam = struct {
    type: []const u8,
    id: ?[]const u8,
    call_id: []const u8,
    status: ApplyPatchCallOutputStatusParam,
    output: ?[]const u8,
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
    country: ?[]const u8,
    region: ?[]const u8,
    city: ?[]const u8,
    timezone: ?[]const u8,
};
pub const AssignedRoleDetails = struct {
    id: []const u8,
    name: []const u8,
    permissions: []const []const u8,
    resource_type: []const u8,
    predefined_role: bool,
    description: ?[]const u8,
    created_at: ?i64,
    updated_at: ?i64,
    created_by: ?[]const u8,
    created_by_user_obj: JsonObject,
    metadata: Metadata,
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
    name: ?[]const u8,
    description: ?[]const u8,
    model: []const u8,
    instructions: ?[]const u8,
    tools: []const AssistantTool,
    tool_resources: ?AssistantToolResources,
    metadata: Metadata,
    temperature: ?f64,
    top_p: ?f64,
    response_format: ?AssistantsApiResponseFormatOption,
};
pub const AssistantStreamEvent = union(enum) {
    thread: ThreadStreamEvent,
    run: RunStreamEvent,
    run_step: RunStepStreamEvent,
    message: MessageStreamEvent,
    err: ErrorEvent,
    raw: std.json.Value,

    pub fn forThread(value: ThreadStreamEvent) AssistantStreamEvent {
        return .{ .thread = value };
    }

    pub fn forRun(value: RunStreamEvent) AssistantStreamEvent {
        return .{ .run = value };
    }

    pub fn forRunStep(value: RunStepStreamEvent) AssistantStreamEvent {
        return .{ .run_step = value };
    }

    pub fn forMessage(value: MessageStreamEvent) AssistantStreamEvent {
        return .{ .message = value };
    }

    pub fn forError(value: ErrorEvent) AssistantStreamEvent {
        return .{ .err = value };
    }

    pub fn forRaw(value: std.json.Value) AssistantStreamEvent {
        return .{ .raw = value };
    }

    pub fn jsonStringify(self: AssistantStreamEvent, writer: anytype) !void {
        switch (self) {
            .thread => |value| {
                try writer.write(value);
            },
            .run => |value| {
                try writer.write(value);
            },
            .run_step => |value| {
                try writer.write(value);
            },
            .message => |value| {
                try writer.write(value);
            },
            .err => |value| {
                try writer.write(value);
            },
            .raw => |value| {
                try writer.write(value);
            },
        }
    }

    pub fn jsonParse(allocator: std.mem.Allocator, source: anytype, options: std.json.ParseOptions) !AssistantStreamEvent {
        const parsed = try std.json.Value.jsonParse(allocator, source, options);
        return jsonParseFromValue(allocator, parsed, options);
    }

    pub fn jsonParseFromValue(
        allocator: std.mem.Allocator,
        source: std.json.Value,
        options: std.json.ParseOptions,
    ) !AssistantStreamEvent {
        switch (source) {
            .object => |root| {
                const event = root.get("event") orelse return .{ .raw = source };
                if (event != .string) return .{ .raw = source };

                if (std.mem.eql(u8, event.string, "thread.created")) {
                    const parsed = std.json.parseFromValue(
                        ThreadStreamEvent,
                        allocator,
                        source,
                        options,
                    ) catch return .{ .raw = source };
                    defer parsed.deinit();
                    return .{ .thread = parsed.value };
                }

                if (std.mem.startsWith(u8, event.string, "thread.run.step.")) {
                    const parsed = std.json.parseFromValue(
                        RunStepStreamEvent,
                        allocator,
                        source,
                        options,
                    ) catch return .{ .raw = source };
                    defer parsed.deinit();
                    return .{ .run_step = parsed.value };
                }

                if (std.mem.startsWith(u8, event.string, "thread.run.")) {
                    const parsed = std.json.parseFromValue(
                        RunStreamEvent,
                        allocator,
                        source,
                        options,
                    ) catch return .{ .raw = source };
                    defer parsed.deinit();
                    return .{ .run = parsed.value };
                }

                if (std.mem.startsWith(u8, event.string, "thread.message.")) {
                    const parsed = std.json.parseFromValue(
                        MessageStreamEvent,
                        allocator,
                        source,
                        options,
                    ) catch return .{ .raw = source };
                    defer parsed.deinit();
                    return .{ .message = parsed.value };
                }

                if (std.mem.eql(u8, event.string, "error")) {
                    const parsed = std.json.parseFromValue(
                        ErrorEvent,
                        allocator,
                        source,
                        options,
                    ) catch return .{ .raw = source };
                    defer parsed.deinit();
                    return .{ .err = parsed.value };
                }

                return .{ .raw = source };
            },
            else => return .{ .raw = source },
        }
    }
};
pub const AssistantSupportedModels = []const u8;
pub const AssistantTool = struct {
    type: []const u8,
    function: ?FunctionObject = null,
    file_search: ?struct {
        max_num_results: ?i64,
        ranking_options: ?FileSearchRankingOptions,
    } = null,
};
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
pub const AssistantToolResources = struct {
    code_interpreter: ?struct {
        file_ids: ?[]const []const u8 = null,
    } = null,
    file_search: ?struct {
        vector_store_ids: ?[]const []const u8 = null,
    } = null,
};
pub const AssistantsApiResponseFormatOption = union(enum) {
    auto: void,
    text: ResponseFormatText,
    json_object: ResponseFormatJsonObject,
    json_schema: ResponseFormatJsonSchema,
    raw: std.json.Value,

    pub fn forAuto() AssistantsApiResponseFormatOption {
        return .auto;
    }

    pub fn forJsonObject() AssistantsApiResponseFormatOption {
        return .{ .json_object = .{ .type = "json_object" } };
    }

    pub fn forText() AssistantsApiResponseFormatOption {
        return .{ .text = .{ .type = "text" } };
    }

    pub fn forJsonSchema(json_schema: ResponseFormatJsonSchema) AssistantsApiResponseFormatOption {
        return .{ .json_schema = json_schema };
    }

    pub fn forRaw(value: std.json.Value) AssistantsApiResponseFormatOption {
        return .{ .raw = value };
    }

    pub fn jsonStringify(self: AssistantsApiResponseFormatOption, writer: anytype) !void {
        switch (self) {
            .auto => {
                try writer.write("auto");
            },
            .text => |value| {
                try writer.write(value);
            },
            .json_object => |value| {
                try writer.write(value);
            },
            .json_schema => |value| {
                try writer.write(value);
            },
            .raw => |value| {
                try writer.write(value);
            },
        }
    }

    pub fn jsonParse(allocator: std.mem.Allocator, source: anytype, options: std.json.ParseOptions) !AssistantsApiResponseFormatOption {
        const parsed = try std.json.Value.jsonParse(allocator, source, options);
        return jsonParseFromValue(allocator, parsed, options);
    }

    pub fn jsonParseFromValue(
        allocator: std.mem.Allocator,
        source: std.json.Value,
        options: std.json.ParseOptions,
    ) !AssistantsApiResponseFormatOption {
        _ = allocator;
        _ = options;

        switch (source) {
            .string => |value| {
                if (std.mem.eql(u8, value, "auto")) {
                    return .auto;
                }
                return .{ .raw = source };
            },
            .object => |root| {
                const kind = root.get("type") orelse return .{ .raw = source };
                if (kind != .string) return .{ .raw = source };

                if (std.mem.eql(u8, kind.string, "text")) {
                    return .{ .text = .{ .type = kind.string } };
                }

                if (std.mem.eql(u8, kind.string, "json_object")) {
                    return .{ .json_object = .{ .type = kind.string } };
                }

                if (std.mem.eql(u8, kind.string, "json_schema")) {
                    const schema_payload = root.get("json_schema") orelse return .{ .raw = source };
                    if (schema_payload != .object) return .{ .raw = source };
                    const schema_root = schema_payload.object;

                    const schema_name = schema_root.get("name") orelse return .{ .raw = source };
                    if (schema_name != .string) return .{ .raw = source };

                    return .{
                        .json_schema = .{
                            .type = kind.string,
                            .json_schema = .{
                                .description = if (schema_root.get("description")) |description| if (description == .string) description.string else null else null,
                                .name = schema_name.string,
                                .schema = if (schema_root.get("schema")) |schema| if (schema == .null) null else schema else null,
                                .strict = if (schema_root.get("strict")) |strict| if (strict == .bool) strict.bool else null else null,
                            },
                        },
                    };
                }

                return .{ .raw = source };
            },
            else => return .{ .raw = source },
        }
    }
};
pub const AssistantsApiToolChoiceOption = ToolChoiceParam;
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
    preview_url: []const u8,
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
        data: ?JsonObject,
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
    login_succeeded: ?JsonObject,
    login_failed: ?struct {
        error_code: ?[]const u8,
        error_message: ?[]const u8,
    },
    logout_succeeded: ?JsonObject,
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
            metadata: ?Metadata,
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
    param: ?[]const u8,
    line: ?i64,
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
    response: ?BatchRequestOutputResponse,
    _error: ?BatchRequestOutputError,
};

pub const BatchRequestOutputResponse = struct {
    status_code: ?i64 = null,
    request_id: ?[]const u8 = null,
    headers: ?JsonObject = null,
    body: ?JsonObject = null,
};

pub const BatchRequestOutputError = struct {
    code: ?[]const u8 = null,
    message: ?[]const u8 = null,
    param: ?[]const u8 = null,
    type: ?[]const u8 = null,
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
    tools: []const ToolChoiceTypes,
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
    data: []const ChatCompletionResponseMessage,
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
pub const ChatCompletionMessageToolCalls = []const ChatCompletionMessageToolCall;
pub const ChatCompletionModalities = []const []const u8;
pub const ChatCompletionChoice = struct {
    index: i64 = 0,
    message: ?ChatCompletionResponseMessage = null,
    logprobs: ?ChatCompletionChoiceLogprobs = null,
    finish_reason: ?[]const u8 = null,
};
pub const ChatCompletionChoiceLogprobs = struct {
    content: ?[]const ChatCompletionTokenLogprob = null,
    refusal: ?[]const ChatCompletionTokenLogprob = null,
};
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
    content: ?ChatCompletionRequestAssistantMessageContent,
    refusal: ?[]const u8,
    role: []const u8,
    name: ?[]const u8,
    audio: ?ChatCompletionRequestAssistantMessageAudio,
    tool_calls: ?ChatCompletionMessageToolCalls,
    function_call: ?ChatCompletionRequestFunctionCall,
};
pub const ChatCompletionRequestAssistantMessageAudio = struct {
    id: []const u8,
};
pub const ChatCompletionRequestFunctionCall = struct {
    arguments: []const u8,
    name: []const u8,
};
pub const ChatCompletionRequestAssistantMessageContent = union(enum) {
    text: []const u8,
    parts: []const ChatCompletionRequestAssistantMessageContentPart,
    raw: std.json.Value,

    pub fn jsonStringify(self: ChatCompletionRequestAssistantMessageContent, writer: anytype) !void {
        switch (self) {
            .text => |value| {
                try writer.write(value);
            },
            .parts => |value| {
                try writer.write(value);
            },
            .raw => |value| {
                try writer.write(value);
            },
        }
    }
};
pub const ChatCompletionRequestAssistantMessageContentPart = union(enum) {
    text: ChatCompletionRequestMessageContentPartText,
    refusal: ChatCompletionRequestMessageContentPartRefusal,
    raw: std.json.Value,

    pub fn jsonStringify(self: ChatCompletionRequestAssistantMessageContentPart, writer: anytype) !void {
        switch (self) {
            .text => |value| {
                try writer.write(value);
            },
            .refusal => |value| {
                try writer.write(value);
            },
            .raw => |value| {
                try writer.write(value);
            },
        }
    }
};
pub const ChatCompletionRequestDeveloperMessage = struct {
    content: ChatCompletionRequestDeveloperMessageContent,
    role: []const u8,
    name: ?[]const u8,
};
pub const ChatCompletionRequestDeveloperMessageContent = union(enum) {
    text: []const u8,
    parts: []const ChatCompletionRequestMessageContentPartText,
    raw: std.json.Value,

    pub fn jsonStringify(self: ChatCompletionRequestDeveloperMessageContent, writer: anytype) !void {
        switch (self) {
            .text => |value| {
                try writer.write(value);
            },
            .parts => |value| {
                try writer.write(value);
            },
            .raw => |value| {
                try writer.write(value);
            },
        }
    }
};
pub const ChatCompletionRequestFunctionMessage = struct {
    role: []const u8,
    content: ?[]const u8,
    name: []const u8,
};
pub const ChatCompletionRequestMessage = union(enum) {
    developer: ChatCompletionRequestDeveloperMessage,
    system: ChatCompletionRequestSystemMessage,
    user: ChatCompletionRequestUserMessage,
    assistant: ChatCompletionRequestAssistantMessage,
    tool: ChatCompletionRequestToolMessage,
    function: ChatCompletionRequestFunctionMessage,
    raw: std.json.Value,

    pub fn jsonStringify(self: ChatCompletionRequestMessage, writer: anytype) !void {
        switch (self) {
            .developer => |value| {
                try writer.write(value);
            },
            .system => |value| {
                try writer.write(value);
            },
            .user => |value| {
                try writer.write(value);
            },
            .assistant => |value| {
                try writer.write(value);
            },
            .tool => |value| {
                try writer.write(value);
            },
            .function => |value| {
                try writer.write(value);
            },
            .raw => |value| {
                try writer.write(value);
            },
        }
    }

    pub fn jsonParse(allocator: std.mem.Allocator, source: anytype, options: std.json.ParseOptions) !ChatCompletionRequestMessage {
        const parsed = try std.json.Value.jsonParse(allocator, source, options);
        return try jsonParseFromValue(allocator, parsed, options);
    }

    pub fn jsonParseFromValue(
        allocator: std.mem.Allocator,
        source: std.json.Value,
        options: std.json.ParseOptions,
    ) !ChatCompletionRequestMessage {
        switch (source) {
            .object => |root| {
                const role = root.get("role") orelse return .{ .raw = source };
                if (role != .string) return .{ .raw = source };

                if (std.mem.eql(u8, role.string, "developer")) {
                    const parsed = std.json.parseFromValue(
                        ChatCompletionRequestDeveloperMessage,
                        allocator,
                        source,
                        options,
                    ) catch return .{ .raw = source };
                    defer parsed.deinit();
                    return .{ .developer = parsed.value };
                }

                if (std.mem.eql(u8, role.string, "system")) {
                    const parsed = std.json.parseFromValue(
                        ChatCompletionRequestSystemMessage,
                        allocator,
                        source,
                        options,
                    ) catch return .{ .raw = source };
                    defer parsed.deinit();
                    return .{ .system = parsed.value };
                }

                if (std.mem.eql(u8, role.string, "user")) {
                    const parsed = std.json.parseFromValue(
                        ChatCompletionRequestUserMessage,
                        allocator,
                        source,
                        options,
                    ) catch return .{ .raw = source };
                    defer parsed.deinit();
                    return .{ .user = parsed.value };
                }

                if (std.mem.eql(u8, role.string, "assistant")) {
                    const parsed = std.json.parseFromValue(
                        ChatCompletionRequestAssistantMessage,
                        allocator,
                        source,
                        options,
                    ) catch return .{ .raw = source };
                    defer parsed.deinit();
                    return .{ .assistant = parsed.value };
                }

                if (std.mem.eql(u8, role.string, "tool")) {
                    const parsed = std.json.parseFromValue(
                        ChatCompletionRequestToolMessage,
                        allocator,
                        source,
                        options,
                    ) catch return .{ .raw = source };
                    defer parsed.deinit();
                    return .{ .tool = parsed.value };
                }

                if (std.mem.eql(u8, role.string, "function")) {
                    const parsed = std.json.parseFromValue(
                        ChatCompletionRequestFunctionMessage,
                        allocator,
                        source,
                        options,
                    ) catch return .{ .raw = source };
                    defer parsed.deinit();
                    return .{ .function = parsed.value };
                }

                return .{ .raw = source };
            },
            else => return .{ .raw = source },
        }
    }
};
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
    content: ChatCompletionRequestSystemMessageContent,
    role: []const u8,
    name: ?[]const u8,
};
pub const ChatCompletionRequestSystemMessageContent = union(enum) {
    text: []const u8,
    parts: []const ChatCompletionRequestSystemMessageContentPart,
    raw: std.json.Value,

    pub fn jsonStringify(self: ChatCompletionRequestSystemMessageContent, writer: anytype) !void {
        switch (self) {
            .text => |value| {
                try writer.write(value);
            },
            .parts => |value| {
                try writer.write(value);
            },
            .raw => |value| {
                try writer.write(value);
            },
        }
    }
};
pub const ChatCompletionRequestSystemMessageContentPart = ChatCompletionRequestMessageContentPartText;
pub const ChatCompletionRequestToolMessage = struct {
    role: []const u8,
    content: ChatCompletionRequestToolMessageContent,
    tool_call_id: []const u8,
};
pub const ChatCompletionRequestToolMessageContent = union(enum) {
    text: []const u8,
    parts: []const ChatCompletionRequestToolMessageContentPart,
    raw: std.json.Value,

    pub fn jsonStringify(self: ChatCompletionRequestToolMessageContent, writer: anytype) !void {
        switch (self) {
            .text => |value| {
                try writer.write(value);
            },
            .parts => |value| {
                try writer.write(value);
            },
            .raw => |value| {
                try writer.write(value);
            },
        }
    }
};
pub const ChatCompletionRequestToolMessageContentPart = ChatCompletionRequestMessageContentPartText;
pub const ChatCompletionRequestUserMessage = struct {
    content: ChatCompletionRequestUserMessageContent,
    role: []const u8,
    name: ?[]const u8,
};
pub const ChatCompletionRequestUserMessageContent = union(enum) {
    text: []const u8,
    parts: []const ChatCompletionRequestUserMessageContentPart,
    raw: std.json.Value,

    pub fn jsonStringify(self: ChatCompletionRequestUserMessageContent, writer: anytype) !void {
        switch (self) {
            .text => |value| {
                try writer.write(value);
            },
            .parts => |value| {
                try writer.write(value);
            },
            .raw => |value| {
                try writer.write(value);
            },
        }
    }
};
pub const ChatCompletionRequestUserMessageContentPart = union(enum) {
    text: ChatCompletionRequestMessageContentPartText,
    image: ChatCompletionRequestMessageContentPartImage,
    audio: ChatCompletionRequestMessageContentPartAudio,
    file: ChatCompletionRequestMessageContentPartFile,
    raw: std.json.Value,

    pub fn jsonStringify(self: ChatCompletionRequestUserMessageContentPart, writer: anytype) !void {
        switch (self) {
            .text => |value| {
                try writer.write(value);
            },
            .image => |value| {
                try writer.write(value);
            },
            .audio => |value| {
                try writer.write(value);
            },
            .file => |value| {
                try writer.write(value);
            },
            .raw => |value| {
                try writer.write(value);
            },
        }
    }
};
pub const ChatCompletionResponseMessage = struct {
    content: ?[]const u8 = null,
    refusal: ?[]const u8 = null,
    reasoning_content: ?[]const u8 = null,
    tool_calls: ?ChatCompletionMessageToolCalls = null,
    annotations: ?[]const Annotation = null,
    role: ?[]const u8 = null,
    function_call: ?ChatCompletionRequestFunctionCall = null,
    audio: ?ChatCompletionResponseMessageAudio = null,
};

pub const ChatCompletionResponseMessageAudio = struct {
    id: []const u8,
    expires_at: i64,
    data: []const u8,
    transcript: []const u8,
};
pub const ChatCompletionRole = []const u8;
pub const ChatCompletionStreamOptions = struct {
    include_usage: ?bool = null,
    include_obfuscation: ?bool = null,
};
pub const ChatCompletionStreamResponseDelta = struct {
    content: ?[]const u8,
    reasoning_content: ?[]const u8 = null,
    function_call: ?struct {
        arguments: ?[]const u8,
        name: ?[]const u8,
    },
    tool_calls: ?[]const ChatCompletionMessageToolCallChunk,
    role: ?[]const u8,
    refusal: ?[]const u8,
    audio: ?ChatCompletionResponseMessageAudio = null,
};
pub const ChatCompletionTokenLogprob = struct {
    token: []const u8,
    logprob: f64,
    bytes: ?[]const i64,
    top_logprobs: []const struct {
        token: []const u8,
        logprob: f64,
        bytes: ?[]const i64,
    },
};
pub const ChatCompletionTool = struct {
    type: []const u8,
    function: FunctionObject,
};
pub const ChatCompletionToolChoiceOption = ToolChoiceParam;
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
    max_file_size: ?i64,
    max_files: ?i64,
};
pub const ChatSessionHistory = struct {
    enabled: bool,
    recent_threads: ?i64,
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
    version: ?[]const u8,
    state_variables: ResponsePromptVariables,
    tracing: ChatkitWorkflowTracing,
};
pub const ChatkitWorkflowTracing = struct {
    enabled: bool,
};
pub const ChunkingStrategyRequestParam = union(enum) {
    auto: AutoChunkingStrategyRequestParam,
    static: StaticChunkingStrategyRequestParam,
    other: OtherChunkingStrategyResponseParam,
    raw: std.json.Value,

    pub fn forAuto() ChunkingStrategyRequestParam {
        return .{ .auto = .{ .type = "auto" } };
    }

    pub fn forStatic(value: StaticChunkingStrategy) ChunkingStrategyRequestParam {
        return .{
            .static = .{
                .type = "static",
                .static = value,
            },
        };
    }

    pub fn forOther(value: []const u8) ChunkingStrategyRequestParam {
        return .{ .other = .{ .type = value } };
    }

    pub fn forRaw(value: std.json.Value) ChunkingStrategyRequestParam {
        return .{ .raw = value };
    }

    pub fn jsonStringify(self: ChunkingStrategyRequestParam, writer: anytype) !void {
        switch (self) {
            .auto => |value| {
                try writer.write(value);
            },
            .static => |value| {
                try writer.write(value);
            },
            .other => |value| {
                try writer.write(value);
            },
            .raw => |value| {
                try writer.write(value);
            },
        }
    }

    pub fn jsonParse(allocator: std.mem.Allocator, source: anytype, options: std.json.ParseOptions) !ChunkingStrategyRequestParam {
        const parsed = try std.json.Value.jsonParse(allocator, source, options);
        return jsonParseFromValue(allocator, parsed, options);
    }

    pub fn jsonParseFromValue(
        allocator: std.mem.Allocator,
        source: std.json.Value,
        options: std.json.ParseOptions,
    ) !ChunkingStrategyRequestParam {
        _ = allocator;
        _ = options;

        switch (source) {
            .string => |value| {
                if (std.mem.eql(u8, value, "auto")) {
                    return .{ .auto = .{ .type = value } };
                }
                return .{ .raw = source };
            },
            .object => |root| {
                const kind = root.get("type") orelse return .{ .raw = source };
                if (kind != .string) return .{ .raw = source };

                if (std.mem.eql(u8, kind.string, "auto")) {
                    return .{ .auto = .{ .type = kind.string } };
                }

                if (std.mem.eql(u8, kind.string, "static")) {
                    const static_payload = root.get("static") orelse return .{ .raw = source };
                    if (static_payload != .object) return .{ .raw = source };
                    const static_root = static_payload.object;

                    const max_chunk_size_tokens = static_root.get("max_chunk_size_tokens") orelse return .{ .raw = source };
                    const chunk_overlap_tokens = static_root.get("chunk_overlap_tokens") orelse return .{ .raw = source };
                    if (max_chunk_size_tokens != .integer or chunk_overlap_tokens != .integer) return .{ .raw = source };

                    return .{
                        .static = .{
                            .type = kind.string,
                            .static = .{
                                .max_chunk_size_tokens = max_chunk_size_tokens.integer,
                                .chunk_overlap_tokens = chunk_overlap_tokens.integer,
                            },
                        },
                    };
                }

                if (std.mem.eql(u8, kind.string, "other")) {
                    return .{ .other = .{ .type = kind.string } };
                }

                return .{ .other = .{ .type = kind.string } };
            },
            else => return .{ .raw = source },
        }
    }
};
pub const ChunkingStrategyResponse = union(enum) {
    auto: AutoChunkingStrategyRequestParam,
    static: StaticChunkingStrategyResponseParam,
    other: OtherChunkingStrategyResponseParam,
    raw: std.json.Value,

    pub fn forAuto() ChunkingStrategyResponse {
        return .{ .auto = .{ .type = "auto" } };
    }

    pub fn forStatic(value: StaticChunkingStrategy) ChunkingStrategyResponse {
        return .{
            .static = .{
                .type = "static",
                .static = value,
            },
        };
    }

    pub fn forOther(value: []const u8) ChunkingStrategyResponse {
        return .{ .other = .{ .type = value } };
    }

    pub fn forRaw(value: std.json.Value) ChunkingStrategyResponse {
        return .{ .raw = value };
    }

    pub fn jsonStringify(self: ChunkingStrategyResponse, writer: anytype) !void {
        switch (self) {
            .auto => |value| {
                try writer.write(value);
            },
            .static => |value| {
                try writer.write(value);
            },
            .other => |value| {
                try writer.write(value);
            },
            .raw => |value| {
                try writer.write(value);
            },
        }
    }

    pub fn jsonParse(allocator: std.mem.Allocator, source: anytype, options: std.json.ParseOptions) !ChunkingStrategyResponse {
        const parsed = try std.json.Value.jsonParse(allocator, source, options);
        return jsonParseFromValue(allocator, parsed, options);
    }

    pub fn jsonParseFromValue(
        allocator: std.mem.Allocator,
        source: std.json.Value,
        options: std.json.ParseOptions,
    ) !ChunkingStrategyResponse {
        _ = allocator;
        _ = options;

        switch (source) {
            .string => |value| {
                if (std.mem.eql(u8, value, "auto")) {
                    return .{ .auto = .{ .type = value } };
                }
                return .{ .raw = source };
            },
            .object => |root| {
                const kind = root.get("type") orelse return .{ .raw = source };
                if (kind != .string) return .{ .raw = source };

                if (std.mem.eql(u8, kind.string, "auto")) {
                    return .{ .auto = .{ .type = kind.string } };
                }

                if (std.mem.eql(u8, kind.string, "static")) {
                    const static_payload = root.get("static") orelse return .{ .raw = source };
                    if (static_payload != .object) return .{ .raw = source };
                    const static_root = static_payload.object;

                    const max_chunk_size_tokens = static_root.get("max_chunk_size_tokens") orelse return .{ .raw = source };
                    const chunk_overlap_tokens = static_root.get("chunk_overlap_tokens") orelse return .{ .raw = source };
                    if (max_chunk_size_tokens != .integer or chunk_overlap_tokens != .integer) return .{ .raw = source };

                    return .{
                        .static = .{
                            .type = kind.string,
                            .static = .{
                                .max_chunk_size_tokens = max_chunk_size_tokens.integer,
                                .chunk_overlap_tokens = chunk_overlap_tokens.integer,
                            },
                        },
                    };
                }

                if (std.mem.eql(u8, kind.string, "other")) {
                    return .{ .other = .{ .type = kind.string } };
                }

                return .{ .other = .{ .type = kind.string } };
            },
            else => return .{ .raw = source },
        }
    }
};
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
    output: ?[]const u8,
};
pub const ClientToolCallStatus = []const u8;
pub const ClosedStatus = struct {
    type: []const u8,
    reason: ?[]const u8,
};
pub const CodeInterpreterContainerAuto = struct {
    type: []const u8,
    file_ids: ?[]const []const u8,
    memory_limit: ?ContainerMemoryLimit,
};
pub const CodeInterpreterToolContainer = union(enum) {
    auto: CodeInterpreterContainerAuto,
    raw: std.json.Value,

    pub fn forAuto(container: CodeInterpreterContainerAuto) CodeInterpreterToolContainer {
        return .{ .auto = container };
    }

    pub fn forRaw(value: std.json.Value) CodeInterpreterToolContainer {
        return .{ .raw = value };
    }

    pub fn jsonStringify(self: CodeInterpreterToolContainer, writer: anytype) !void {
        switch (self) {
            .auto => |value| {
                try writer.write(value);
            },
            .raw => |value| {
                try writer.write(value);
            },
        }
    }

    pub fn jsonParse(
        allocator: std.mem.Allocator,
        source: anytype,
        options: std.json.ParseOptions,
    ) !CodeInterpreterToolContainer {
        const parsed = try std.json.Value.jsonParse(allocator, source, options);
        return jsonParseFromValue(allocator, parsed, options);
    }

    pub fn jsonParseFromValue(
        allocator: std.mem.Allocator,
        source: std.json.Value,
        options: std.json.ParseOptions,
    ) !CodeInterpreterToolContainer {
        switch (source) {
            .object => |root| {
                const kind = root.get("type") orelse return .{ .raw = source };
                if (kind != .string) return .{ .raw = source };

                if (std.mem.eql(u8, kind.string, "auto")) {
                    const parsed = std.json.parseFromValue(
                        CodeInterpreterContainerAuto,
                        allocator,
                        source,
                        options,
                    ) catch return .{ .raw = source };
                    defer parsed.deinit();
                    return .{ .auto = parsed.value };
                }

                return .{ .raw = source };
            },
            else => return .{ .raw = source },
        }
    }
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
pub const CodeInterpreterOutput = union(enum) {
    image: CodeInterpreterOutputImage,
    logs: CodeInterpreterOutputLogs,
    text: CodeInterpreterTextOutput,
    file: CodeInterpreterFileOutput,
    raw: std.json.Value,

    pub fn jsonStringify(self: CodeInterpreterOutput, writer: anytype) !void {
        switch (self) {
            .image => |value| {
                try writer.write(value);
            },
            .logs => |value| {
                try writer.write(value);
            },
            .text => |value| {
                try writer.write(value);
            },
            .file => |value| {
                try writer.write(value);
            },
            .raw => |value| {
                try writer.write(value);
            },
        }
    }

    pub fn jsonParse(allocator: std.mem.Allocator, source: anytype, options: std.json.ParseOptions) !CodeInterpreterOutput {
        return .{
            .raw = try std.json.Value.jsonParse(allocator, source, options),
        };
    }

    pub fn jsonParseFromValue(
        allocator: std.mem.Allocator,
        source: std.json.Value,
        options: std.json.ParseOptions,
    ) !CodeInterpreterOutput {
        _ = allocator;
        _ = options;
        return .{ .raw = source };
    }
};
pub const CodeInterpreterTool = struct {
    type: []const u8,
    container: CodeInterpreterToolContainer,
};
pub const CodeInterpreterToolCall = struct {
    type: []const u8,
    id: []const u8,
    status: []const u8,
    container_id: []const u8,
    code: ?[]const u8,
    outputs: ?[]const CodeInterpreterOutput,
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
    input: ?InputParam,
    previous_response_id: ?[]const u8,
    instructions: ?[]const u8,
};
pub const CompactionBody = struct {
    type: []const u8,
    id: []const u8,
    encrypted_content: []const u8,
    created_by: ?[]const u8,
};
pub const CompactionSummaryItemParam = struct {
    id: ?[]const u8,
    type: []const u8,
    encrypted_content: []const u8,
};
pub const ComparisonFilter = struct {
    type: []const u8,
    key: []const u8,
    value: ComparisonFilterValue,
};
pub const ComparisonFilterValueItems = union(enum) {
    string: []const u8,
    number: f64,
    raw: std.json.Value,

    pub fn forString(value: []const u8) ComparisonFilterValueItems {
        return .{ .string = value };
    }

    pub fn forNumber(value: f64) ComparisonFilterValueItems {
        return .{ .number = value };
    }

    pub fn forRaw(value: std.json.Value) ComparisonFilterValueItems {
        return .{ .raw = value };
    }

    pub fn jsonStringify(self: ComparisonFilterValueItems, writer: anytype) !void {
        switch (self) {
            .string => |value| {
                try writer.write(value);
            },
            .number => |value| {
                try writer.write(value);
            },
            .raw => |value| {
                try writer.write(value);
            },
        }
    }

    pub fn jsonParse(
        allocator: std.mem.Allocator,
        source: anytype,
        options: std.json.ParseOptions,
    ) !ComparisonFilterValueItems {
        const parsed = try std.json.Value.jsonParse(allocator, source, options);
        return jsonParseFromValue(allocator, parsed, options);
    }

    pub fn jsonParseFromValue(
        allocator: std.mem.Allocator,
        source: std.json.Value,
        options: std.json.ParseOptions,
    ) !ComparisonFilterValueItems {
        _ = options;
        _ = allocator;
        return switch (source) {
            .string => .{ .string = source.string },
            .number => .{ .number = source.number },
            .null => .{ .raw = source },
            else => .{ .raw = source },
        };
    }
};
pub const ComparisonFilterValue = union(enum) {
    string: []const u8,
    number: f64,
    boolean: bool,
    items: []const ComparisonFilterValueItems,
    raw: std.json.Value,

    pub fn jsonStringify(self: ComparisonFilterValue, writer: anytype) !void {
        switch (self) {
            .string => |value| {
                try writer.write(value);
            },
            .number => |value| {
                try writer.write(value);
            },
            .boolean => |value| {
                try writer.write(value);
            },
            .items => |value| {
                try writer.beginArray();
                for (value) |item| {
                    try writer.write(item);
                }
                try writer.endArray();
            },
            .raw => |value| {
                try writer.write(value);
            },
        }
    }

    pub fn forString(value: []const u8) ComparisonFilterValue {
        return .{ .string = value };
    }

    pub fn forNumber(value: f64) ComparisonFilterValue {
        return .{ .number = value };
    }

    pub fn forBoolean(value: bool) ComparisonFilterValue {
        return .{ .boolean = value };
    }

    pub fn forItems(value: []const ComparisonFilterValueItems) ComparisonFilterValue {
        return .{ .items = value };
    }

    pub fn forRaw(value: std.json.Value) ComparisonFilterValue {
        return .{ .raw = value };
    }

    pub fn jsonParse(
        allocator: std.mem.Allocator,
        source: anytype,
        options: std.json.ParseOptions,
    ) !ComparisonFilterValue {
        const parsed = try std.json.Value.jsonParse(allocator, source, options);
        return jsonParseFromValue(allocator, parsed, options);
    }

    pub fn jsonParseFromValue(
        allocator: std.mem.Allocator,
        source: std.json.Value,
        options: std.json.ParseOptions,
    ) !ComparisonFilterValue {
        switch (source) {
            .string => return .{ .string = source.string },
            .number => return .{ .number = source.number },
            .bool => return .{ .boolean = source.bool },
            .array => |array| {
                var values = try allocator.alloc(ComparisonFilterValueItems, array.items.len);
                for (array.items, 0..) |item, i| {
                    values[i] = ComparisonFilterValueItems.jsonParseFromValue(allocator, item, options) catch {
                        allocator.free(values);
                        return .{ .raw = source };
                    };
                }
                return .{ .items = values };
            },
            else => return .{ .raw = source },
        }
    }
};
pub const CompleteUploadRequest = struct {
    part_ids: []const []const u8,
    md5: ?[]const u8,
};
pub const CompletionUsage = struct {
    completion_tokens: i64,
    prompt_tokens: i64,
    total_tokens: i64,
    prompt_cache_hit_tokens: ?i64 = null,
    prompt_cache_miss_tokens: ?i64 = null,
    completion_tokens_details: ?struct {
        accepted_prediction_tokens: ?i64 = null,
        audio_tokens: ?i64 = null,
        reasoning_tokens: ?i64 = null,
        rejected_prediction_tokens: ?i64 = null,
    } = null,
    prompt_tokens_details: ?struct {
        audio_tokens: ?i64 = null,
        cached_tokens: ?i64 = null,
    } = null,
};
pub const CompoundFilter = struct {
    type: []const u8,
    filters: []const Filters,
};
pub const Filters = union(enum) {
    comparison: ComparisonFilter,
    compound: CompoundFilter,
    raw: std.json.Value,

    pub fn jsonStringify(self: Filters, writer: anytype) !void {
        switch (self) {
            .comparison => |value| {
                try writer.write(value);
            },
            .compound => |value| {
                try writer.write(value);
            },
            .raw => |value| {
                try writer.write(value);
            },
        }
    }

    pub fn jsonParse(
        allocator: std.mem.Allocator,
        source: anytype,
        options: std.json.ParseOptions,
    ) !Filters {
        const parsed = try std.json.Value.jsonParse(allocator, source, options);
        return jsonParseFromValue(allocator, parsed, options);
    }

    pub fn jsonParseFromValue(
        allocator: std.mem.Allocator,
        source: std.json.Value,
        options: std.json.ParseOptions,
    ) !Filters {
        switch (source) {
            .object => |object| {
                const t = object.get("type") orelse return .{ .raw = source };
                if (t != .string) return .{ .raw = source };
                if (std.mem.eql(u8, t.string, "and") or std.mem.eql(u8, t.string, "or")) {
                    const parsed = std.json.parseFromValue(CompoundFilter, allocator, source, options) catch
                        return .{ .raw = source };
                    defer parsed.deinit();
                    return .{ .compound = parsed.value };
                }
                if (std.mem.eql(u8, t.string, "eq") or
                    std.mem.eql(u8, t.string, "ne") or
                    std.mem.eql(u8, t.string, "gt") or
                    std.mem.eql(u8, t.string, "gte") or
                    std.mem.eql(u8, t.string, "lt") or
                    std.mem.eql(u8, t.string, "lte") or
                    std.mem.eql(u8, t.string, "in") or
                    std.mem.eql(u8, t.string, "nin"))
                {
                    const parsed = std.json.parseFromValue(ComparisonFilter, allocator, source, options) catch
                        return .{ .raw = source };
                    defer parsed.deinit();
                    return .{ .comparison = parsed.value };
                }
                return .{ .raw = source };
            },
            else => return .{ .raw = source },
        }
    }
};
pub const ComputerAction = union(enum) {
    click: ClickParam,
    double_click: DoubleClickAction,
    drag: Drag,
    keypress: KeyPressAction,
    move: Move,
    screenshot: Screenshot,
    scroll: Scroll,
    type_action: Type,
    wait: Wait,
    raw: std.json.Value,

    pub fn forClick(value: ClickParam) ComputerAction {
        return .{ .click = value };
    }

    pub fn forDoubleClick(value: DoubleClickAction) ComputerAction {
        return .{ .double_click = value };
    }

    pub fn forDrag(value: Drag) ComputerAction {
        return .{ .drag = value };
    }

    pub fn forKeyPress(value: KeyPressAction) ComputerAction {
        return .{ .keypress = value };
    }

    pub fn forMove(value: Move) ComputerAction {
        return .{ .move = value };
    }

    pub fn forScreenshot(value: Screenshot) ComputerAction {
        return .{ .screenshot = value };
    }

    pub fn forScroll(value: Scroll) ComputerAction {
        return .{ .scroll = value };
    }

    pub fn forTypeAction(value: Type) ComputerAction {
        return .{ .type_action = value };
    }

    pub fn forWait(value: Wait) ComputerAction {
        return .{ .wait = value };
    }

    pub fn forRaw(value: std.json.Value) ComputerAction {
        return .{ .raw = value };
    }

    pub fn jsonStringify(self: ComputerAction, writer: anytype) !void {
        switch (self) {
            .click => |value| {
                try writer.write(value);
            },
            .double_click => |value| {
                try writer.write(value);
            },
            .drag => |value| {
                try writer.write(value);
            },
            .keypress => |value| {
                try writer.write(value);
            },
            .move => |value| {
                try writer.write(value);
            },
            .screenshot => |value| {
                try writer.write(value);
            },
            .scroll => |value| {
                try writer.write(value);
            },
            .type_action => |value| {
                try writer.write(value);
            },
            .wait => |value| {
                try writer.write(value);
            },
            .raw => |value| {
                try writer.write(value);
            },
        }
    }

    pub fn jsonParse(allocator: std.mem.Allocator, source: anytype, options: std.json.ParseOptions) !ComputerAction {
        const parsed = try std.json.Value.jsonParse(allocator, source, options);
        return jsonParseFromValue(allocator, parsed, options);
    }

    pub fn jsonParseFromValue(
        allocator: std.mem.Allocator,
        source: std.json.Value,
        options: std.json.ParseOptions,
    ) !ComputerAction {
        switch (source) {
            .object => |root| {
                const kind = root.get("type") orelse return .{ .raw = source };
                if (kind != .string) return .{ .raw = source };

                if (std.mem.eql(u8, kind.string, "click")) {
                    const parsed = std.json.parseFromValue(
                        ClickParam,
                        allocator,
                        source,
                        options,
                    ) catch return .{ .raw = source };
                    defer parsed.deinit();
                    return .{ .click = parsed.value };
                }

                if (std.mem.eql(u8, kind.string, "double_click")) {
                    const parsed = std.json.parseFromValue(
                        DoubleClickAction,
                        allocator,
                        source,
                        options,
                    ) catch return .{ .raw = source };
                    defer parsed.deinit();
                    return .{ .double_click = parsed.value };
                }

                if (std.mem.eql(u8, kind.string, "drag")) {
                    const parsed = std.json.parseFromValue(
                        Drag,
                        allocator,
                        source,
                        options,
                    ) catch return .{ .raw = source };
                    defer parsed.deinit();
                    return .{ .drag = parsed.value };
                }

                if (std.mem.eql(u8, kind.string, "keypress")) {
                    const parsed = std.json.parseFromValue(
                        KeyPressAction,
                        allocator,
                        source,
                        options,
                    ) catch return .{ .raw = source };
                    defer parsed.deinit();
                    return .{ .keypress = parsed.value };
                }

                if (std.mem.eql(u8, kind.string, "move")) {
                    const parsed = std.json.parseFromValue(
                        Move,
                        allocator,
                        source,
                        options,
                    ) catch return .{ .raw = source };
                    defer parsed.deinit();
                    return .{ .move = parsed.value };
                }

                if (std.mem.eql(u8, kind.string, "screenshot")) {
                    const parsed = std.json.parseFromValue(
                        Screenshot,
                        allocator,
                        source,
                        options,
                    ) catch return .{ .raw = source };
                    defer parsed.deinit();
                    return .{ .screenshot = parsed.value };
                }

                if (std.mem.eql(u8, kind.string, "scroll")) {
                    const parsed = std.json.parseFromValue(
                        Scroll,
                        allocator,
                        source,
                        options,
                    ) catch return .{ .raw = source };
                    defer parsed.deinit();
                    return .{ .scroll = parsed.value };
                }

                if (std.mem.eql(u8, kind.string, "type")) {
                    const parsed = std.json.parseFromValue(
                        Type,
                        allocator,
                        source,
                        options,
                    ) catch return .{ .raw = source };
                    defer parsed.deinit();
                    return .{ .type_action = parsed.value };
                }

                if (std.mem.eql(u8, kind.string, "wait")) {
                    const parsed = std.json.parseFromValue(
                        Wait,
                        allocator,
                        source,
                        options,
                    ) catch return .{ .raw = source };
                    defer parsed.deinit();
                    return .{ .wait = parsed.value };
                }

                return .{ .raw = source };
            },
            else => return .{ .raw = source },
        }
    }
};
pub const ComputerCallOutputItemParam = struct {
    id: ?[]const u8,
    call_id: []const u8,
    type: []const u8,
    output: ComputerScreenshotImage,
    acknowledged_safety_checks: ?[]const ComputerCallSafetyCheckParam,
    status: ?[]const u8,
};
pub const ComputerCallSafetyCheckParam = struct {
    id: []const u8,
    code: ?[]const u8,
    message: ?[]const u8,
};
pub const ComputerEnvironment = []const u8;
pub const ComputerScreenshotContent = struct {
    type: []const u8,
    image_url: ?[]const u8,
    file_id: ?[]const u8,
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
pub const ComputerToolCallOutputResource = ComputerToolCallOutput;
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
    object: []const u8,
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
    object: []const u8,
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
pub const Content = GenericContent;
pub const Conversation = ConversationResource;
pub const Conversation_2 = struct {
    id: []const u8,
};
pub const ConversationItem = union(enum) {
    message: Message,
    function_tool_call: FunctionToolCall,
    function_tool_call_output: FunctionToolCallOutput,
    file_search_tool_call: FileSearchToolCall,
    web_search_tool_call: WebSearchToolCall,
    image_gen_tool_call: ImageGenToolCall,
    computer_tool_call: ComputerToolCall,
    computer_tool_call_output: ComputerToolCallOutput,
    reasoning: ReasoningItem,
    code_interpreter_tool_call: CodeInterpreterToolCall,
    local_shell_tool_call: LocalShellToolCall,
    local_shell_tool_call_output: LocalShellToolCallOutput,
    function_shell_call: FunctionShellCall,
    function_shell_call_output: FunctionShellCallOutput,
    apply_patch_tool_call: ApplyPatchToolCall,
    apply_patch_tool_call_output: ApplyPatchToolCallOutput,
    mcp_list_tools: MCPListTools,
    mcp_approval_request: MCPApprovalRequest,
    mcp_approval_response: MCPApprovalResponseResource,
    mcp_tool_call: MCPToolCall,
    custom_tool_call: CustomToolCall,
    custom_tool_call_output: CustomToolCallOutput,
    raw: std.json.Value,

    pub fn forMessage(value: Message) ConversationItem {
        return .{ .message = value };
    }

    pub fn forFunctionToolCall(value: FunctionToolCall) ConversationItem {
        return .{ .function_tool_call = value };
    }

    pub fn forRaw(value: std.json.Value) ConversationItem {
        return .{ .raw = value };
    }

    pub fn jsonStringify(self: ConversationItem, writer: anytype) !void {
        switch (self) {
            .message => |value| try writer.write(value),
            .function_tool_call => |value| try writer.write(value),
            .function_tool_call_output => |value| try writer.write(value),
            .file_search_tool_call => |value| try writer.write(value),
            .web_search_tool_call => |value| try writer.write(value),
            .image_gen_tool_call => |value| try writer.write(value),
            .computer_tool_call => |value| try writer.write(value),
            .computer_tool_call_output => |value| try writer.write(value),
            .reasoning => |value| try writer.write(value),
            .code_interpreter_tool_call => |value| try writer.write(value),
            .local_shell_tool_call => |value| try writer.write(value),
            .local_shell_tool_call_output => |value| try writer.write(value),
            .function_shell_call => |value| try writer.write(value),
            .function_shell_call_output => |value| try writer.write(value),
            .apply_patch_tool_call => |value| try writer.write(value),
            .apply_patch_tool_call_output => |value| try writer.write(value),
            .mcp_list_tools => |value| try writer.write(value),
            .mcp_approval_request => |value| try writer.write(value),
            .mcp_approval_response => |value| try writer.write(value),
            .mcp_tool_call => |value| try writer.write(value),
            .custom_tool_call => |value| try writer.write(value),
            .custom_tool_call_output => |value| try writer.write(value),
            .raw => |value| try writer.write(value),
        }
    }

    pub fn jsonParse(allocator: std.mem.Allocator, source: anytype, options: std.json.ParseOptions) !ConversationItem {
        const parsed = try std.json.Value.jsonParse(allocator, source, options);
        return try jsonParseFromValue(allocator, parsed, options);
    }

    pub fn jsonParseFromValue(
        allocator: std.mem.Allocator,
        source: std.json.Value,
        options: std.json.ParseOptions,
    ) !ConversationItem {
        switch (source) {
            .object => |root| {
                const item_type = root.get("type") orelse return .{ .raw = source };
                if (item_type != .string) return .{ .raw = source };

                if (std.mem.eql(u8, item_type.string, "message")) {
                    if (std.json.parseFromValue(
                        Message,
                        allocator,
                        source,
                        options,
                    )) |parsed| {
                        defer parsed.deinit();
                        return .{ .message = parsed.value };
                    } else |_| {}
                }

                if (std.mem.eql(u8, item_type.string, "function_call")) {
                    if (std.json.parseFromValue(
                        FunctionToolCall,
                        allocator,
                        source,
                        options,
                    )) |parsed| {
                        defer parsed.deinit();
                        return .{ .function_tool_call = parsed.value };
                    } else |_| {}

                    if (std.json.parseFromValue(
                        FunctionToolCallOutput,
                        allocator,
                        source,
                        options,
                    )) |parsed| {
                        defer parsed.deinit();
                        return .{ .function_tool_call_output = parsed.value };
                    } else |_| {}
                }

                if (std.mem.eql(u8, item_type.string, "custom_tool_call")) {
                    if (std.json.parseFromValue(
                        CustomToolCall,
                        allocator,
                        source,
                        options,
                    )) |parsed| {
                        defer parsed.deinit();
                        return .{ .custom_tool_call = parsed.value };
                    } else |_| {}

                    if (std.json.parseFromValue(
                        CustomToolCallOutput,
                        allocator,
                        source,
                        options,
                    )) |parsed| {
                        defer parsed.deinit();
                        return .{ .custom_tool_call_output = parsed.value };
                    } else |_| {}
                }

                if (std.mem.eql(u8, item_type.string, "computer_call")) {
                    if (std.json.parseFromValue(
                        ComputerToolCall,
                        allocator,
                        source,
                        options,
                    )) |parsed| {
                        defer parsed.deinit();
                        return .{ .computer_tool_call = parsed.value };
                    } else |_| {}

                    if (std.json.parseFromValue(
                        ComputerToolCallOutput,
                        allocator,
                        source,
                        options,
                    )) |parsed| {
                        defer parsed.deinit();
                        return .{ .computer_tool_call_output = parsed.value };
                    } else |_| {}
                }

                if (std.mem.eql(u8, item_type.string, "reasoning")) {
                    if (std.json.parseFromValue(
                        ReasoningItem,
                        allocator,
                        source,
                        options,
                    )) |parsed| {
                        defer parsed.deinit();
                        return .{ .reasoning = parsed.value };
                    } else |_| {}
                }

                if (std.mem.eql(u8, item_type.string, "code_interpreter_call")) {
                    if (std.json.parseFromValue(
                        CodeInterpreterToolCall,
                        allocator,
                        source,
                        options,
                    )) |parsed| {
                        defer parsed.deinit();
                        return .{ .code_interpreter_tool_call = parsed.value };
                    } else |_| {}
                }

                if (std.mem.eql(u8, item_type.string, "local_shell_call")) {
                    if (std.json.parseFromValue(
                        LocalShellToolCall,
                        allocator,
                        source,
                        options,
                    )) |parsed| {
                        defer parsed.deinit();
                        return .{ .local_shell_tool_call = parsed.value };
                    } else |_| {}

                    if (std.json.parseFromValue(
                        LocalShellToolCallOutput,
                        allocator,
                        source,
                        options,
                    )) |parsed| {
                        defer parsed.deinit();
                        return .{ .local_shell_tool_call_output = parsed.value };
                    } else |_| {}
                }

                if (std.mem.eql(u8, item_type.string, "shell_call")) {
                    if (std.json.parseFromValue(
                        FunctionShellCall,
                        allocator,
                        source,
                        options,
                    )) |parsed| {
                        defer parsed.deinit();
                        return .{ .function_shell_call = parsed.value };
                    } else |_| {}

                    if (std.json.parseFromValue(
                        FunctionShellCallOutput,
                        allocator,
                        source,
                        options,
                    )) |parsed| {
                        defer parsed.deinit();
                        return .{ .function_shell_call_output = parsed.value };
                    } else |_| {}
                }

                if (std.mem.eql(u8, item_type.string, "apply_patch_call")) {
                    if (std.json.parseFromValue(
                        ApplyPatchToolCall,
                        allocator,
                        source,
                        options,
                    )) |parsed| {
                        defer parsed.deinit();
                        return .{ .apply_patch_tool_call = parsed.value };
                    } else |_| {}

                    if (std.json.parseFromValue(
                        ApplyPatchToolCallOutput,
                        allocator,
                        source,
                        options,
                    )) |parsed| {
                        defer parsed.deinit();
                        return .{ .apply_patch_tool_call_output = parsed.value };
                    } else |_| {}
                }

                if (std.mem.eql(u8, item_type.string, "web_search_call")) {
                    if (std.json.parseFromValue(
                        WebSearchToolCall,
                        allocator,
                        source,
                        options,
                    )) |parsed| {
                        defer parsed.deinit();
                        return .{ .web_search_tool_call = parsed.value };
                    } else |_| {}
                }

                if (std.mem.eql(u8, item_type.string, "image_generation_call")) {
                    if (std.json.parseFromValue(
                        ImageGenToolCall,
                        allocator,
                        source,
                        options,
                    )) |parsed| {
                        defer parsed.deinit();
                        return .{ .image_gen_tool_call = parsed.value };
                    } else |_| {}
                }

                if (std.mem.eql(u8, item_type.string, "file_search_call")) {
                    if (std.json.parseFromValue(
                        FileSearchToolCall,
                        allocator,
                        source,
                        options,
                    )) |parsed| {
                        defer parsed.deinit();
                        return .{ .file_search_tool_call = parsed.value };
                    } else |_| {}
                }

                if (std.mem.eql(u8, item_type.string, "mcp_list_tools")) {
                    if (std.json.parseFromValue(
                        MCPListTools,
                        allocator,
                        source,
                        options,
                    )) |parsed| {
                        defer parsed.deinit();
                        return .{ .mcp_list_tools = parsed.value };
                    } else |_| {}
                }

                if (std.mem.eql(u8, item_type.string, "mcp_approval_request")) {
                    if (std.json.parseFromValue(
                        MCPApprovalRequest,
                        allocator,
                        source,
                        options,
                    )) |parsed| {
                        defer parsed.deinit();
                        return .{ .mcp_approval_request = parsed.value };
                    } else |_| {}
                }

                if (std.mem.eql(u8, item_type.string, "mcp_approval_response")) {
                    if (std.json.parseFromValue(
                        MCPApprovalResponseResource,
                        allocator,
                        source,
                        options,
                    )) |parsed| {
                        defer parsed.deinit();
                        return .{ .mcp_approval_response = parsed.value };
                    } else |_| {}
                }

                if (std.mem.eql(u8, item_type.string, "mcp_call")) {
                    if (std.json.parseFromValue(
                        MCPToolCall,
                        allocator,
                        source,
                        options,
                    )) |parsed| {
                        defer parsed.deinit();
                        return .{ .mcp_tool_call = parsed.value };
                    } else |_| {}
                }

                return .{ .raw = source };
            },
            .string, .number, .bool, .null, .array => return .{ .raw = source },
        }
    }
};
pub const ConversationItemList = struct {
    object: []const u8,
    data: []const ConversationItem,
    has_more: bool,
    first_id: []const u8,
    last_id: []const u8,
};
pub const ConversationParam = union(enum) {
    id: []const u8,
    conversation: ConversationParam_2,
    raw: std.json.Value,

    pub fn forId(value: []const u8) ConversationParam {
        return .{ .id = value };
    }

    pub fn forConversation(value: ConversationParam_2) ConversationParam {
        return .{ .conversation = value };
    }

    pub fn forRaw(value: std.json.Value) ConversationParam {
        return .{ .raw = value };
    }

    pub fn jsonStringify(self: ConversationParam, writer: anytype) !void {
        switch (self) {
            .id => |value| try writer.write(value),
            .conversation => |value| try writer.write(value),
            .raw => |value| try writer.write(value),
        }
    }

    pub fn jsonParse(allocator: std.mem.Allocator, source: anytype, options: std.json.ParseOptions) !ConversationParam {
        const parsed = try std.json.Value.jsonParse(allocator, source, options);
        return try jsonParseFromValue(allocator, parsed, options);
    }

    pub fn jsonParseFromValue(
        allocator: std.mem.Allocator,
        source: std.json.Value,
        options: std.json.ParseOptions,
    ) !ConversationParam {
        switch (source) {
            .string => return .{ .id = try allocator.dupe(u8, source.string) },
            .object => {
                if (std.json.parseFromValue(
                    ConversationParam_2,
                    allocator,
                    source,
                    options,
                )) |parsed| {
                    defer parsed.deinit();
                    return .{ .conversation = parsed.value };
                } else |_| {}
            },
            .array, .number, .bool, .null => {},
        }

        return .{ .raw = source };
    }
};
pub const ConversationParam_2 = struct {
    id: []const u8,
};
pub const ConversationResource = struct {
    id: []const u8,
    object: []const u8,
    metadata: Metadata,
    created_at: i64,
};
pub const CostsResult = struct {
    object: []const u8,
    amount: ?struct {
        value: ?f64,
        currency: ?[]const u8,
    },
    line_item: ?JsonObject,
    project_id: ?[]const u8,
};
pub const CreateAssistantRequest = struct {
    model: []const u8,
    name: ?[]const u8,
    description: ?[]const u8,
    instructions: ?[]const u8,
    reasoning_effort: ?ReasoningEffort,
    tools: ?[]const AssistantTool,
    tool_resources: ?AssistantToolResources,
    metadata: ?Metadata,
    temperature: ?f64,
    top_p: ?f64,
    response_format: ?AssistantsApiResponseFormatOption,
};
pub const CreateChatCompletionRequestObject = struct {
    model: ?[]const u8 = null,
    messages: ?[]const ChatCompletionRequestMessage = null,
};
pub const CreateChatCompletionRequest = union(enum) {
    object: CreateChatCompletionRequestObject,
    raw: JsonObject,

    pub fn forObject(value: CreateChatCompletionRequestObject) CreateChatCompletionRequest {
        return .{ .object = value };
    }

    pub fn forRaw(value: JsonObject) CreateChatCompletionRequest {
        return .{ .raw = value };
    }

    pub fn jsonStringify(self: CreateChatCompletionRequest, writer: anytype) !void {
        switch (self) {
            .object => |value| try writer.write(value),
            .raw => |value| try writer.write(value),
        }
    }

    pub fn jsonParse(allocator: std.mem.Allocator, source: anytype, options: std.json.ParseOptions) !CreateChatCompletionRequest {
        const parsed = try std.json.Value.jsonParse(allocator, source, options);
        return try jsonParseFromValue(allocator, parsed, options);
    }

    pub fn jsonParseFromValue(
        allocator: std.mem.Allocator,
        source: std.json.Value,
        options: std.json.ParseOptions,
    ) !CreateChatCompletionRequest {
        switch (source) {
            .object => |root| {
                if (root.get("messages") != null) {
                    const parsed = std.json.parseFromValue(
                        CreateChatCompletionRequestObject,
                        allocator,
                        source,
                        options,
                    ) catch return .{ .raw = source };
                    defer parsed.deinit();
                    return .{ .object = parsed.value };
                }

                return .{ .raw = source };
            },
            else => return .{ .raw = source },
        }
    }
};
pub const CreateChatCompletionResponse = struct {
    id: []const u8 = "",
    choices: []const ChatCompletionChoice = &.{},
    created: i64 = 0,
    model: []const u8 = "",
    service_tier: ?ServiceTier = null,
    system_fingerprint: ?[]const u8 = null,
    object: []const u8 = "",
    usage: ?CompletionUsage = null,
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
pub const CompletionLogprobTopLogprob = struct {
    token: ?[]const u8 = null,
    logprob: ?f64 = null,
    bytes: ?[]const i64 = null,
};
pub const CompletionLogprobs = struct {
    tokens: ?[]const []const u8 = null,
    token_logprobs: ?[]const ?f64 = null,
    top_logprobs: ?[]const []const CompletionLogprobTopLogprob = null,
    text_offset: ?[]const i64 = null,
};
pub const CreateCompletionLogitBiasEntry = struct {
    token: []const u8,
    bias: i64,
};
pub const CreateCompletionLogitBias = union(enum) {
    entries: []const CreateCompletionLogitBiasEntry,
    raw: std.json.Value,

    pub fn forEntries(entries: []const CreateCompletionLogitBiasEntry) CreateCompletionLogitBias {
        return .{ .entries = entries };
    }

    pub fn forRaw(value: std.json.Value) CreateCompletionLogitBias {
        return .{ .raw = value };
    }

    pub fn jsonStringify(self: CreateCompletionLogitBias, writer: anytype) !void {
        switch (self) {
            .entries => |value| {
                try writer.beginObject();
                for (value) |entry| {
                    try writer.objectField(entry.token);
                    try writer.write(entry.bias);
                }
                try writer.endObject();
            },
            .raw => |value| {
                try writer.write(value);
            },
        }
    }
};
pub const CreateCompletionRequest = struct {
    model: []const u8,
    prompt: []const u8,
    best_of: ?i64,
    echo: ?bool,
    frequency_penalty: ?f64,
    logit_bias: ?CreateCompletionLogitBias,
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
        logprobs: ?CompletionLogprobs = null,
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
    metadata: ?Metadata,
    items: ?[]const InputItem,
};
pub const CreateEmbeddingRequest = struct {
    input: CreateEmbeddingRequestInput,
    model: []const u8,
    encoding_format: ?[]const u8,
    dimensions: ?i64,
    user: ?[]const u8,
};
pub const CreateEmbeddingRequestInput = union(enum) {
    text: []const u8,
    texts: []const []const u8,
    raw: std.json.Value,

    pub fn forText(text: []const u8) CreateEmbeddingRequestInput {
        return .{ .text = text };
    }

    pub fn forTexts(texts: []const []const u8) CreateEmbeddingRequestInput {
        return .{ .texts = texts };
    }

    pub fn forRaw(value: std.json.Value) CreateEmbeddingRequestInput {
        return .{ .raw = value };
    }

    pub fn jsonStringify(self: CreateEmbeddingRequestInput, writer: anytype) !void {
        switch (self) {
            .text => |value| {
                try writer.write(value);
            },
            .texts => |value| {
                try writer.write(value);
            },
            .raw => |value| {
                try writer.write(value);
            },
        }
    }
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
    input_messages: ?InputParam,
    sampling_params: ?struct {
        reasoning_effort: ?ReasoningEffort,
        temperature: ?f64,
        max_completion_tokens: ?i64,
        top_p: ?f64,
        seed: ?i64,
        response_format: ?TextResponseFormatConfiguration,
        tools: ?[]const ChatCompletionTool,
    },
    model: ?[]const u8,
    source: std.json.Value,
};
pub const CreateEvalCustomDataSourceConfig = struct {
    type: []const u8,
    item_schema: EvalSchema,
    include_sample_schema: ?bool,
};
pub const CreateEvalItem = union(enum) {
    item: EvalItem,
    raw: JsonObject,

    pub fn forItem(value: EvalItem) CreateEvalItem {
        return .{ .item = value };
    }

    pub fn forRaw(value: JsonObject) CreateEvalItem {
        return .{ .raw = value };
    }

    pub fn jsonStringify(self: CreateEvalItem, writer: anytype) !void {
        switch (self) {
            .item => |value| try writer.write(value),
            .raw => |value| try writer.write(value),
        }
    }

    pub fn jsonParse(allocator: std.mem.Allocator, source: anytype, options: std.json.ParseOptions) !CreateEvalItem {
        const parsed = try std.json.Value.jsonParse(allocator, source, options);
        return try jsonParseFromValue(allocator, parsed, options);
    }

    pub fn jsonParseFromValue(
        allocator: std.mem.Allocator,
        source: std.json.Value,
        options: std.json.ParseOptions,
    ) !CreateEvalItem {
        switch (source) {
            .object => |root| {
                if (root.get("role") != null and root.get("content") != null) {
                    const parsed = std.json.parseFromValue(EvalItem, allocator, source, options) catch return .{ .raw = source };
                    defer parsed.deinit();
                    return .{ .item = parsed.value };
                }

                return .{ .raw = source };
            },
            else => return .{ .raw = source },
        }
    }
};
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
    metadata: ?Metadata,
};
pub const CreateEvalRequest = struct {
    name: ?[]const u8,
    metadata: ?Metadata,
    data_source_config: EvalDataSourceConfig,
    testing_criteria: []const EvalTestingCriterion,
};
pub const CreateEvalResponsesRunDataSource = struct {
    type: []const u8,
    input_messages: ?InputParam,
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
    metadata: ?Metadata,
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
    model: []const u8,
    training_file: []const u8,
    hyperparameters: ?struct {
        batch_size: ?i64,
        learning_rate_multiplier: ?f64,
        n_epochs: ?i64,
    },
    suffix: ?[]const u8,
    validation_file: ?[]const u8,
    integrations: ?[]const struct {
        type: []const u8,
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
    image: JsonObject,
    prompt: []const u8,
    mask: ?[]const u8,
    background: ?[]const u8,
    model: ?[]const u8,
    n: ?i64,
    size: ?[]const u8,
    response_format: ?[]const u8,
    output_format: ?[]const u8,
    output_compression: ?i64,
    user: ?[]const u8,
    input_fidelity: ?InputFidelity,
    stream: ?bool,
    partial_images: ?PartialImages,
    quality: ?[]const u8,
};
pub const CreateImageRequest = struct {
    prompt: []const u8,
    model: ?[]const u8,
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
    model: ?[]const u8,
    n: ?i64,
    response_format: ?[]const u8,
    size: ?[]const u8,
    user: ?[]const u8,
};
pub const CreateMessageRequestContentPart = union(enum) {
    text: struct {
        type: []const u8,
        text: []const u8,
    },
    raw: std.json.Value,

    pub fn jsonStringify(self: CreateMessageRequestContentPart, writer: anytype) !void {
        switch (self) {
            .text => |value| {
                try writer.write(value);
            },
            .raw => |value| {
                try writer.write(value);
            },
        }
    }
};

pub const CreateMessageRequestContent = union(enum) {
    text: []const u8,
    parts: []const CreateMessageRequestContentPart,
    raw: std.json.Value,

    pub fn jsonStringify(self: CreateMessageRequestContent, writer: anytype) !void {
        switch (self) {
            .text => |value| {
                try writer.write(value);
            },
            .parts => |value| {
                try writer.write(value);
            },
            .raw => |value| {
                try writer.write(value);
            },
        }
    }
};
pub const CreateMessageRequest = struct {
    role: []const u8,
    content: CreateMessageRequestContent,
    attachments: ?[]const struct {
        file_id: []const u8,
        tools: []const struct {
            type: []const u8,
        },
    },
    metadata: ?Metadata,
};
pub const CreateModelResponseProperties = ModelResponseProperties;
pub const CreateModerationRequest = struct {
    input: CreateModerationRequestInput,
    model: ?[]const u8,
};
pub const CreateModerationRequestInput = union(enum) {
    text: []const u8,
    texts: []const []const u8,
    raw: std.json.Value,

    pub fn forText(text: []const u8) CreateModerationRequestInput {
        return .{ .text = text };
    }

    pub fn forTexts(texts: []const []const u8) CreateModerationRequestInput {
        return .{ .texts = texts };
    }

    pub fn forRaw(value: std.json.Value) CreateModerationRequestInput {
        return .{ .raw = value };
    }

    pub fn jsonStringify(self: CreateModerationRequestInput, writer: anytype) !void {
        switch (self) {
            .text => |value| {
                try writer.write(value);
            },
            .texts => |value| {
                try writer.write(value);
            },
            .raw => |value| {
                try writer.write(value);
            },
        }
    }
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
            illicit: bool,
            illicit_violent: bool,
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
pub const CreateResponseObject = struct {
    input: ?InputParam = null,
    model: ?[]const u8 = null,
    instructions: ?[]const u8 = null,
    tools: ?[]const Tool = null,
    tool_choice: ?ToolChoiceParam = null,
    parallel_tool_calls: ?ParallelToolCalls = null,
    temperature: ?f64 = null,
    top_p: ?f64 = null,
    max_output_tokens: ?i64 = null,
    stream: ?bool = null,
    response_format: ?TextResponseFormatConfiguration = null,
    previous_response_id: ?[]const u8 = null,
    conversation: ?ConversationParam = null,
    metadata: ?Metadata = null,
};

pub const CreateResponse = union(enum) {
    object: CreateResponseObject,
    raw: std.json.Value,

    pub fn forObject(value: CreateResponseObject) CreateResponse {
        return .{ .object = value };
    }

    pub fn forRaw(value: std.json.Value) CreateResponse {
        return .{ .raw = value };
    }

    pub fn jsonStringify(self: CreateResponse, writer: anytype) !void {
        switch (self) {
            .object => |value| {
                try writer.write(value);
            },
            .raw => |value| {
                try writer.write(value);
            },
        }
    }

    pub fn jsonParse(allocator: std.mem.Allocator, source: anytype, options: std.json.ParseOptions) !CreateResponse {
        const parsed = try std.json.Value.jsonParse(allocator, source, options);
        return jsonParseFromValue(allocator, parsed, options);
    }

    pub fn jsonParseFromValue(
        allocator: std.mem.Allocator,
        source: std.json.Value,
        options: std.json.ParseOptions,
    ) !CreateResponse {
        const parsed = std.json.parseFromValue(
            CreateResponseObject,
            allocator,
            source,
            options,
        ) catch return .{ .raw = source };
        defer parsed.deinit();

        return .{ .object = parsed.value };
    }
};
pub const CreateRunRequest = struct {
    assistant_id: []const u8,
    model: ?[]const u8,
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
    truncation_strategy: ?TruncationObject,
    tool_choice: ?AssistantsApiToolChoiceOption,
    parallel_tool_calls: ?ParallelToolCalls,
    response_format: ?AssistantsApiResponseFormatOption,
};
pub const CreateRunRequestWithoutStream = struct {
    assistant_id: []const u8,
    model: ?[]const u8,
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
    truncation_strategy: ?TruncationObject,
    tool_choice: ?AssistantsApiToolChoiceOption,
    parallel_tool_calls: ?ParallelToolCalls,
    response_format: ?AssistantsApiResponseFormatOption,
};
pub const CreateSpeechRequest = struct {
    model: []const u8,
    input: []const u8,
    instructions: ?[]const u8,
    voice: VoiceIdsShared,
    response_format: ?[]const u8,
    speed: ?f64,
    stream_format: ?[]const u8,
};
pub const CreateSpeechResponseStreamEvent = union(enum) {
    delta: SpeechAudioDeltaEvent,
    done: SpeechAudioDoneEvent,
    raw: std.json.Value,

    pub fn forDelta(value: SpeechAudioDeltaEvent) CreateSpeechResponseStreamEvent {
        return .{ .delta = value };
    }

    pub fn forDone(value: SpeechAudioDoneEvent) CreateSpeechResponseStreamEvent {
        return .{ .done = value };
    }

    pub fn forRaw(value: std.json.Value) CreateSpeechResponseStreamEvent {
        return .{ .raw = value };
    }

    pub fn jsonStringify(self: CreateSpeechResponseStreamEvent, writer: anytype) !void {
        switch (self) {
            .delta => |value| {
                try writer.write(value);
            },
            .done => |value| {
                try writer.write(value);
            },
            .raw => |value| {
                try writer.write(value);
            },
        }
    }

    pub fn jsonParse(allocator: std.mem.Allocator, source: anytype, options: std.json.ParseOptions) !CreateSpeechResponseStreamEvent {
        const parsed = try std.json.Value.jsonParse(allocator, source, options);
        return jsonParseFromValue(allocator, parsed, options);
    }

    pub fn jsonParseFromValue(
        allocator: std.mem.Allocator,
        source: std.json.Value,
        options: std.json.ParseOptions,
    ) !CreateSpeechResponseStreamEvent {
        switch (source) {
            .object => |root| {
                if (root.get("usage") != null) {
                    const parsed = std.json.parseFromValue(
                        SpeechAudioDoneEvent,
                        allocator,
                        source,
                        options,
                    ) catch return .{ .raw = source };
                    defer parsed.deinit();
                    return .{ .done = parsed.value };
                }

                if (root.get("audio") != null) {
                    const parsed = std.json.parseFromValue(
                        SpeechAudioDeltaEvent,
                        allocator,
                        source,
                        options,
                    ) catch return .{ .raw = source };
                    defer parsed.deinit();
                    return .{ .delta = parsed.value };
                }

                return .{ .raw = source };
            },
            else => return .{ .raw = source },
        }
    }
};
pub const CreateThreadAndRunRequest = struct {
    assistant_id: []const u8,
    thread: ?CreateThreadRequest,
    model: ?[]const u8,
    instructions: ?[]const u8,
    tools: ?[]const AssistantTool,
    tool_resources: ?AssistantToolResources,
    metadata: ?Metadata,
    temperature: ?f64,
    top_p: ?f64,
    stream: ?bool,
    max_prompt_tokens: ?i64,
    max_completion_tokens: ?i64,
    truncation_strategy: ?TruncationObject,
    tool_choice: ?AssistantsApiToolChoiceOption,
    parallel_tool_calls: ?ParallelToolCalls,
    response_format: ?AssistantsApiResponseFormatOption,
};
pub const CreateThreadAndRunRequestWithoutStream = struct {
    assistant_id: []const u8,
    thread: ?CreateThreadRequest,
    model: ?[]const u8,
    instructions: ?[]const u8,
    tools: ?[]const AssistantTool,
    tool_resources: ?AssistantToolResources,
    metadata: ?Metadata,
    temperature: ?f64,
    top_p: ?f64,
    max_prompt_tokens: ?i64,
    max_completion_tokens: ?i64,
    truncation_strategy: ?TruncationObject,
    tool_choice: ?AssistantsApiToolChoiceOption,
    parallel_tool_calls: ?ParallelToolCalls,
    response_format: ?AssistantsApiResponseFormatOption,
};
pub const CreateThreadRequest = struct {
    messages: ?[]const CreateMessageRequest,
    tool_resources: ?AssistantToolResources,
    metadata: ?Metadata,
};
pub const CreateTranscriptionRequest = struct {
    file: []const u8,
    model: []const u8,
    language: ?[]const u8,
    prompt: ?[]const u8,
    response_format: ?AudioResponseFormat,
    temperature: ?f64,
    include: ?[]const TranscriptionInclude,
    timestamp_granularities: ?[]const []const u8,
    stream: ?bool,
    chunking_strategy: ?TranscriptionChunkingStrategy,
    known_speaker_names: ?[]const []const u8,
    known_speaker_references: ?[]const []const u8,
};
pub const CreateTranscriptionResponseDiarizedJson = struct {
    task: []const u8,
    duration: f64,
    text: []const u8,
    segments: []const TranscriptionDiarizedSegment,
    usage: ?TranscriptTextUsage,
};
pub const CreateTranscriptionResponseJson = struct {
    text: []const u8,
    logprobs: ?[]const struct {
        token: ?[]const u8,
        logprob: ?f64,
        bytes: ?[]const f64,
    },
    usage: ?TranscriptTextUsage,
};
pub const CreateTranscriptionResponseStreamEvent = union(enum) {
    delta: TranscriptTextDeltaEvent,
    done: TranscriptTextDoneEvent,
    segment: TranscriptTextSegmentEvent,
    raw: std.json.Value,

    pub fn forDelta(value: TranscriptTextDeltaEvent) CreateTranscriptionResponseStreamEvent {
        return .{ .delta = value };
    }

    pub fn forDone(value: TranscriptTextDoneEvent) CreateTranscriptionResponseStreamEvent {
        return .{ .done = value };
    }

    pub fn forSegment(value: TranscriptTextSegmentEvent) CreateTranscriptionResponseStreamEvent {
        return .{ .segment = value };
    }

    pub fn forRaw(value: std.json.Value) CreateTranscriptionResponseStreamEvent {
        return .{ .raw = value };
    }

    pub fn jsonStringify(self: CreateTranscriptionResponseStreamEvent, writer: anytype) !void {
        switch (self) {
            .delta => |value| {
                try writer.write(value);
            },
            .done => |value| {
                try writer.write(value);
            },
            .segment => |value| {
                try writer.write(value);
            },
            .raw => |value| {
                try writer.write(value);
            },
        }
    }

    pub fn jsonParse(allocator: std.mem.Allocator, source: anytype, options: std.json.ParseOptions) !CreateTranscriptionResponseStreamEvent {
        const parsed = try std.json.Value.jsonParse(allocator, source, options);
        return jsonParseFromValue(allocator, parsed, options);
    }

    pub fn jsonParseFromValue(
        allocator: std.mem.Allocator,
        source: std.json.Value,
        options: std.json.ParseOptions,
    ) !CreateTranscriptionResponseStreamEvent {
        switch (source) {
            .object => |root| {
                if (root.get("usage") != null) {
                    const parsed = std.json.parseFromValue(
                        TranscriptTextDoneEvent,
                        allocator,
                        source,
                        options,
                    ) catch return .{ .raw = source };
                    defer parsed.deinit();
                    return .{ .done = parsed.value };
                }

                if (root.get("delta") != null or root.get("segment_id") != null) {
                    const parsed = std.json.parseFromValue(
                        TranscriptTextDeltaEvent,
                        allocator,
                        source,
                        options,
                    ) catch return .{ .raw = source };
                    defer parsed.deinit();
                    return .{ .delta = parsed.value };
                }

                if (root.get("start") != null and root.get("end") != null and root.get("text") != null) {
                    const parsed = std.json.parseFromValue(
                        TranscriptTextSegmentEvent,
                        allocator,
                        source,
                        options,
                    ) catch return .{ .raw = source };
                    defer parsed.deinit();
                    return .{ .segment = parsed.value };
                }

                return .{ .raw = source };
            },
            else => return .{ .raw = source },
        }
    }
};
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
    model: []const u8,
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
    output: ToolOutputPayload,
};
pub const CustomToolChatCompletions = struct {
    type: []const u8,
    custom: struct {
        name: []const u8,
        description: ?[]const u8,
        format: ?JsonObject,
    },
};
pub const CustomToolParam = struct {
    type: []const u8,
    name: []const u8,
    description: ?[]const u8,
    format: ?JsonObject,
};
pub const DeleteAssistantResponse = struct {
    id: []const u8,
    deleted: bool,
    object: []const u8,
};
pub const DeleteCertificateResponse = struct {
    object: []const u8,
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
pub const DeletedConversation = DeletedConversationResource;
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
    content: GenericContent,
    type: ?[]const u8,
};
pub const Embedding = struct {
    index: i64,
    embedding: []const f64,
    object: []const u8,
};
pub const Error = struct {
    code: ?[]const u8,
    message: []const u8,
    param: ?[]const u8,
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
    data_source_config: EvalDataSourceConfig,
    testing_criteria: []const EvalTestingCriterion,
    created_at: i64,
    metadata: Metadata,
};
pub const EvalApiError = struct {
    code: []const u8,
    message: []const u8,
};
pub const EvalCustomDataSourceConfig = struct {
    type: []const u8,
    schema: EvalSchema,
};
pub const EvalGraderLabelModel = GraderLabelModel;
pub const EvalGraderPython = GraderPython;
pub const EvalGraderScoreModel = struct {
    type: []const u8,
    name: []const u8,
    model: []const u8,
    sampling_params: ?struct {
        seed: ?i64,
        top_p: ?f64,
        temperature: ?f64,
        max_completions_tokens: ?i64,
        reasoning_effort: ?ReasoningEffort,
    },
    input: []const EvalItem,
    range: ?[]const f64,
    pass_threshold: ?f64 = null,
};
pub const EvalGraderStringCheck = GraderStringCheck;
pub const EvalGraderTextSimilarity = GraderTextSimilarity;
pub const EvalItem = struct {
    role: []const u8,
    content: EvalItemContent,
    type: ?[]const u8,
};
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
pub const EvalItemContentItem = union(enum) {
    output_text: EvalItemContentOutputText,
    input_image: EvalItemInputImage,
    raw: JsonObject,

    pub fn forRaw(value: JsonObject) EvalItemContentItem {
        return .{ .raw = value };
    }

    pub fn jsonStringify(self: EvalItemContentItem, writer: anytype) !void {
        switch (self) {
            .output_text => |value| try writer.write(value),
            .input_image => |value| try writer.write(value),
            .raw => |value| try writer.write(value),
        }
    }

    pub fn jsonParse(allocator: std.mem.Allocator, source: anytype, options: std.json.ParseOptions) !EvalItemContentItem {
        const parsed = try std.json.Value.jsonParse(allocator, source, options);
        return try jsonParseFromValue(allocator, parsed, options);
    }

    pub fn jsonParseFromValue(
        allocator: std.mem.Allocator,
        source: std.json.Value,
        options: std.json.ParseOptions,
    ) !EvalItemContentItem {
        switch (source) {
            .object => |root| {
                const item_type = root.get("type") orelse return .{ .raw = source };
                if (item_type != .string) return .{ .raw = source };

                if (std.mem.eql(u8, item_type.string, "output_text") or
                    std.mem.eql(u8, item_type.string, "input_text") or
                    std.mem.eql(u8, item_type.string, "text"))
                {
                    const parsed = std.json.parseFromValue(EvalItemContentOutputText, allocator, source, options) catch return .{ .raw = source };
                    defer parsed.deinit();
                    return .{ .output_text = parsed.value };
                }

                if (std.mem.eql(u8, item_type.string, "input_image")) {
                    const parsed = std.json.parseFromValue(EvalItemInputImage, allocator, source, options) catch return .{ .raw = source };
                    defer parsed.deinit();
                    return .{ .input_image = parsed.value };
                }

                return .{ .raw = source };
            },
            else => return .{ .raw = source },
        }
    }
};
pub const EvalItemContentArray = []const EvalItemContentItem;
pub const EvalItemContent = union(enum) {
    text: EvalItemContentText,
    items: EvalItemContentArray,
    raw: JsonObject,

    pub fn forText(value: EvalItemContentText) EvalItemContent {
        return .{ .text = value };
    }

    pub fn forItems(value: EvalItemContentArray) EvalItemContent {
        return .{ .items = value };
    }

    pub fn forRaw(value: JsonObject) EvalItemContent {
        return .{ .raw = value };
    }

    pub fn jsonStringify(self: EvalItemContent, writer: anytype) !void {
        switch (self) {
            .text => |value| try writer.write(value),
            .items => |value| try writer.write(value),
            .raw => |value| try writer.write(value),
        }
    }

    pub fn jsonParse(allocator: std.mem.Allocator, source: anytype, options: std.json.ParseOptions) !EvalItemContent {
        const parsed = try std.json.Value.jsonParse(allocator, source, options);
        return try jsonParseFromValue(allocator, parsed, options);
    }

    pub fn jsonParseFromValue(
        allocator: std.mem.Allocator,
        source: std.json.Value,
        options: std.json.ParseOptions,
    ) !EvalItemContent {
        switch (source) {
            .string => return .{ .text = source.string },
            .array => {
                const parsed = std.json.parseFromValue(EvalItemContentArray, allocator, source, options) catch return .{ .raw = source };
                defer parsed.deinit();
                return .{ .items = parsed.value };
            },
            else => return .{ .raw = source },
        }
    }
};
pub const EvalJsonlFileContentSource = struct {
    type: []const u8,
    content: []const struct {
        item: EvalItemContent,
        sample: ?EvalSample,
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
    schema: EvalSchema,
};
pub const EvalResponsesSource = struct {
    type: []const u8,
    metadata: ?Metadata,
    model: ?[]const u8,
    instructions_search: ?[]const u8,
    created_after: ?i64,
    created_before: ?i64,
    reasoning_effort: ?ReasoningEffort,
    temperature: ?f64,
    top_p: ?f64,
    users: ?[]const []const u8,
    tools: ?[]const []const u8,
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
    datasource_item: EvalDatasourceItem,
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
    sample: ?EvalSample,
};
pub const EvalStoredCompletionsDataSourceConfig = struct {
    type: []const u8,
    metadata: ?Metadata,
    schema: EvalSchema,
};
pub const EvalStoredCompletionsSource = struct {
    type: []const u8,
    metadata: ?Metadata,
    model: ?[]const u8,
    created_after: ?i64,
    created_before: ?i64,
    limit: ?i64,
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
    filters: ?Filters,
};
pub const FileSearchToolCallResult = struct {
    file_id: []const u8,
    text: []const u8,
    filename: []const u8,
    attributes: ?VectorStoreFileAttributes,
    score: f64,
};
pub const FileSearchToolCall = struct {
    id: []const u8,
    type: []const u8,
    status: []const u8,
    queries: []const []const u8,
    results: ?[]const FileSearchToolCallResult,
};
pub const FileUploadParam = struct {
    enabled: ?bool,
    max_file_size: ?i64,
    max_files: ?i64,
};
pub const FineTuneChatCompletionRequestAssistantMessage = union(enum) {
    message: ChatCompletionRequestAssistantMessage,
    raw: JsonObject,

    pub fn forMessage(value: ChatCompletionRequestAssistantMessage) FineTuneChatCompletionRequestAssistantMessage {
        return .{ .message = value };
    }

    pub fn forRaw(value: JsonObject) FineTuneChatCompletionRequestAssistantMessage {
        return .{ .raw = value };
    }

    pub fn jsonStringify(self: FineTuneChatCompletionRequestAssistantMessage, writer: anytype) !void {
        switch (self) {
            .message => |value| try writer.write(value),
            .raw => |value| try writer.write(value),
        }
    }

    pub fn jsonParse(allocator: std.mem.Allocator, source: anytype, options: std.json.ParseOptions) !FineTuneChatCompletionRequestAssistantMessage {
        const parsed = try std.json.Value.jsonParse(allocator, source, options);
        return try jsonParseFromValue(allocator, parsed, options);
    }

    pub fn jsonParseFromValue(
        allocator: std.mem.Allocator,
        source: std.json.Value,
        options: std.json.ParseOptions,
    ) !FineTuneChatCompletionRequestAssistantMessage {
        switch (source) {
            .object => |root| {
                const role = root.get("role") orelse return .{ .raw = source };
                if (role == .string and std.mem.eql(u8, role.string, "assistant")) {
                    const parsed = std.json.parseFromValue(
                        ChatCompletionRequestAssistantMessage,
                        allocator,
                        source,
                        options,
                    ) catch return .{ .raw = source };
                    defer parsed.deinit();
                    return .{ .message = parsed.value };
                }

                return .{ .raw = source };
            },
            else => return .{ .raw = source },
        }
    }
};
pub const FineTuneChatRequestInput = struct {
    messages: ?JsonObjectArray,
    tools: ?[]const ChatCompletionTool,
    parallel_tool_calls: ?ParallelToolCalls,
    functions: ?[]const ChatCompletionFunctions,
};
pub const FineTuneDPOHyperparameters = struct {
    beta: ?f64,
    batch_size: ?i64,
    learning_rate_multiplier: ?f64,
    n_epochs: ?i64,
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
        messages: ?JsonObjectArray,
        tools: ?[]const ChatCompletionTool,
        parallel_tool_calls: ?ParallelToolCalls,
    },
    preferred_output: ?JsonObjectArray,
    non_preferred_output: ?JsonObjectArray,
};
pub const FineTuneReinforcementHyperparameters = struct {
    batch_size: ?i64,
    learning_rate_multiplier: ?f64,
    n_epochs: ?i64,
    reasoning_effort: ?[]const u8,
    compute_multiplier: ?f64,
    eval_interval: ?i64,
    eval_samples: ?i64,
};
pub const FineTuneReinforcementMethod = struct {
    grader: EvalGraderConfig,
    hyperparameters: ?FineTuneReinforcementHyperparameters,
};
pub const FineTuneReinforcementRequestInput = struct {
    messages: JsonObjectArray,
    tools: ?[]const ChatCompletionTool,
};
pub const FineTuneSupervisedHyperparameters = struct {
    batch_size: ?i64,
    learning_rate_multiplier: ?f64,
    n_epochs: ?i64,
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
        name: ?[]const u8,
        entity: ?[]const u8,
        tags: ?[]const []const u8,
    },
};
pub const FineTuningJob = struct {
    id: []const u8,
    created_at: i64,
    _error: ?FineTuningJobError,
    fine_tuned_model: ?[]const u8,
    finished_at: ?i64,
    hyperparameters: struct {
        batch_size: ?i64,
        learning_rate_multiplier: ?f64,
        n_epochs: ?i64,
    },
    model: []const u8,
    object: []const u8,
    organization_id: []const u8,
    result_files: []const []const u8,
    status: []const u8,
    trained_tokens: ?i64,
    training_file: []const u8,
    validation_file: ?[]const u8,
    integrations: ?[]const FineTuningIntegration,
    seed: i64,
    estimated_finish: ?i64,
    method: ?FineTuneMethod,
    metadata: ?Metadata,
};

pub const FineTuningJobError = struct {
    code: ?[]const u8 = null,
    message: ?[]const u8 = null,
    param: ?[]const u8 = null,
    type: ?[]const u8 = null,
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
    data: ?JsonObject,
};
pub const FunctionCallItemStatus = []const u8;
pub const FunctionCallOutputItemParam = struct {
    id: ?[]const u8,
    call_id: []const u8,
    type: []const u8,
    output: ToolOutputPayload,
    status: ?FunctionCallItemStatus,
};
pub const FunctionAndCustomToolCallOutput = union(enum) {
    function: FunctionToolCallOutput,
    custom: CustomToolCallOutput,
    raw: std.json.Value,

    pub fn forFunction(value: FunctionToolCallOutput) FunctionAndCustomToolCallOutput {
        return .{ .function = value };
    }

    pub fn forCustom(value: CustomToolCallOutput) FunctionAndCustomToolCallOutput {
        return .{ .custom = value };
    }

    pub fn forRaw(value: std.json.Value) FunctionAndCustomToolCallOutput {
        return .{ .raw = value };
    }

    pub fn jsonStringify(self: FunctionAndCustomToolCallOutput, writer: anytype) !void {
        switch (self) {
            .function => |value| try writer.write(value),
            .custom => |value| try writer.write(value),
            .raw => |value| try writer.write(value),
        }
    }

    pub fn jsonParse(
        allocator: std.mem.Allocator,
        source: anytype,
        options: std.json.ParseOptions,
    ) !FunctionAndCustomToolCallOutput {
        const parsed = try std.json.Value.jsonParse(allocator, source, options);
        defer parsed.deinit();
        return try jsonParseFromValue(allocator, parsed.value, options);
    }

    pub fn jsonParseFromValue(
        allocator: std.mem.Allocator,
        source: std.json.Value,
        options: std.json.ParseOptions,
    ) !FunctionAndCustomToolCallOutput {
        if (source != .object) return .{ .raw = source };

        const root = source.object;
        const tool_type = root.get("type") orelse return .{ .raw = source };
        if (tool_type != .string) return .{ .raw = source };

        if (std.mem.eql(u8, tool_type.string, "function")) {
            if (std.json.parseFromValue(
                FunctionToolCallOutput,
                allocator,
                source,
                options,
            )) |parsed| {
                defer parsed.deinit();
                return .{ .function = parsed.value };
            } else |_| {}
        }

        if (std.mem.eql(u8, tool_type.string, "custom")) {
            if (std.json.parseFromValue(
                CustomToolCallOutput,
                allocator,
                source,
                options,
            )) |parsed| {
                defer parsed.deinit();
                return .{ .custom = parsed.value };
            } else |_| {}
        }

        return .{ .raw = source };
    }
};
pub const FunctionObject = struct {
    description: ?[]const u8,
    name: []const u8,
    parameters: ?FunctionParameters,
    strict: ?bool,
};
pub const FunctionParameters = JsonObject;
pub const FunctionShellAction = struct {
    commands: []const []const u8,
    timeout_ms: i64,
    max_output_length: i64,
};
pub const FunctionShellActionParam = struct {
    commands: []const []const u8,
    timeout_ms: ?i64 = null,
    max_output_length: ?i64 = null,
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
    id: ?[]const u8,
    call_id: []const u8,
    type: []const u8,
    action: FunctionShellActionParam,
    status: ?FunctionShellCallItemStatus,
};
pub const FunctionShellCallItemStatus = []const u8;
pub const FunctionShellCallOutput = struct {
    type: []const u8,
    id: []const u8,
    call_id: []const u8,
    output: []const FunctionShellCallOutputContent,
    max_output_length: i64,
    created_by: ?[]const u8,
};
pub const FunctionShellCallOutputContent = struct {
    stdout: []const u8,
    stderr: []const u8,
    outcome: FunctionShellCallOutputOutcome,
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
    id: ?[]const u8,
    call_id: []const u8,
    type: []const u8,
    output: []const FunctionShellCallOutputContentParam,
    max_output_length: ?i64 = null,
};
pub const FunctionShellCallOutputOutcome = union(enum) {
    exit: FunctionShellCallOutputExitOutcome,
    timeout: FunctionShellCallOutputTimeoutOutcome,
    raw: std.json.Value,

    pub fn forExit(outcome: FunctionShellCallOutputExitOutcome) FunctionShellCallOutputOutcome {
        return .{ .exit = outcome };
    }

    pub fn forTimeout(outcome: FunctionShellCallOutputTimeoutOutcome) FunctionShellCallOutputOutcome {
        return .{ .timeout = outcome };
    }

    pub fn forRaw(value: std.json.Value) FunctionShellCallOutputOutcome {
        return .{ .raw = value };
    }

    pub fn jsonStringify(self: FunctionShellCallOutputOutcome, writer: anytype) !void {
        switch (self) {
            .exit => |value| try writer.write(value),
            .timeout => |value| try writer.write(value),
            .raw => |value| try writer.write(value),
        }
    }

    pub fn jsonParse(
        allocator: std.mem.Allocator,
        source: anytype,
        options: std.json.ParseOptions,
    ) !FunctionShellCallOutputOutcome {
        const parsed = try std.json.Value.jsonParse(allocator, source, options);
        defer parsed.deinit();
        return try jsonParseFromValue(allocator, parsed.value, options);
    }

    pub fn jsonParseFromValue(
        allocator: std.mem.Allocator,
        source: std.json.Value,
        options: std.json.ParseOptions,
    ) !FunctionShellCallOutputOutcome {
        if (source != .object) return .{ .raw = source };

        const root = source.object;
        const outcome_type = root.get("type") orelse return .{ .raw = source };
        if (outcome_type != .string) return .{ .raw = source };

        if (std.mem.eql(u8, outcome_type.string, "exit")) {
            if (std.json.parseFromValue(
                FunctionShellCallOutputExitOutcome,
                allocator,
                source,
                options,
            )) |parsed| {
                defer parsed.deinit();
                return .{ .exit = parsed.value };
            } else |_| {}
        }

        if (std.mem.eql(u8, outcome_type.string, "timeout")) {
            if (std.json.parseFromValue(
                FunctionShellCallOutputTimeoutOutcome,
                allocator,
                source,
                options,
            )) |parsed| {
                defer parsed.deinit();
                return .{ .timeout = parsed.value };
            } else |_| {}
        }

        return .{ .raw = source };
    }
};
pub const FunctionShellCallOutputOutcomeParam = FunctionShellCallOutputOutcome;
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
    description: ?[]const u8,
    parameters: FunctionParameters,
    strict: bool,
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
    output: ToolOutputPayload,
    status: ?[]const u8,
};
pub const FunctionToolCallOutputResource = FunctionToolCallOutput;
pub const FunctionToolCallResource = FunctionToolCall;
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
    graders: []const EvalGraderConfig,
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
        seed: ?i64,
        top_p: ?f64,
        temperature: ?f64,
        max_completions_tokens: ?i64,
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
    next: ?[]const u8,
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
pub const ImageEditStreamEvent = union(enum) {
    completed: ImageEditCompletedEvent,
    partial_image: ImageEditPartialImageEvent,
    raw: std.json.Value,

    pub fn forCompleted(value: ImageEditCompletedEvent) ImageEditStreamEvent {
        return .{ .completed = value };
    }

    pub fn forPartialImage(value: ImageEditPartialImageEvent) ImageEditStreamEvent {
        return .{ .partial_image = value };
    }

    pub fn forRaw(value: std.json.Value) ImageEditStreamEvent {
        return .{ .raw = value };
    }

    pub fn jsonStringify(self: ImageEditStreamEvent, writer: anytype) !void {
        switch (self) {
            .completed => |value| {
                try writer.write(value);
            },
            .partial_image => |value| {
                try writer.write(value);
            },
            .raw => |value| {
                try writer.write(value);
            },
        }
    }

    pub fn jsonParse(allocator: std.mem.Allocator, source: anytype, options: std.json.ParseOptions) !ImageEditStreamEvent {
        const parsed = try std.json.Value.jsonParse(allocator, source, options);
        return jsonParseFromValue(allocator, parsed, options);
    }

    pub fn jsonParseFromValue(
        allocator: std.mem.Allocator,
        source: std.json.Value,
        options: std.json.ParseOptions,
    ) !ImageEditStreamEvent {
        switch (source) {
            .object => |root| {
                if (root.get("usage") != null) {
                    const parsed = std.json.parseFromValue(
                        ImageEditCompletedEvent,
                        allocator,
                        source,
                        options,
                    ) catch return .{ .raw = source };
                    defer parsed.deinit();
                    return .{ .completed = parsed.value };
                }

                if (root.get("partial_image_index") != null) {
                    const parsed = std.json.parseFromValue(
                        ImageEditPartialImageEvent,
                        allocator,
                        source,
                        options,
                    ) catch return .{ .raw = source };
                    defer parsed.deinit();
                    return .{ .partial_image = parsed.value };
                }

                return .{ .raw = source };
            },
            else => return .{ .raw = source },
        }
    }
};
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
pub const ImageGenStreamEvent = union(enum) {
    completed: ImageGenCompletedEvent,
    partial_image: ImageGenPartialImageEvent,
    raw: std.json.Value,

    pub fn forCompleted(value: ImageGenCompletedEvent) ImageGenStreamEvent {
        return .{ .completed = value };
    }

    pub fn forPartialImage(value: ImageGenPartialImageEvent) ImageGenStreamEvent {
        return .{ .partial_image = value };
    }

    pub fn forRaw(value: std.json.Value) ImageGenStreamEvent {
        return .{ .raw = value };
    }

    pub fn jsonStringify(self: ImageGenStreamEvent, writer: anytype) !void {
        switch (self) {
            .completed => |value| {
                try writer.write(value);
            },
            .partial_image => |value| {
                try writer.write(value);
            },
            .raw => |value| {
                try writer.write(value);
            },
        }
    }

    pub fn jsonParse(allocator: std.mem.Allocator, source: anytype, options: std.json.ParseOptions) !ImageGenStreamEvent {
        const parsed = try std.json.Value.jsonParse(allocator, source, options);
        return jsonParseFromValue(allocator, parsed, options);
    }

    pub fn jsonParseFromValue(
        allocator: std.mem.Allocator,
        source: std.json.Value,
        options: std.json.ParseOptions,
    ) !ImageGenStreamEvent {
        switch (source) {
            .object => |root| {
                if (root.get("usage") != null) {
                    const parsed = std.json.parseFromValue(
                        ImageGenCompletedEvent,
                        allocator,
                        source,
                        options,
                    ) catch return .{ .raw = source };
                    defer parsed.deinit();
                    return .{ .completed = parsed.value };
                }

                if (root.get("partial_image_index") != null) {
                    const parsed = std.json.parseFromValue(
                        ImageGenPartialImageEvent,
                        allocator,
                        source,
                        options,
                    ) catch return .{ .raw = source };
                    defer parsed.deinit();
                    return .{ .partial_image = parsed.value };
                }

                return .{ .raw = source };
            },
            else => return .{ .raw = source },
        }
    }
};
pub const ImageGenTool = struct {
    type: []const u8,
    model: ?[]const u8,
    quality: ?[]const u8,
    size: ?[]const u8,
    output_format: ?[]const u8,
    output_compression: ?i64,
    moderation: ?[]const u8,
    background: ?[]const u8,
    input_fidelity: ?InputFidelity,
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
    result: ToolOutputPayload,
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
    tool_choice: ?ToolChoice,
    model: ?[]const u8,
};
pub const InputAudio = struct {
    type: []const u8,
    input_audio: struct {
        data: []const u8,
        format: []const u8,
    },
};
pub const InputContent = union(enum) {
    text: InputTextContent,
    image: InputImageContent,
    file: InputFileContent,
    audio: InputAudio,
    raw: std.json.Value,

    pub fn forText(value: []const u8) InputContent {
        return .{
            .text = .{
                .type = "text",
                .text = value,
            },
        };
    }

    pub fn forImage(value: InputImageContent) InputContent {
        return .{ .image = value };
    }

    pub fn forFile(value: InputFileContent) InputContent {
        return .{ .file = value };
    }

    pub fn forAudio(value: InputAudio) InputContent {
        return .{ .audio = value };
    }

    pub fn forRaw(value: std.json.Value) InputContent {
        return .{ .raw = value };
    }

    pub fn jsonStringify(self: InputContent, writer: anytype) !void {
        switch (self) {
            .text => |value| {
                try writer.write(value);
            },
            .image => |value| {
                try writer.write(value);
            },
            .file => |value| {
                try writer.write(value);
            },
            .audio => |value| {
                try writer.write(value);
            },
            .raw => |value| {
                try writer.write(value);
            },
        }
    }

    pub fn jsonParse(allocator: std.mem.Allocator, source: anytype, options: std.json.ParseOptions) !InputContent {
        const parsed = try std.json.Value.jsonParse(allocator, source, options);
        return jsonParseFromValue(allocator, parsed, options);
    }

    pub fn jsonParseFromValue(
        allocator: std.mem.Allocator,
        source: std.json.Value,
        options: std.json.ParseOptions,
    ) !InputContent {
        switch (source) {
            .object => |root| {
                const kind = root.get("type") orelse return .{ .raw = source };
                if (kind != .string) return .{ .raw = source };

                if (std.mem.eql(u8, kind.string, "text")) {
                    const parsed = std.json.parseFromValue(
                        InputTextContent,
                        allocator,
                        source,
                        options,
                    ) catch return .{ .raw = source };
                    defer parsed.deinit();
                    return .{ .text = parsed.value };
                }

                if (std.mem.eql(u8, kind.string, "input_image")) {
                    const parsed = std.json.parseFromValue(
                        InputImageContent,
                        allocator,
                        source,
                        options,
                    ) catch return .{ .raw = source };
                    defer parsed.deinit();
                    return .{ .image = parsed.value };
                }

                if (std.mem.eql(u8, kind.string, "input_file")) {
                    const parsed = std.json.parseFromValue(
                        InputFileContent,
                        allocator,
                        source,
                        options,
                    ) catch return .{ .raw = source };
                    defer parsed.deinit();
                    return .{ .file = parsed.value };
                }

                if (std.mem.eql(u8, kind.string, "input_audio")) {
                    const parsed = std.json.parseFromValue(
                        InputAudio,
                        allocator,
                        source,
                        options,
                    ) catch return .{ .raw = source };
                    defer parsed.deinit();
                    return .{ .audio = parsed.value };
                }

                return .{ .raw = source };
            },
            else => return .{ .raw = source },
        }
    }
};
pub const InputFidelity = []const u8;
pub const InputFileContent = struct {
    type: []const u8,
    file_id: ?[]const u8,
    filename: ?[]const u8,
    file_url: ?[]const u8,
    file_data: ?[]const u8,
};
pub const InputFileContentParam = struct {
    type: []const u8,
    file_id: ?[]const u8,
    filename: ?[]const u8,
    file_data: ?[]const u8,
    file_url: ?[]const u8,
};
pub const InputImageContent = struct {
    type: []const u8,
    image_url: ?[]const u8,
    file_id: ?[]const u8,
    detail: ImageDetail,
};
pub const InputImageContentParamAutoParam = struct {
    type: []const u8,
    image_url: ?[]const u8,
    file_id: ?[]const u8,
    detail: ?ImageDetail,
};
pub const InputMessage = struct {
    type: ?[]const u8,
    role: []const u8,
    status: ?[]const u8,
    content: InputMessageContentList,
};
pub const InputMessageContentList = []const InputContent;
pub const InputMessageResource = struct {
    id: []const u8,
    type: ?[]const u8,
    role: []const u8,
    status: ?[]const u8,
    content: InputMessageContentList,
};
pub const InputParam = union(enum) {
    text: []const u8,
    items: []const InputItem,
    raw: std.json.Value,

    pub fn forText(value: []const u8) InputParam {
        return .{ .text = value };
    }

    pub fn forItems(value: []const InputItem) InputParam {
        return .{ .items = value };
    }

    pub fn forRaw(value: std.json.Value) InputParam {
        return .{ .raw = value };
    }

    pub fn jsonStringify(self: InputParam, writer: anytype) !void {
        switch (self) {
            .text => |value| {
                try writer.write(value);
            },
            .items => |value| {
                try writer.write(value);
            },
            .raw => |value| {
                try writer.write(value);
            },
        }
    }

    pub fn jsonParse(allocator: std.mem.Allocator, source: anytype, options: std.json.ParseOptions) !InputParam {
        const parsed = try std.json.Value.jsonParse(allocator, source, options);
        return try jsonParseFromValue(allocator, parsed, options);
    }

    pub fn jsonParseFromValue(
        allocator: std.mem.Allocator,
        source: std.json.Value,
        options: std.json.ParseOptions,
    ) !InputParam {
        switch (source) {
            .string => return .{ .text = source.string },
            .array => |arr| {
                _ = arr;
                const parsed_items = std.json.parseFromValue([]const InputItem, allocator, source, options) catch {
                    return .{ .raw = source };
                };
                defer parsed_items.deinit();
                return .{ .items = parsed_items.value };
            },
            else => return .{ .raw = source },
        }
    }
};
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
pub const Item = union(enum) {
    input_message: InputMessage,
    output_message: OutputMessage,
    file_search_tool_call: FileSearchToolCall,
    computer_tool_call: ComputerToolCall,
    computer_tool_call_output: ComputerCallOutputItemParam,
    web_search_tool_call: WebSearchToolCall,
    function_tool_call: FunctionToolCall,
    function_tool_call_output: FunctionCallOutputItemParam,
    reasoning: ReasoningItem,
    compaction: CompactionSummaryItemParam,
    image_gen_tool_call: ImageGenToolCall,
    code_interpreter_tool_call: CodeInterpreterToolCall,
    local_shell_tool_call: LocalShellToolCall,
    local_shell_tool_call_output: LocalShellToolCallOutput,
    function_shell_call: FunctionShellCall,
    function_shell_call_output: FunctionShellCallOutput,
    apply_patch_tool_call: ApplyPatchToolCall,
    apply_patch_tool_call_output: ApplyPatchToolCallOutputItemParam,
    mcp_list_tools: MCPListTools,
    mcp_approval_request: MCPApprovalRequest,
    mcp_approval_response: MCPApprovalResponse,
    mcp_tool_call: MCPToolCall,
    custom_tool_call: CustomToolCall,
    custom_tool_call_output: CustomToolCallOutput,
    raw: std.json.Value,

    pub fn forInputMessage(value: InputMessage) Item {
        return .{ .input_message = value };
    }

    pub fn forOutputMessage(value: OutputMessage) Item {
        return .{ .output_message = value };
    }

    pub fn forFileSearchToolCall(value: FileSearchToolCall) Item {
        return .{ .file_search_tool_call = value };
    }

    pub fn forRaw(value: std.json.Value) Item {
        return .{ .raw = value };
    }

    pub fn jsonStringify(self: Item, writer: anytype) !void {
        switch (self) {
            .input_message => |value| try writer.write(value),
            .output_message => |value| try writer.write(value),
            .file_search_tool_call => |value| try writer.write(value),
            .computer_tool_call => |value| try writer.write(value),
            .computer_tool_call_output => |value| try writer.write(value),
            .web_search_tool_call => |value| try writer.write(value),
            .function_tool_call => |value| try writer.write(value),
            .function_tool_call_output => |value| try writer.write(value),
            .reasoning => |value| try writer.write(value),
            .compaction => |value| try writer.write(value),
            .image_gen_tool_call => |value| try writer.write(value),
            .code_interpreter_tool_call => |value| try writer.write(value),
            .local_shell_tool_call => |value| try writer.write(value),
            .local_shell_tool_call_output => |value| try writer.write(value),
            .function_shell_call => |value| try writer.write(value),
            .function_shell_call_output => |value| try writer.write(value),
            .apply_patch_tool_call => |value| try writer.write(value),
            .apply_patch_tool_call_output => |value| try writer.write(value),
            .mcp_list_tools => |value| try writer.write(value),
            .mcp_approval_request => |value| try writer.write(value),
            .mcp_approval_response => |value| try writer.write(value),
            .mcp_tool_call => |value| try writer.write(value),
            .custom_tool_call => |value| try writer.write(value),
            .custom_tool_call_output => |value| try writer.write(value),
            .raw => |value| try writer.write(value),
        }
    }

    pub fn jsonParse(allocator: std.mem.Allocator, source: anytype, options: std.json.ParseOptions) !Item {
        const parsed = try std.json.Value.jsonParse(allocator, source, options);
        return try jsonParseFromValue(allocator, parsed, options);
    }

    pub fn jsonParseFromValue(
        allocator: std.mem.Allocator,
        source: std.json.Value,
        options: std.json.ParseOptions,
    ) !Item {
        switch (source) {
            .object => |root| {
                const item_type = root.get("type") orelse return .{ .raw = source };
                if (item_type != .string) return .{ .raw = source };

                if (std.mem.eql(u8, item_type.string, "message")) {
                    if (root.get("id") != null) {
                        if (std.json.parseFromValue(OutputMessage, allocator, source, options)) |parsed| {
                            defer parsed.deinit();
                            return .{ .output_message = parsed.value };
                        } else |_| {}
                    }

                    if (std.json.parseFromValue(InputMessage, allocator, source, options)) |parsed| {
                        defer parsed.deinit();
                        return .{ .input_message = parsed.value };
                    } else |_| {}
                }

                if (std.mem.eql(u8, item_type.string, "file_search_call")) {
                    if (std.json.parseFromValue(FileSearchToolCall, allocator, source, options)) |parsed| {
                        defer parsed.deinit();
                        return .{ .file_search_tool_call = parsed.value };
                    } else |_| {}
                }

                if (std.mem.eql(u8, item_type.string, "computer_call")) {
                    if (std.json.parseFromValue(ComputerToolCall, allocator, source, options)) |parsed| {
                        defer parsed.deinit();
                        return .{ .computer_tool_call = parsed.value };
                    } else |_| {}
                }

                if (std.mem.eql(u8, item_type.string, "computer_call_output")) {
                    if (std.json.parseFromValue(ComputerCallOutputItemParam, allocator, source, options)) |parsed| {
                        defer parsed.deinit();
                        return .{ .computer_tool_call_output = parsed.value };
                    } else |_| {}
                }

                if (std.mem.eql(u8, item_type.string, "web_search_call")) {
                    if (std.json.parseFromValue(WebSearchToolCall, allocator, source, options)) |parsed| {
                        defer parsed.deinit();
                        return .{ .web_search_tool_call = parsed.value };
                    } else |_| {}
                }

                if (std.mem.eql(u8, item_type.string, "function_call")) {
                    if (std.json.parseFromValue(FunctionToolCall, allocator, source, options)) |parsed| {
                        defer parsed.deinit();
                        return .{ .function_tool_call = parsed.value };
                    } else |_| {}
                }

                if (std.mem.eql(u8, item_type.string, "function_call_output")) {
                    if (std.json.parseFromValue(FunctionCallOutputItemParam, allocator, source, options)) |parsed| {
                        defer parsed.deinit();
                        return .{ .function_tool_call_output = parsed.value };
                    } else |_| {}
                }

                if (std.mem.eql(u8, item_type.string, "reasoning")) {
                    if (std.json.parseFromValue(ReasoningItem, allocator, source, options)) |parsed| {
                        defer parsed.deinit();
                        return .{ .reasoning = parsed.value };
                    } else |_| {}
                }

                if (std.mem.eql(u8, item_type.string, "compaction")) {
                    if (std.json.parseFromValue(CompactionSummaryItemParam, allocator, source, options)) |parsed| {
                        defer parsed.deinit();
                        return .{ .compaction = parsed.value };
                    } else |_| {}
                }

                if (std.mem.eql(u8, item_type.string, "image_generation_call")) {
                    if (std.json.parseFromValue(ImageGenToolCall, allocator, source, options)) |parsed| {
                        defer parsed.deinit();
                        return .{ .image_gen_tool_call = parsed.value };
                    } else |_| {}
                }

                if (std.mem.eql(u8, item_type.string, "code_interpreter_call")) {
                    if (std.json.parseFromValue(CodeInterpreterToolCall, allocator, source, options)) |parsed| {
                        defer parsed.deinit();
                        return .{ .code_interpreter_tool_call = parsed.value };
                    } else |_| {}
                }

                if (std.mem.eql(u8, item_type.string, "local_shell_call")) {
                    if (std.json.parseFromValue(LocalShellToolCall, allocator, source, options)) |parsed| {
                        defer parsed.deinit();
                        return .{ .local_shell_tool_call = parsed.value };
                    } else |_| {}

                    if (std.json.parseFromValue(LocalShellToolCallOutput, allocator, source, options)) |parsed| {
                        defer parsed.deinit();
                        return .{ .local_shell_tool_call_output = parsed.value };
                    } else |_| {}
                }

                if (std.mem.eql(u8, item_type.string, "shell_call")) {
                    if (std.json.parseFromValue(FunctionShellCall, allocator, source, options)) |parsed| {
                        defer parsed.deinit();
                        return .{ .function_shell_call = parsed.value };
                    } else |_| {}
                }

                if (std.mem.eql(u8, item_type.string, "shell_call_output")) {
                    if (std.json.parseFromValue(FunctionShellCallOutput, allocator, source, options)) |parsed| {
                        defer parsed.deinit();
                        return .{ .function_shell_call_output = parsed.value };
                    } else |_| {}
                }

                if (std.mem.eql(u8, item_type.string, "apply_patch_call")) {
                    if (std.json.parseFromValue(ApplyPatchToolCall, allocator, source, options)) |parsed| {
                        defer parsed.deinit();
                        return .{ .apply_patch_tool_call = parsed.value };
                    } else |_| {}
                }

                if (std.mem.eql(u8, item_type.string, "apply_patch_call_output")) {
                    if (std.json.parseFromValue(ApplyPatchToolCallOutputItemParam, allocator, source, options)) |parsed| {
                        defer parsed.deinit();
                        return .{ .apply_patch_tool_call_output = parsed.value };
                    } else |_| {}
                }

                if (std.mem.eql(u8, item_type.string, "mcp_list_tools")) {
                    if (std.json.parseFromValue(MCPListTools, allocator, source, options)) |parsed| {
                        defer parsed.deinit();
                        return .{ .mcp_list_tools = parsed.value };
                    } else |_| {}
                }

                if (std.mem.eql(u8, item_type.string, "mcp_approval_request")) {
                    if (std.json.parseFromValue(MCPApprovalRequest, allocator, source, options)) |parsed| {
                        defer parsed.deinit();
                        return .{ .mcp_approval_request = parsed.value };
                    } else |_| {}
                }

                if (std.mem.eql(u8, item_type.string, "mcp_approval_response")) {
                    if (std.json.parseFromValue(MCPApprovalResponse, allocator, source, options)) |parsed| {
                        defer parsed.deinit();
                        return .{ .mcp_approval_response = parsed.value };
                    } else |_| {}
                }

                if (std.mem.eql(u8, item_type.string, "mcp_call")) {
                    if (std.json.parseFromValue(MCPToolCall, allocator, source, options)) |parsed| {
                        defer parsed.deinit();
                        return .{ .mcp_tool_call = parsed.value };
                    } else |_| {}
                }

                if (std.mem.eql(u8, item_type.string, "custom_tool_call")) {
                    if (std.json.parseFromValue(CustomToolCall, allocator, source, options)) |parsed| {
                        defer parsed.deinit();
                        return .{ .custom_tool_call = parsed.value };
                    } else |_| {}
                }

                if (std.mem.eql(u8, item_type.string, "custom_tool_call_output")) {
                    if (std.json.parseFromValue(CustomToolCallOutput, allocator, source, options)) |parsed| {
                        defer parsed.deinit();
                        return .{ .custom_tool_call_output = parsed.value };
                    } else |_| {}
                }

                return .{ .raw = source };
            },
            else => return .{ .raw = source },
        }
    }
};
pub const ItemField = Item;
pub const InputItem = union(enum) {
    easy_message: EasyInputMessage,
    item: Item,
    item_reference: ItemReferenceParam,
    raw: std.json.Value,

    pub fn forEasyMessage(value: EasyInputMessage) InputItem {
        return .{ .easy_message = value };
    }

    pub fn forItem(value: Item) InputItem {
        return .{ .item = value };
    }

    pub fn forReference(value: ItemReferenceParam) InputItem {
        return .{ .item_reference = value };
    }

    pub fn forRaw(value: std.json.Value) InputItem {
        return .{ .raw = value };
    }

    pub fn jsonStringify(self: InputItem, writer: anytype) !void {
        switch (self) {
            .easy_message => |value| try writer.write(value),
            .item => |value| try writer.write(value),
            .item_reference => |value| try writer.write(value),
            .raw => |value| try writer.write(value),
        }
    }

    pub fn jsonParse(allocator: std.mem.Allocator, source: anytype, options: std.json.ParseOptions) !InputItem {
        const parsed = try std.json.Value.jsonParse(allocator, source, options);
        return try jsonParseFromValue(allocator, parsed, options);
    }

    pub fn jsonParseFromValue(
        allocator: std.mem.Allocator,
        source: std.json.Value,
        options: std.json.ParseOptions,
    ) !InputItem {
        switch (source) {
            .object => |root| {
                const item_type = root.get("type");
                if (item_type == null) {
                    if (std.json.parseFromValue(EasyInputMessage, allocator, source, options)) |parsed| {
                        defer parsed.deinit();
                        return .{ .easy_message = parsed.value };
                    } else |_| {
                        return .{ .raw = source };
                    }
                }
                if (item_type.? != .string) return .{ .raw = source };

                if (std.mem.eql(u8, item_type.?.string, "item_reference")) {
                    if (std.json.parseFromValue(ItemReferenceParam, allocator, source, options)) |parsed| {
                        defer parsed.deinit();
                        return .{ .item_reference = parsed.value };
                    } else |_| {}
                }

                if (Item.jsonParseFromValue(allocator, source, options)) |value| {
                    return .{ .item = value };
                } else |_| {
                    return .{ .raw = source };
                }
            },
            else => return .{ .raw = source },
        }
    }
};
pub const ItemReferenceParam = struct {
    type: ?[]const u8,
    id: []const u8,
};
pub const ItemResource = union(enum) {
    input_message: InputMessageResource,
    output_message: OutputMessage,
    file_search_tool_call: FileSearchToolCall,
    computer_tool_call: ComputerToolCall,
    computer_tool_call_output: ComputerToolCallOutput,
    web_search_tool_call: WebSearchToolCall,
    function_tool_call: FunctionToolCallResource,
    function_tool_call_output: FunctionToolCallOutputResource,
    image_gen_tool_call: ImageGenToolCall,
    code_interpreter_tool_call: CodeInterpreterToolCall,
    local_shell_tool_call: LocalShellToolCall,
    local_shell_tool_call_output: LocalShellToolCallOutput,
    function_shell_call: FunctionShellCall,
    function_shell_call_output: FunctionShellCallOutput,
    apply_patch_tool_call: ApplyPatchToolCall,
    apply_patch_tool_call_output: ApplyPatchToolCallOutput,
    mcp_list_tools: MCPListTools,
    mcp_approval_request: MCPApprovalRequest,
    mcp_approval_response: MCPApprovalResponseResource,
    mcp_tool_call: MCPToolCall,
    raw: std.json.Value,

    pub fn forRaw(value: std.json.Value) ItemResource {
        return .{ .raw = value };
    }

    pub fn jsonStringify(self: ItemResource, writer: anytype) !void {
        switch (self) {
            .input_message => |value| try writer.write(value),
            .output_message => |value| try writer.write(value),
            .file_search_tool_call => |value| try writer.write(value),
            .computer_tool_call => |value| try writer.write(value),
            .computer_tool_call_output => |value| try writer.write(value),
            .web_search_tool_call => |value| try writer.write(value),
            .function_tool_call => |value| try writer.write(value),
            .function_tool_call_output => |value| try writer.write(value),
            .image_gen_tool_call => |value| try writer.write(value),
            .code_interpreter_tool_call => |value| try writer.write(value),
            .local_shell_tool_call => |value| try writer.write(value),
            .local_shell_tool_call_output => |value| try writer.write(value),
            .function_shell_call => |value| try writer.write(value),
            .function_shell_call_output => |value| try writer.write(value),
            .apply_patch_tool_call => |value| try writer.write(value),
            .apply_patch_tool_call_output => |value| try writer.write(value),
            .mcp_list_tools => |value| try writer.write(value),
            .mcp_approval_request => |value| try writer.write(value),
            .mcp_approval_response => |value| try writer.write(value),
            .mcp_tool_call => |value| try writer.write(value),
            .raw => |value| try writer.write(value),
        }
    }

    pub fn jsonParse(allocator: std.mem.Allocator, source: anytype, options: std.json.ParseOptions) !ItemResource {
        const parsed = try std.json.Value.jsonParse(allocator, source, options);
        return try jsonParseFromValue(allocator, parsed, options);
    }

    pub fn jsonParseFromValue(
        allocator: std.mem.Allocator,
        source: std.json.Value,
        options: std.json.ParseOptions,
    ) !ItemResource {
        switch (source) {
            .object => |root| {
                const item_type = root.get("type") orelse return .{ .raw = source };
                if (item_type != .string) return .{ .raw = source };

                if (std.mem.eql(u8, item_type.string, "message")) {
                    if (root.get("id") != null) {
                        if (std.json.parseFromValue(InputMessageResource, allocator, source, options)) |parsed| {
                            defer parsed.deinit();
                            return .{ .input_message = parsed.value };
                        } else |_| {}

                        if (std.json.parseFromValue(OutputMessage, allocator, source, options)) |parsed| {
                            defer parsed.deinit();
                            return .{ .output_message = parsed.value };
                        } else |_| {}
                    } else {
                        if (std.json.parseFromValue(OutputMessage, allocator, source, options)) |parsed| {
                            defer parsed.deinit();
                            return .{ .output_message = parsed.value };
                        } else |_| {}
                    }
                }

                if (std.mem.eql(u8, item_type.string, "file_search_call")) {
                    if (std.json.parseFromValue(FileSearchToolCall, allocator, source, options)) |parsed| {
                        defer parsed.deinit();
                        return .{ .file_search_tool_call = parsed.value };
                    } else |_| {}
                }

                if (std.mem.eql(u8, item_type.string, "computer_call")) {
                    if (std.json.parseFromValue(ComputerToolCall, allocator, source, options)) |parsed| {
                        defer parsed.deinit();
                        return .{ .computer_tool_call = parsed.value };
                    } else |_| {}
                }

                if (std.mem.eql(u8, item_type.string, "computer_call_output")) {
                    if (std.json.parseFromValue(ComputerToolCallOutput, allocator, source, options)) |parsed| {
                        defer parsed.deinit();
                        return .{ .computer_tool_call_output = parsed.value };
                    } else |_| {}
                }

                if (std.mem.eql(u8, item_type.string, "web_search_call")) {
                    if (std.json.parseFromValue(WebSearchToolCall, allocator, source, options)) |parsed| {
                        defer parsed.deinit();
                        return .{ .web_search_tool_call = parsed.value };
                    } else |_| {}
                }

                if (std.mem.eql(u8, item_type.string, "function_call")) {
                    if (std.json.parseFromValue(FunctionToolCallResource, allocator, source, options)) |parsed| {
                        defer parsed.deinit();
                        return .{ .function_tool_call = parsed.value };
                    } else |_| {}
                }

                if (std.mem.eql(u8, item_type.string, "function_call_output")) {
                    if (std.json.parseFromValue(FunctionToolCallOutputResource, allocator, source, options)) |parsed| {
                        defer parsed.deinit();
                        return .{ .function_tool_call_output = parsed.value };
                    } else |_| {}
                }

                if (std.mem.eql(u8, item_type.string, "image_generation_call")) {
                    if (std.json.parseFromValue(ImageGenToolCall, allocator, source, options)) |parsed| {
                        defer parsed.deinit();
                        return .{ .image_gen_tool_call = parsed.value };
                    } else |_| {}
                }

                if (std.mem.eql(u8, item_type.string, "code_interpreter_call")) {
                    if (std.json.parseFromValue(CodeInterpreterToolCall, allocator, source, options)) |parsed| {
                        defer parsed.deinit();
                        return .{ .code_interpreter_tool_call = parsed.value };
                    } else |_| {}
                }

                if (std.mem.eql(u8, item_type.string, "local_shell_call")) {
                    if (std.json.parseFromValue(LocalShellToolCall, allocator, source, options)) |parsed| {
                        defer parsed.deinit();
                        return .{ .local_shell_tool_call = parsed.value };
                    } else |_| {}
                }

                if (std.mem.eql(u8, item_type.string, "local_shell_call_output")) {
                    if (std.json.parseFromValue(LocalShellToolCallOutput, allocator, source, options)) |parsed| {
                        defer parsed.deinit();
                        return .{ .local_shell_tool_call_output = parsed.value };
                    } else |_| {}
                }

                if (std.mem.eql(u8, item_type.string, "shell_call")) {
                    if (std.json.parseFromValue(FunctionShellCall, allocator, source, options)) |parsed| {
                        defer parsed.deinit();
                        return .{ .function_shell_call = parsed.value };
                    } else |_| {}
                }

                if (std.mem.eql(u8, item_type.string, "shell_call_output")) {
                    if (std.json.parseFromValue(FunctionShellCallOutput, allocator, source, options)) |parsed| {
                        defer parsed.deinit();
                        return .{ .function_shell_call_output = parsed.value };
                    } else |_| {}
                }

                if (std.mem.eql(u8, item_type.string, "apply_patch_call")) {
                    if (std.json.parseFromValue(ApplyPatchToolCall, allocator, source, options)) |parsed| {
                        defer parsed.deinit();
                        return .{ .apply_patch_tool_call = parsed.value };
                    } else |_| {}
                }

                if (std.mem.eql(u8, item_type.string, "apply_patch_call_output")) {
                    if (std.json.parseFromValue(ApplyPatchToolCallOutput, allocator, source, options)) |parsed| {
                        defer parsed.deinit();
                        return .{ .apply_patch_tool_call_output = parsed.value };
                    } else |_| {}
                }

                if (std.mem.eql(u8, item_type.string, "mcp_list_tools")) {
                    if (std.json.parseFromValue(MCPListTools, allocator, source, options)) |parsed| {
                        defer parsed.deinit();
                        return .{ .mcp_list_tools = parsed.value };
                    } else |_| {}
                }

                if (std.mem.eql(u8, item_type.string, "mcp_approval_request")) {
                    if (std.json.parseFromValue(MCPApprovalRequest, allocator, source, options)) |parsed| {
                        defer parsed.deinit();
                        return .{ .mcp_approval_request = parsed.value };
                    } else |_| {}
                }

                if (std.mem.eql(u8, item_type.string, "mcp_approval_response")) {
                    if (std.json.parseFromValue(MCPApprovalResponseResource, allocator, source, options)) |parsed| {
                        defer parsed.deinit();
                        return .{ .mcp_approval_response = parsed.value };
                    } else |_| {}
                }

                if (std.mem.eql(u8, item_type.string, "mcp_call")) {
                    if (std.json.parseFromValue(MCPToolCall, allocator, source, options)) |parsed| {
                        defer parsed.deinit();
                        return .{ .mcp_tool_call = parsed.value };
                    } else |_| {}
                }

                return .{ .raw = source };
            },
            else => return .{ .raw = source },
        }
    }
};
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
    first_id: ?[]const u8,
    last_id: ?[]const u8,
    has_more: bool,
};
pub const ListFineTuningJobCheckpointsResponse = struct {
    data: []const FineTuningJobCheckpoint,
    object: []const u8,
    first_id: ?[]const u8,
    last_id: ?[]const u8,
    has_more: bool,
};
pub const ListFineTuningJobEventsResponse = struct {
    data: []const FineTuningJobEvent,
    object: []const u8,
    has_more: bool,
};
pub const ListMessagesResponse = struct {
    object: []const u8,
    data: []const MessageObject,
    first_id: []const u8,
    last_id: []const u8,
    has_more: bool,
};
pub const ListModelsResponse = struct {
    object: []const u8,
    data: []const Model,
};
pub const ListPaginatedFineTuningJobsResponse = struct {
    data: []const FineTuningJob,
    has_more: bool,
    object: []const u8,
};
pub const ListRunStepsResponse = struct {
    object: []const u8,
    data: []const RunStepObject,
    first_id: []const u8,
    last_id: []const u8,
    has_more: bool,
};
pub const ListRunsResponse = struct {
    object: []const u8,
    data: []const RunObject,
    first_id: []const u8,
    last_id: []const u8,
    has_more: bool,
};
pub const ListVectorStoreFilesResponse = struct {
    object: []const u8,
    data: []const VectorStoreFileObject,
    first_id: []const u8,
    last_id: []const u8,
    has_more: bool,
};
pub const ListVectorStoresResponse = struct {
    object: []const u8,
    data: []const VectorStoreObject,
    first_id: []const u8,
    last_id: []const u8,
    has_more: bool,
};
pub const LocalShellCallStatus = []const u8;
pub const LocalShellExecAction = struct {
    type: []const u8,
    command: []const []const u8,
    timeout_ms: ?i64,
    working_directory: ?[]const u8,
    env: JsonObject,
    user: ?[]const u8,
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
    status: ?[]const u8,
};
pub const LocalShellToolParam = struct {
    type: []const u8,
};
pub const LockedStatus = struct {
    type: []const u8,
    reason: ?[]const u8,
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
    id: ?[]const u8,
    approval_request_id: []const u8,
    approve: bool,
    reason: ?[]const u8,
};
pub const MCPApprovalResponseResource = struct {
    type: []const u8,
    id: []const u8,
    approval_request_id: []const u8,
    approve: bool,
    reason: ?[]const u8,
};
pub const MCPListTools = struct {
    type: []const u8,
    id: []const u8,
    server_label: []const u8,
    tools: []const MCPListToolsTool,
    _error: ?[]const u8,
};
pub const MCPListToolsTool = struct {
    name: []const u8,
    description: ?[]const u8,
    input_schema: FunctionParameters,
    annotations: ?JsonObject,
};
pub const MCPTool = struct {
    type: []const u8,
    server_label: []const u8,
    server_url: ?[]const u8,
    connector_id: ?[]const u8,
    authorization: ?[]const u8,
    server_description: ?[]const u8,
    headers: ?JsonObject,
    allowed_tools: ?JsonObject,
    require_approval: ?JsonObject,
};
pub const MCPToolCall = struct {
    type: []const u8,
    id: []const u8,
    server_label: []const u8,
    name: []const u8,
    arguments: []const u8,
    output: ?[]const u8,
    _error: ?[]const u8,
    status: ?MCPToolCallStatus,
    approval_request_id: ?[]const u8,
};

pub const MCPToolCallError = struct {
    code: ?[]const u8 = null,
    message: ?[]const u8 = null,
    param: ?[]const u8 = null,
    type: ?[]const u8 = null,
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
    content: []const MessageContent,
};
pub const MessageTextAnnotation = union(enum) {
    file_citation: MessageContentTextAnnotationsFileCitationObject,
    file_path: MessageContentTextAnnotationsFilePathObject,
    raw: std.json.Value,

    pub fn forFileCitation(value: MessageContentTextAnnotationsFileCitationObject) MessageTextAnnotation {
        return .{ .file_citation = value };
    }

    pub fn forFilePath(value: MessageContentTextAnnotationsFilePathObject) MessageTextAnnotation {
        return .{ .file_path = value };
    }

    pub fn forRaw(value: std.json.Value) MessageTextAnnotation {
        return .{ .raw = value };
    }

    pub fn jsonStringify(self: MessageTextAnnotation, writer: anytype) !void {
        switch (self) {
            .file_citation => |value| {
                try writer.write(value);
            },
            .file_path => |value| {
                try writer.write(value);
            },
            .raw => |value| {
                try writer.write(value);
            },
        }
    }

    pub fn jsonParse(allocator: std.mem.Allocator, source: anytype, options: std.json.ParseOptions) !MessageTextAnnotation {
        const parsed = try std.json.Value.jsonParse(allocator, source, options);
        return jsonParseFromValue(allocator, parsed, options);
    }

    pub fn jsonParseFromValue(
        allocator: std.mem.Allocator,
        source: std.json.Value,
        options: std.json.ParseOptions,
    ) !MessageTextAnnotation {
        switch (source) {
            .object => |root| {
                const kind = root.get("type") orelse return .{ .raw = source };
                if (kind != .string) return .{ .raw = source };

                if (std.mem.eql(u8, kind.string, "file_citation")) {
                    const parsed = std.json.parseFromValue(
                        MessageContentTextAnnotationsFileCitationObject,
                        allocator,
                        source,
                        options,
                    ) catch return .{ .raw = source };
                    defer parsed.deinit();
                    return .{ .file_citation = parsed.value };
                }

                if (std.mem.eql(u8, kind.string, "file_path")) {
                    const parsed = std.json.parseFromValue(
                        MessageContentTextAnnotationsFilePathObject,
                        allocator,
                        source,
                        options,
                    ) catch return .{ .raw = source };
                    defer parsed.deinit();
                    return .{ .file_path = parsed.value };
                }

                return .{ .raw = source };
            },
            else => return .{ .raw = source },
        }
    }
};
pub const MessageTextAnnotationDelta = union(enum) {
    file_citation: MessageDeltaContentTextAnnotationsFileCitationObject,
    file_path: MessageDeltaContentTextAnnotationsFilePathObject,
    raw: std.json.Value,

    pub fn forFileCitation(value: MessageDeltaContentTextAnnotationsFileCitationObject) MessageTextAnnotationDelta {
        return .{ .file_citation = value };
    }

    pub fn forFilePath(value: MessageDeltaContentTextAnnotationsFilePathObject) MessageTextAnnotationDelta {
        return .{ .file_path = value };
    }

    pub fn forRaw(value: std.json.Value) MessageTextAnnotationDelta {
        return .{ .raw = value };
    }

    pub fn jsonStringify(self: MessageTextAnnotationDelta, writer: anytype) !void {
        switch (self) {
            .file_citation => |value| {
                try writer.write(value);
            },
            .file_path => |value| {
                try writer.write(value);
            },
            .raw => |value| {
                try writer.write(value);
            },
        }
    }

    pub fn jsonParse(allocator: std.mem.Allocator, source: anytype, options: std.json.ParseOptions) !MessageTextAnnotationDelta {
        const parsed = try std.json.Value.jsonParse(allocator, source, options);
        return jsonParseFromValue(allocator, parsed, options);
    }

    pub fn jsonParseFromValue(
        allocator: std.mem.Allocator,
        source: std.json.Value,
        options: std.json.ParseOptions,
    ) !MessageTextAnnotationDelta {
        switch (source) {
            .object => |root| {
                const kind = root.get("type") orelse return .{ .raw = source };
                if (kind != .string) return .{ .raw = source };

                if (std.mem.eql(u8, kind.string, "file_citation")) {
                    const parsed = std.json.parseFromValue(
                        MessageDeltaContentTextAnnotationsFileCitationObject,
                        allocator,
                        source,
                        options,
                    ) catch return .{ .raw = source };
                    defer parsed.deinit();
                    return .{ .file_citation = parsed.value };
                }

                if (std.mem.eql(u8, kind.string, "file_path")) {
                    const parsed = std.json.parseFromValue(
                        MessageDeltaContentTextAnnotationsFilePathObject,
                        allocator,
                        source,
                        options,
                    ) catch return .{ .raw = source };
                    defer parsed.deinit();
                    return .{ .file_path = parsed.value };
                }

                return .{ .raw = source };
            },
            else => return .{ .raw = source },
        }
    }
};
pub const MessageContent = union(enum) {
    text: MessageContentTextObject,
    image_file: MessageContentImageFileObject,
    image_url: MessageContentImageUrlObject,
    refusal: MessageContentRefusalObject,
    raw: std.json.Value,

    pub fn forText(value: MessageContentTextObject) MessageContent {
        return .{ .text = value };
    }

    pub fn forImageFile(value: MessageContentImageFileObject) MessageContent {
        return .{ .image_file = value };
    }

    pub fn forImageUrl(value: MessageContentImageUrlObject) MessageContent {
        return .{ .image_url = value };
    }

    pub fn forRefusal(value: MessageContentRefusalObject) MessageContent {
        return .{ .refusal = value };
    }

    pub fn forRaw(value: std.json.Value) MessageContent {
        return .{ .raw = value };
    }

    pub fn jsonStringify(self: MessageContent, writer: anytype) !void {
        switch (self) {
            .text => |value| {
                try writer.write(value);
            },
            .image_file => |value| {
                try writer.write(value);
            },
            .image_url => |value| {
                try writer.write(value);
            },
            .refusal => |value| {
                try writer.write(value);
            },
            .raw => |value| {
                try writer.write(value);
            },
        }
    }

    pub fn jsonParse(allocator: std.mem.Allocator, source: anytype, options: std.json.ParseOptions) !MessageContent {
        const parsed = try std.json.Value.jsonParse(allocator, source, options);
        return jsonParseFromValue(allocator, parsed, options);
    }

    pub fn jsonParseFromValue(
        allocator: std.mem.Allocator,
        source: std.json.Value,
        options: std.json.ParseOptions,
    ) !MessageContent {
        switch (source) {
            .object => |root| {
                const kind = root.get("type") orelse return .{ .raw = source };
                if (kind != .string) return .{ .raw = source };

                if (std.mem.eql(u8, kind.string, "text")) {
                    const parsed = std.json.parseFromValue(
                        MessageContentTextObject,
                        allocator,
                        source,
                        options,
                    ) catch return .{ .raw = source };
                    defer parsed.deinit();
                    return .{ .text = parsed.value };
                }

                if (std.mem.eql(u8, kind.string, "image_file")) {
                    const parsed = std.json.parseFromValue(
                        MessageContentImageFileObject,
                        allocator,
                        source,
                        options,
                    ) catch return .{ .raw = source };
                    defer parsed.deinit();
                    return .{ .image_file = parsed.value };
                }

                if (std.mem.eql(u8, kind.string, "image_url")) {
                    const parsed = std.json.parseFromValue(
                        MessageContentImageUrlObject,
                        allocator,
                        source,
                        options,
                    ) catch return .{ .raw = source };
                    defer parsed.deinit();
                    return .{ .image_url = parsed.value };
                }

                if (std.mem.eql(u8, kind.string, "refusal")) {
                    const parsed = std.json.parseFromValue(
                        MessageContentRefusalObject,
                        allocator,
                        source,
                        options,
                    ) catch return .{ .raw = source };
                    defer parsed.deinit();
                    return .{ .refusal = parsed.value };
                }

                return .{ .raw = source };
            },
            else => return .{ .raw = source },
        }
    }
};
pub const MessageContentDelta = union(enum) {
    text: MessageDeltaContentTextObject,
    image_file: MessageDeltaContentImageFileObject,
    image_url: MessageDeltaContentImageUrlObject,
    refusal: MessageDeltaContentRefusalObject,
    raw: std.json.Value,

    pub fn forText(value: MessageDeltaContentTextObject) MessageContentDelta {
        return .{ .text = value };
    }

    pub fn forImageFile(value: MessageDeltaContentImageFileObject) MessageContentDelta {
        return .{ .image_file = value };
    }

    pub fn forImageUrl(value: MessageDeltaContentImageUrlObject) MessageContentDelta {
        return .{ .image_url = value };
    }

    pub fn forRefusal(value: MessageDeltaContentRefusalObject) MessageContentDelta {
        return .{ .refusal = value };
    }

    pub fn forRaw(value: std.json.Value) MessageContentDelta {
        return .{ .raw = value };
    }

    pub fn jsonStringify(self: MessageContentDelta, writer: anytype) !void {
        switch (self) {
            .text => |value| {
                try writer.write(value);
            },
            .image_file => |value| {
                try writer.write(value);
            },
            .image_url => |value| {
                try writer.write(value);
            },
            .refusal => |value| {
                try writer.write(value);
            },
            .raw => |value| {
                try writer.write(value);
            },
        }
    }

    pub fn jsonParse(allocator: std.mem.Allocator, source: anytype, options: std.json.ParseOptions) !MessageContentDelta {
        const parsed = try std.json.Value.jsonParse(allocator, source, options);
        return jsonParseFromValue(allocator, parsed, options);
    }

    pub fn jsonParseFromValue(
        allocator: std.mem.Allocator,
        source: std.json.Value,
        options: std.json.ParseOptions,
    ) !MessageContentDelta {
        switch (source) {
            .object => |root| {
                const kind = root.get("type") orelse return .{ .raw = source };
                if (kind != .string) return .{ .raw = source };

                if (std.mem.eql(u8, kind.string, "text")) {
                    const parsed = std.json.parseFromValue(
                        MessageDeltaContentTextObject,
                        allocator,
                        source,
                        options,
                    ) catch return .{ .raw = source };
                    defer parsed.deinit();
                    return .{ .text = parsed.value };
                }

                if (std.mem.eql(u8, kind.string, "image_file")) {
                    const parsed = std.json.parseFromValue(
                        MessageDeltaContentImageFileObject,
                        allocator,
                        source,
                        options,
                    ) catch return .{ .raw = source };
                    defer parsed.deinit();
                    return .{ .image_file = parsed.value };
                }

                if (std.mem.eql(u8, kind.string, "image_url")) {
                    const parsed = std.json.parseFromValue(
                        MessageDeltaContentImageUrlObject,
                        allocator,
                        source,
                        options,
                    ) catch return .{ .raw = source };
                    defer parsed.deinit();
                    return .{ .image_url = parsed.value };
                }

                if (std.mem.eql(u8, kind.string, "refusal")) {
                    const parsed = std.json.parseFromValue(
                        MessageDeltaContentRefusalObject,
                        allocator,
                        source,
                        options,
                    ) catch return .{ .raw = source };
                    defer parsed.deinit();
                    return .{ .refusal = parsed.value };
                }

                return .{ .raw = source };
            },
            else => return .{ .raw = source },
        }
    }
};
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
        annotations: []const MessageTextAnnotation,
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
        annotations: ?[]const MessageTextAnnotationDelta,
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
    incomplete_details: ?MessageIncompleteDetails,
    completed_at: ?i64,
    incomplete_at: ?i64,
    role: []const u8,
    content: []const MessageContent,
    assistant_id: ?[]const u8,
    run_id: ?[]const u8,
    attachments: ?[]const Attachment,
    metadata: Metadata,
};

pub const MessageIncompleteDetails = struct {
    reason: ?[]const u8,
};
pub const MessageRequestContentTextObject = struct {
    type: []const u8,
    text: []const u8,
};
pub const MessageRole = []const u8;
pub const MessageStatus = []const u8;
pub const MessageStreamEventCreated = struct {
    event: []const u8,
    data: MessageObject,
};
pub const MessageStreamEventInProgress = struct {
    event: []const u8,
    data: MessageObject,
};
pub const MessageStreamEventDelta = struct {
    event: []const u8,
    data: MessageDeltaObject,
};
pub const MessageStreamEventCompleted = struct {
    event: []const u8,
    data: MessageObject,
};
pub const MessageStreamEventIncomplete = struct {
    event: []const u8,
    data: MessageObject,
};
pub const MessageStreamEvent = union(enum) {
    created: MessageStreamEventCreated,
    in_progress: MessageStreamEventInProgress,
    delta: MessageStreamEventDelta,
    completed: MessageStreamEventCompleted,
    incomplete: MessageStreamEventIncomplete,
    raw: std.json.Value,

    pub fn forCreated(value: MessageStreamEventCreated) MessageStreamEvent {
        return .{ .created = value };
    }

    pub fn forInProgress(value: MessageStreamEventInProgress) MessageStreamEvent {
        return .{ .in_progress = value };
    }

    pub fn forDelta(value: MessageStreamEventDelta) MessageStreamEvent {
        return .{ .delta = value };
    }

    pub fn forCompleted(value: MessageStreamEventCompleted) MessageStreamEvent {
        return .{ .completed = value };
    }

    pub fn forIncomplete(value: MessageStreamEventIncomplete) MessageStreamEvent {
        return .{ .incomplete = value };
    }

    pub fn forRaw(value: std.json.Value) MessageStreamEvent {
        return .{ .raw = value };
    }

    pub fn jsonStringify(self: MessageStreamEvent, writer: anytype) !void {
        switch (self) {
            .created => |value| {
                try writer.write(value);
            },
            .in_progress => |value| {
                try writer.write(value);
            },
            .delta => |value| {
                try writer.write(value);
            },
            .completed => |value| {
                try writer.write(value);
            },
            .incomplete => |value| {
                try writer.write(value);
            },
            .raw => |value| {
                try writer.write(value);
            },
        }
    }

    pub fn jsonParse(allocator: std.mem.Allocator, source: anytype, options: std.json.ParseOptions) !MessageStreamEvent {
        const parsed = try std.json.Value.jsonParse(allocator, source, options);
        return jsonParseFromValue(allocator, parsed, options);
    }

    pub fn jsonParseFromValue(
        allocator: std.mem.Allocator,
        source: std.json.Value,
        options: std.json.ParseOptions,
    ) !MessageStreamEvent {
        switch (source) {
            .object => |root| {
                const event = root.get("event") orelse return .{ .raw = source };
                if (event != .string) return .{ .raw = source };

                if (std.mem.eql(u8, event.string, "thread.message.created")) {
                    const parsed = std.json.parseFromValue(
                        MessageStreamEventCreated,
                        allocator,
                        source,
                        options,
                    ) catch return .{ .raw = source };
                    defer parsed.deinit();
                    return .{ .created = parsed.value };
                }

                if (std.mem.eql(u8, event.string, "thread.message.in_progress")) {
                    const parsed = std.json.parseFromValue(
                        MessageStreamEventInProgress,
                        allocator,
                        source,
                        options,
                    ) catch return .{ .raw = source };
                    defer parsed.deinit();
                    return .{ .in_progress = parsed.value };
                }

                if (std.mem.eql(u8, event.string, "thread.message.delta")) {
                    const parsed = std.json.parseFromValue(
                        MessageStreamEventDelta,
                        allocator,
                        source,
                        options,
                    ) catch return .{ .raw = source };
                    defer parsed.deinit();
                    return .{ .delta = parsed.value };
                }

                if (std.mem.eql(u8, event.string, "thread.message.completed")) {
                    const parsed = std.json.parseFromValue(
                        MessageStreamEventCompleted,
                        allocator,
                        source,
                        options,
                    ) catch return .{ .raw = source };
                    defer parsed.deinit();
                    return .{ .completed = parsed.value };
                }

                if (std.mem.eql(u8, event.string, "thread.message.incomplete")) {
                    const parsed = std.json.parseFromValue(
                        MessageStreamEventIncomplete,
                        allocator,
                        source,
                        options,
                    ) catch return .{ .raw = source };
                    defer parsed.deinit();
                    return .{ .incomplete = parsed.value };
                }

                return .{ .raw = source };
            },
            else => return .{ .raw = source },
        }
    }
};
pub const Metadata = JsonObject;
pub const Model = struct {
    id: []const u8 = "",
    object: []const u8 = "",
    created: ?i64 = null,
    owned_by: []const u8 = "",
    permission: ?[]const ModelPermission = null,
    root: ?[]const u8 = null,
    parent: ?[]const u8 = null,
};
pub const ModelPermission = struct {
    id: ?[]const u8 = null,
    object: ?[]const u8 = null,
    created: ?i64 = null,
    allow_create_engine: ?bool = null,
    allow_sampling: ?bool = null,
    allow_logprobs: ?bool = null,
    allow_search_indices: ?bool = null,
    allow_view: ?bool = null,
    allow_fine_tuning: ?bool = null,
    organization: ?[]const u8 = null,
    group: ?[]const u8 = null,
    is_blocking: ?bool = null,
};
pub const ModelIds = []const []const u8;
pub const ModelIdsCompaction = ?[]const u8;
pub const ModelIdsResponses = []const u8;
pub const ModelIdsShared = []const u8;
pub const ModelResponseProperties = struct {
    metadata: ?Metadata,
    top_logprobs: ?i64,
    temperature: ?f64,
    top_p: ?f64,
    user: ?[]const u8,
    safety_identifier: ?[]const u8,
    prompt_cache_key: ?[]const u8,
    service_tier: ?ServiceTier,
    prompt_cache_retention: ?[]const u8,
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
    model: ?[]const u8,
    reasoning_effort: ?ReasoningEffort,
    name: ?[]const u8,
    description: ?[]const u8,
    instructions: ?[]const u8,
    tools: ?[]const AssistantTool,
    tool_resources: ?AssistantToolResources,
    metadata: ?Metadata,
    temperature: ?f64,
    top_p: ?f64,
    response_format: ?AssistantsApiResponseFormatOption,
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
    tool_resources: ?AssistantToolResources,
    metadata: ?Metadata,
};
pub const Move = struct {
    type: []const u8,
    x: i64,
    y: i64,
};
pub const NoiseReductionType = []const u8;
pub const OpenAIFile = struct {
    id: []const u8 = "",
    object: []const u8 = "",
    bytes: ?i64 = null,
    created_at: ?i64 = null,
    filename: []const u8 = "",
    purpose: []const u8 = "",
    status: []const u8 = "",
    status_details: ?JsonObject = null,
};
pub const OrderEnum = []const u8;
pub const OtherChunkingStrategyResponseParam = struct {
    type: []const u8,
};
pub const OutputAudio = struct {
    type: []const u8,
    data: []const u8,
    transcript: []const u8,
};
pub const OutputContent = union(enum) {
    text: OutputTextContent,
    refusal: RefusalContent,
    reasoning: ReasoningTextContent,
    audio: OutputAudio,
    raw: std.json.Value,

    pub fn forText(value: OutputTextContent) OutputContent {
        return .{ .text = value };
    }

    pub fn forRefusal(value: RefusalContent) OutputContent {
        return .{ .refusal = value };
    }

    pub fn forReasoning(value: ReasoningTextContent) OutputContent {
        return .{ .reasoning = value };
    }

    pub fn forAudio(value: OutputAudio) OutputContent {
        return .{ .audio = value };
    }

    pub fn forRaw(value: std.json.Value) OutputContent {
        return .{ .raw = value };
    }

    pub fn jsonStringify(self: OutputContent, writer: anytype) !void {
        switch (self) {
            .text => |value| {
                try writer.write(value);
            },
            .refusal => |value| {
                try writer.write(value);
            },
            .reasoning => |value| {
                try writer.write(value);
            },
            .audio => |value| {
                try writer.write(value);
            },
            .raw => |value| {
                try writer.write(value);
            },
        }
    }

    pub fn jsonParse(allocator: std.mem.Allocator, source: anytype, options: std.json.ParseOptions) !OutputContent {
        const parsed = try std.json.Value.jsonParse(allocator, source, options);
        return jsonParseFromValue(allocator, parsed, options);
    }

    pub fn jsonParseFromValue(
        allocator: std.mem.Allocator,
        source: std.json.Value,
        options: std.json.ParseOptions,
    ) !OutputContent {
        switch (source) {
            .object => |root| {
                const kind = root.get("type") orelse return .{ .raw = source };
                if (kind != .string) return .{ .raw = source };

                if (std.mem.eql(u8, kind.string, "output_text")) {
                    const parsed = std.json.parseFromValue(
                        OutputTextContent,
                        allocator,
                        source,
                        options,
                    ) catch return .{ .raw = source };
                    defer parsed.deinit();
                    return .{ .text = parsed.value };
                }

                if (std.mem.eql(u8, kind.string, "refusal")) {
                    const parsed = std.json.parseFromValue(
                        RefusalContent,
                        allocator,
                        source,
                        options,
                    ) catch return .{ .raw = source };
                    defer parsed.deinit();
                    return .{ .refusal = parsed.value };
                }

                if (std.mem.eql(u8, kind.string, "reasoning_text")) {
                    const parsed = std.json.parseFromValue(
                        ReasoningTextContent,
                        allocator,
                        source,
                        options,
                    ) catch return .{ .raw = source };
                    defer parsed.deinit();
                    return .{ .reasoning = parsed.value };
                }

                if (std.mem.eql(u8, kind.string, "output_audio")) {
                    const parsed = std.json.parseFromValue(
                        OutputAudio,
                        allocator,
                        source,
                        options,
                    ) catch return .{ .raw = source };
                    defer parsed.deinit();
                    return .{ .audio = parsed.value };
                }

                return .{ .raw = source };
            },
            else => return .{ .raw = source },
        }
    }
};
pub const OutputItem = union(enum) {
    message: OutputMessage,
    file_search_tool_call: FileSearchToolCall,
    function_tool_call: FunctionToolCall,
    web_search_tool_call: WebSearchToolCall,
    computer_tool_call: ComputerToolCall,
    reasoning: ReasoningItem,
    compaction: CompactionBody,
    image_gen_tool_call: ImageGenToolCall,
    code_interpreter_tool_call: CodeInterpreterToolCall,
    local_shell_tool_call: LocalShellToolCall,
    function_shell_call: FunctionShellCall,
    function_shell_call_output: FunctionShellCallOutput,
    apply_patch_tool_call: ApplyPatchToolCall,
    apply_patch_tool_call_output: ApplyPatchToolCallOutput,
    mcp_tool_call: MCPToolCall,
    mcp_list_tools: MCPListTools,
    mcp_approval_request: MCPApprovalRequest,
    custom_tool_call: CustomToolCall,
    raw: std.json.Value,

    pub fn forMessage(value: OutputMessage) OutputItem {
        return .{ .message = value };
    }

    pub fn forFileSearchToolCall(value: FileSearchToolCall) OutputItem {
        return .{ .file_search_tool_call = value };
    }

    pub fn forFunctionToolCall(value: FunctionToolCall) OutputItem {
        return .{ .function_tool_call = value };
    }

    pub fn forWebSearchToolCall(value: WebSearchToolCall) OutputItem {
        return .{ .web_search_tool_call = value };
    }

    pub fn forComputerToolCall(value: ComputerToolCall) OutputItem {
        return .{ .computer_tool_call = value };
    }

    pub fn forReasoning(value: ReasoningItem) OutputItem {
        return .{ .reasoning = value };
    }

    pub fn forCompaction(value: CompactionBody) OutputItem {
        return .{ .compaction = value };
    }

    pub fn forImageGenToolCall(value: ImageGenToolCall) OutputItem {
        return .{ .image_gen_tool_call = value };
    }

    pub fn forCodeInterpreterToolCall(value: CodeInterpreterToolCall) OutputItem {
        return .{ .code_interpreter_tool_call = value };
    }

    pub fn forLocalShellToolCall(value: LocalShellToolCall) OutputItem {
        return .{ .local_shell_tool_call = value };
    }

    pub fn forFunctionShellCall(value: FunctionShellCall) OutputItem {
        return .{ .function_shell_call = value };
    }

    pub fn forFunctionShellCallOutput(value: FunctionShellCallOutput) OutputItem {
        return .{ .function_shell_call_output = value };
    }

    pub fn forApplyPatchToolCall(value: ApplyPatchToolCall) OutputItem {
        return .{ .apply_patch_tool_call = value };
    }

    pub fn forApplyPatchToolCallOutput(value: ApplyPatchToolCallOutput) OutputItem {
        return .{ .apply_patch_tool_call_output = value };
    }

    pub fn forMCPToolCall(value: MCPToolCall) OutputItem {
        return .{ .mcp_tool_call = value };
    }

    pub fn forMCPListTools(value: MCPListTools) OutputItem {
        return .{ .mcp_list_tools = value };
    }

    pub fn forMCPApprovalRequest(value: MCPApprovalRequest) OutputItem {
        return .{ .mcp_approval_request = value };
    }

    pub fn forCustomToolCall(value: CustomToolCall) OutputItem {
        return .{ .custom_tool_call = value };
    }

    pub fn forRaw(value: std.json.Value) OutputItem {
        return .{ .raw = value };
    }

    pub fn jsonStringify(self: OutputItem, writer: anytype) !void {
        switch (self) {
            .message => |value| try writer.write(value),
            .file_search_tool_call => |value| try writer.write(value),
            .function_tool_call => |value| try writer.write(value),
            .web_search_tool_call => |value| try writer.write(value),
            .computer_tool_call => |value| try writer.write(value),
            .reasoning => |value| try writer.write(value),
            .compaction => |value| try writer.write(value),
            .image_gen_tool_call => |value| try writer.write(value),
            .code_interpreter_tool_call => |value| try writer.write(value),
            .local_shell_tool_call => |value| try writer.write(value),
            .function_shell_call => |value| try writer.write(value),
            .function_shell_call_output => |value| try writer.write(value),
            .apply_patch_tool_call => |value| try writer.write(value),
            .apply_patch_tool_call_output => |value| try writer.write(value),
            .mcp_tool_call => |value| try writer.write(value),
            .mcp_list_tools => |value| try writer.write(value),
            .mcp_approval_request => |value| try writer.write(value),
            .custom_tool_call => |value| try writer.write(value),
            .raw => |value| try writer.write(value),
        }
    }

    pub fn jsonParse(allocator: std.mem.Allocator, source: anytype, options: std.json.ParseOptions) !OutputItem {
        const parsed = try std.json.Value.jsonParse(allocator, source, options);
        return try jsonParseFromValue(allocator, parsed, options);
    }

    pub fn jsonParseFromValue(
        allocator: std.mem.Allocator,
        source: std.json.Value,
        options: std.json.ParseOptions,
    ) !OutputItem {
        switch (source) {
            .object => |root| {
                const item_type = root.get("type") orelse return .{ .raw = source };
                if (item_type != .string) return .{ .raw = source };

                if (std.mem.eql(u8, item_type.string, "message")) {
                    if (std.json.parseFromValue(OutputMessage, allocator, source, options)) |parsed| {
                        defer parsed.deinit();
                        return .{ .message = parsed.value };
                    } else |_| {}
                }

                if (std.mem.eql(u8, item_type.string, "file_search_call")) {
                    if (std.json.parseFromValue(FileSearchToolCall, allocator, source, options)) |parsed| {
                        defer parsed.deinit();
                        return .{ .file_search_tool_call = parsed.value };
                    } else |_| {}
                }

                if (std.mem.eql(u8, item_type.string, "function_call")) {
                    if (std.json.parseFromValue(FunctionToolCall, allocator, source, options)) |parsed| {
                        defer parsed.deinit();
                        return .{ .function_tool_call = parsed.value };
                    } else |_| {}
                }

                if (std.mem.eql(u8, item_type.string, "web_search_call")) {
                    if (std.json.parseFromValue(WebSearchToolCall, allocator, source, options)) |parsed| {
                        defer parsed.deinit();
                        return .{ .web_search_tool_call = parsed.value };
                    } else |_| {}
                }

                if (std.mem.eql(u8, item_type.string, "computer_call")) {
                    if (std.json.parseFromValue(ComputerToolCall, allocator, source, options)) |parsed| {
                        defer parsed.deinit();
                        return .{ .computer_tool_call = parsed.value };
                    } else |_| {}
                }

                if (std.mem.eql(u8, item_type.string, "reasoning")) {
                    if (std.json.parseFromValue(ReasoningItem, allocator, source, options)) |parsed| {
                        defer parsed.deinit();
                        return .{ .reasoning = parsed.value };
                    } else |_| {}
                }

                if (std.mem.eql(u8, item_type.string, "compaction")) {
                    if (std.json.parseFromValue(CompactionBody, allocator, source, options)) |parsed| {
                        defer parsed.deinit();
                        return .{ .compaction = parsed.value };
                    } else |_| {}
                }

                if (std.mem.eql(u8, item_type.string, "image_generation_call")) {
                    if (std.json.parseFromValue(ImageGenToolCall, allocator, source, options)) |parsed| {
                        defer parsed.deinit();
                        return .{ .image_gen_tool_call = parsed.value };
                    } else |_| {}
                }

                if (std.mem.eql(u8, item_type.string, "code_interpreter_call")) {
                    if (std.json.parseFromValue(CodeInterpreterToolCall, allocator, source, options)) |parsed| {
                        defer parsed.deinit();
                        return .{ .code_interpreter_tool_call = parsed.value };
                    } else |_| {}
                }

                if (std.mem.eql(u8, item_type.string, "local_shell_call")) {
                    if (std.json.parseFromValue(LocalShellToolCall, allocator, source, options)) |parsed| {
                        defer parsed.deinit();
                        return .{ .local_shell_tool_call = parsed.value };
                    } else |_| {}
                }

                if (std.mem.eql(u8, item_type.string, "shell_call")) {
                    if (std.json.parseFromValue(FunctionShellCall, allocator, source, options)) |parsed| {
                        defer parsed.deinit();
                        return .{ .function_shell_call = parsed.value };
                    } else |_| {}
                }

                if (std.mem.eql(u8, item_type.string, "shell_call_output")) {
                    if (std.json.parseFromValue(FunctionShellCallOutput, allocator, source, options)) |parsed| {
                        defer parsed.deinit();
                        return .{ .function_shell_call_output = parsed.value };
                    } else |_| {}
                }

                if (std.mem.eql(u8, item_type.string, "apply_patch_call")) {
                    if (std.json.parseFromValue(ApplyPatchToolCall, allocator, source, options)) |parsed| {
                        defer parsed.deinit();
                        return .{ .apply_patch_tool_call = parsed.value };
                    } else |_| {}
                }

                if (std.mem.eql(u8, item_type.string, "apply_patch_call_output")) {
                    if (std.json.parseFromValue(ApplyPatchToolCallOutput, allocator, source, options)) |parsed| {
                        defer parsed.deinit();
                        return .{ .apply_patch_tool_call_output = parsed.value };
                    } else |_| {}
                }

                if (std.mem.eql(u8, item_type.string, "mcp_call")) {
                    if (std.json.parseFromValue(MCPToolCall, allocator, source, options)) |parsed| {
                        defer parsed.deinit();
                        return .{ .mcp_tool_call = parsed.value };
                    } else |_| {}
                }

                if (std.mem.eql(u8, item_type.string, "mcp_list_tools")) {
                    if (std.json.parseFromValue(MCPListTools, allocator, source, options)) |parsed| {
                        defer parsed.deinit();
                        return .{ .mcp_list_tools = parsed.value };
                    } else |_| {}
                }

                if (std.mem.eql(u8, item_type.string, "mcp_approval_request")) {
                    if (std.json.parseFromValue(MCPApprovalRequest, allocator, source, options)) |parsed| {
                        defer parsed.deinit();
                        return .{ .mcp_approval_request = parsed.value };
                    } else |_| {}
                }

                if (std.mem.eql(u8, item_type.string, "custom_tool_call")) {
                    if (std.json.parseFromValue(CustomToolCall, allocator, source, options)) |parsed| {
                        defer parsed.deinit();
                        return .{ .custom_tool_call = parsed.value };
                    } else |_| {}
                }

                return .{ .raw = source };
            },
            else => return .{ .raw = source },
        }
    }
};
pub const OutputMessage = struct {
    id: []const u8,
    type: []const u8,
    role: []const u8,
    content: []const OutputMessageContent,
    status: []const u8,
};
pub const OutputMessageContent = OutputContent;
pub const OutputTextContent = struct {
    type: []const u8,
    text: []const u8,
    annotations: ?[]const Annotation = null,
    logprobs: ?[]const LogProb,
};
pub const ParallelToolCalls = bool;
pub const PartialImages = i64;
pub const PredictionContent = struct {
    type: []const u8,
    content: GenericContent,
};
pub const Project = struct {
    id: []const u8,
    object: []const u8,
    name: []const u8,
    created_at: i64,
    archived_at: ?i64,
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
    next: ?[]const u8,
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
pub const PromptTemplate = struct {
    id: []const u8,
    version: ?[]const u8 = null,
    variables: ?ResponsePromptVariables = null,
};

pub const Prompt = union(enum) {
    template: PromptTemplate,
    raw: std.json.Value,

    pub fn forTemplate(value: PromptTemplate) Prompt {
        return .{ .template = value };
    }

    pub fn forRaw(value: std.json.Value) Prompt {
        return .{ .raw = value };
    }

    pub fn jsonStringify(self: Prompt, writer: anytype) !void {
        switch (self) {
            .template => |value| {
                try writer.write(value);
            },
            .raw => |value| {
                try writer.write(value);
            },
        }
    }

    pub fn jsonParse(allocator: std.mem.Allocator, source: anytype, options: std.json.ParseOptions) !Prompt {
        const parsed = try std.json.Value.jsonParse(allocator, source, options);
        return jsonParseFromValue(allocator, parsed, options);
    }

    pub fn jsonParseFromValue(
        allocator: std.mem.Allocator,
        source: std.json.Value,
        options: std.json.ParseOptions,
    ) !Prompt {
        _ = allocator;
        _ = options;

        switch (source) {
            .object => |root| {
                const id = root.get("id") orelse return .{ .raw = source };
                if (id != .string) return .{ .raw = source };

                return .{
                    .template = .{
                        .id = id.string,
                        .version = if (root.get("version")) |value| switch (value) {
                            .null => null,
                            .string => value.string,
                            else => return .{ .raw = source },
                        } else null,
                        .variables = if (root.get("variables")) |value| switch (value) {
                            .null => null,
                            else => value,
                        } else null,
                    },
                };
            },
            else => return .{ .raw = source },
        }
    }
};
pub const PublicAssignOrganizationGroupRoleBody = struct {
    role_id: []const u8,
};
pub const PublicCreateOrganizationRoleBody = struct {
    role_name: []const u8,
    permissions: []const []const u8,
    description: ?[]const u8,
};
pub const PublicRoleListResource = struct {
    object: []const u8,
    data: []const Role,
    has_more: bool,
    next: ?[]const u8,
};
pub const PublicUpdateOrganizationRoleBody = struct {
    permissions: ?[]const []const u8,
    description: ?[]const u8,
    role_name: ?[]const u8,
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
pub const RealtimeAudioFormatPcm = struct {
    type: []const u8,
    rate: ?i64 = null,
};

pub const RealtimeAudioFormatPcmu = struct {
    type: []const u8,
};

pub const RealtimeAudioFormatPcma = struct {
    type: []const u8,
};

pub const RealtimeAudioFormats = union(enum) {
    pcm: RealtimeAudioFormatPcm,
    pcmu: RealtimeAudioFormatPcmu,
    pcma: RealtimeAudioFormatPcma,
    raw: std.json.Value,

    pub fn forPcm(value: RealtimeAudioFormatPcm) RealtimeAudioFormats {
        return .{ .pcm = value };
    }

    pub fn forPcmu(value: RealtimeAudioFormatPcmu) RealtimeAudioFormats {
        return .{ .pcmu = value };
    }

    pub fn forPcma(value: RealtimeAudioFormatPcma) RealtimeAudioFormats {
        return .{ .pcma = value };
    }

    pub fn forRaw(value: std.json.Value) RealtimeAudioFormats {
        return .{ .raw = value };
    }

    pub fn jsonStringify(self: RealtimeAudioFormats, writer: anytype) !void {
        switch (self) {
            .pcm => |value| {
                try writer.write(value);
            },
            .pcmu => |value| {
                try writer.write(value);
            },
            .pcma => |value| {
                try writer.write(value);
            },
            .raw => |value| {
                try writer.write(value);
            },
        }
    }

    pub fn jsonParse(allocator: std.mem.Allocator, source: anytype, options: std.json.ParseOptions) !RealtimeAudioFormats {
        const parsed = try std.json.Value.jsonParse(allocator, source, options);
        return jsonParseFromValue(allocator, parsed, options);
    }

    pub fn jsonParseFromValue(
        allocator: std.mem.Allocator,
        source: std.json.Value,
        options: std.json.ParseOptions,
    ) !RealtimeAudioFormats {
        _ = allocator;
        _ = options;

        switch (source) {
            .object => |root| {
                const format_type = root.get("type") orelse return .{ .raw = source };
                if (format_type != .string) return .{ .raw = source };

                if (std.mem.eql(u8, format_type.string, "audio/pcm")) {
                    return .{
                        .pcm = .{
                            .type = format_type.string,
                            .rate = if (root.get("rate")) |rate| switch (rate) {
                                .null => null,
                                .integer => rate.integer,
                                else => return .{ .raw = source },
                            } else null,
                        },
                    };
                }

                if (std.mem.eql(u8, format_type.string, "audio/pcmu")) {
                    return .{ .pcmu = .{ .type = format_type.string } };
                }

                if (std.mem.eql(u8, format_type.string, "audio/pcma")) {
                    return .{ .pcma = .{ .type = format_type.string } };
                }

                return .{ .raw = source };
            },
            else => return .{ .raw = source },
        }
    }
};
pub const RealtimeBetaClientEventConversationItemCreate = struct {
    event_id: ?[]const u8,
    type: []const u8,
    previous_item_id: ?[]const u8,
    item: RealtimeConversationItem,
};
pub const RealtimeBetaClientEventConversationItemDelete = struct {
    event_id: ?[]const u8,
    type: []const u8,
    item_id: []const u8,
};
pub const RealtimeBetaClientEventConversationItemRetrieve = struct {
    event_id: ?[]const u8,
    type: []const u8,
    item_id: []const u8,
};
pub const RealtimeBetaClientEventConversationItemTruncate = struct {
    event_id: ?[]const u8,
    type: []const u8,
    item_id: []const u8,
    content_index: i64,
    audio_end_ms: i64,
};
pub const RealtimeBetaClientEventInputAudioBufferAppend = struct {
    event_id: ?[]const u8,
    type: []const u8,
    audio: []const u8,
};
pub const RealtimeBetaClientEventInputAudioBufferClear = struct {
    event_id: ?[]const u8,
    type: []const u8,
};
pub const RealtimeBetaClientEventInputAudioBufferCommit = struct {
    event_id: ?[]const u8,
    type: []const u8,
};
pub const RealtimeBetaClientEventOutputAudioBufferClear = struct {
    event_id: ?[]const u8,
    type: []const u8,
};
pub const RealtimeBetaClientEventResponseCancel = struct {
    event_id: ?[]const u8,
    type: []const u8,
    response_id: ?[]const u8,
};
pub const RealtimeBetaClientEventResponseCreate = struct {
    event_id: ?[]const u8,
    type: []const u8,
    response: ?RealtimeBetaResponseCreateParams,
};
pub const RealtimeBetaClientEventSessionUpdate = struct {
    event_id: ?[]const u8,
    type: []const u8,
    session: RealtimeSessionCreateRequest,
};
pub const RealtimeBetaClientEventTranscriptionSessionUpdate = struct {
    event_id: ?[]const u8,
    type: []const u8,
    session: RealtimeTranscriptionSessionCreateRequest,
};
pub const RealtimeBetaResponse = struct {
    id: ?[]const u8,
    object: ?[]const u8,
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
    max_output_tokens: ?i64,
};
pub const RealtimeBetaResponseCreateParams = struct {
    modalities: ?[]const []const u8,
    instructions: ?[]const u8,
    voice: ?VoiceIdsShared,
    output_audio_format: ?[]const u8,
    tools: ?[]const RealtimeFunctionTool,
    tool_choice: ?ToolChoiceParam,
    temperature: ?f64,
    max_output_tokens: ?i64,
    conversation: ?ConversationParam,
    metadata: ?Metadata,
    prompt: ?Prompt,
    input: ?[]const RealtimeConversationItem,
};
pub const RealtimeBetaServerEventConversationItemCreated = struct {
    event_id: []const u8,
    type: []const u8,
    previous_item_id: ?[]const u8,
    item: RealtimeConversationItem,
};
pub const RealtimeBetaServerEventConversationItemDeleted = struct {
    event_id: []const u8,
    type: []const u8,
    item_id: []const u8,
};
pub const RealtimeBetaServerEventConversationItemInputAudioTranscriptionCompleted = struct {
    event_id: []const u8,
    type: []const u8,
    item_id: []const u8,
    content_index: i64,
    transcript: []const u8,
    logprobs: ?[]const LogProbProperties,
    usage: TranscriptTextUsage,
};
pub const RealtimeBetaServerEventConversationItemInputAudioTranscriptionDelta = struct {
    event_id: []const u8,
    type: []const u8,
    item_id: []const u8,
    content_index: ?i64,
    delta: ?[]const u8,
    logprobs: ?[]const LogProbProperties,
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
    type: []const u8,
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
    type: []const u8,
    item: RealtimeConversationItem,
};
pub const RealtimeBetaServerEventConversationItemTruncated = struct {
    event_id: []const u8,
    type: []const u8,
    item_id: []const u8,
    content_index: i64,
    audio_end_ms: i64,
};
pub const RealtimeBetaServerEventError = struct {
    event_id: []const u8,
    type: []const u8,
    _error: struct {
        type: []const u8,
        code: ?[]const u8,
        message: []const u8,
        param: ?[]const u8,
        event_id: ?[]const u8,
    },
};
pub const RealtimeBetaServerEventInputAudioBufferCleared = struct {
    event_id: []const u8,
    type: []const u8,
};
pub const RealtimeBetaServerEventInputAudioBufferCommitted = struct {
    event_id: []const u8,
    type: []const u8,
    previous_item_id: ?[]const u8,
    item_id: []const u8,
};
pub const RealtimeBetaServerEventInputAudioBufferSpeechStarted = struct {
    event_id: []const u8,
    type: []const u8,
    audio_start_ms: i64,
    item_id: []const u8,
};
pub const RealtimeBetaServerEventInputAudioBufferSpeechStopped = struct {
    event_id: []const u8,
    type: []const u8,
    audio_end_ms: i64,
    item_id: []const u8,
};
pub const RealtimeBetaServerEventMCPListToolsCompleted = struct {
    event_id: []const u8,
    type: []const u8,
    item_id: []const u8,
};
pub const RealtimeBetaServerEventMCPListToolsFailed = struct {
    event_id: []const u8,
    type: []const u8,
    item_id: []const u8,
};
pub const RealtimeBetaServerEventMCPListToolsInProgress = struct {
    event_id: []const u8,
    type: []const u8,
    item_id: []const u8,
};
pub const RealtimeBetaServerEventRateLimitsUpdated = struct {
    event_id: []const u8,
    type: []const u8,
    rate_limits: []const struct {
        name: ?[]const u8,
        limit: ?i64,
        remaining: ?i64,
        reset_seconds: ?f64,
    },
};
pub const RealtimeBetaServerEventResponseAudioDelta = struct {
    event_id: []const u8,
    type: []const u8,
    response_id: []const u8,
    item_id: []const u8,
    output_index: i64,
    content_index: i64,
    delta: []const u8,
};
pub const RealtimeBetaServerEventResponseAudioDone = struct {
    event_id: []const u8,
    type: []const u8,
    response_id: []const u8,
    item_id: []const u8,
    output_index: i64,
    content_index: i64,
};
pub const RealtimeBetaServerEventResponseAudioTranscriptDelta = struct {
    event_id: []const u8,
    type: []const u8,
    response_id: []const u8,
    item_id: []const u8,
    output_index: i64,
    content_index: i64,
    delta: []const u8,
};
pub const RealtimeBetaServerEventResponseAudioTranscriptDone = struct {
    event_id: []const u8,
    type: []const u8,
    response_id: []const u8,
    item_id: []const u8,
    output_index: i64,
    content_index: i64,
    transcript: []const u8,
};
pub const RealtimeBetaServerEventResponseContentPartAdded = struct {
    event_id: []const u8,
    type: []const u8,
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
    type: []const u8,
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
    type: []const u8,
    response: RealtimeBetaResponse,
};
pub const RealtimeBetaServerEventResponseDone = struct {
    event_id: []const u8,
    type: []const u8,
    response: RealtimeBetaResponse,
};
pub const RealtimeBetaServerEventResponseFunctionCallArgumentsDelta = struct {
    event_id: []const u8,
    type: []const u8,
    response_id: []const u8,
    item_id: []const u8,
    output_index: i64,
    call_id: []const u8,
    delta: []const u8,
};
pub const RealtimeBetaServerEventResponseFunctionCallArgumentsDone = struct {
    event_id: []const u8,
    type: []const u8,
    response_id: []const u8,
    item_id: []const u8,
    output_index: i64,
    call_id: []const u8,
    arguments: []const u8,
};
pub const RealtimeBetaServerEventResponseMCPCallArgumentsDelta = struct {
    event_id: []const u8,
    type: []const u8,
    response_id: []const u8,
    item_id: []const u8,
    output_index: i64,
    delta: []const u8,
    obfuscation: ?RealtimeObfuscation,
};
pub const RealtimeBetaServerEventResponseMCPCallArgumentsDone = struct {
    event_id: []const u8,
    type: []const u8,
    response_id: []const u8,
    item_id: []const u8,
    output_index: i64,
    arguments: []const u8,
};
pub const RealtimeBetaServerEventResponseMCPCallCompleted = struct {
    event_id: []const u8,
    type: []const u8,
    output_index: i64,
    item_id: []const u8,
};
pub const RealtimeBetaServerEventResponseMCPCallFailed = struct {
    event_id: []const u8,
    type: []const u8,
    output_index: i64,
    item_id: []const u8,
};
pub const RealtimeBetaServerEventResponseMCPCallInProgress = struct {
    event_id: []const u8,
    type: []const u8,
    output_index: i64,
    item_id: []const u8,
};
pub const RealtimeBetaServerEventResponseOutputItemAdded = struct {
    event_id: []const u8,
    type: []const u8,
    response_id: []const u8,
    output_index: i64,
    item: RealtimeConversationItem,
};
pub const RealtimeBetaServerEventResponseOutputItemDone = struct {
    event_id: []const u8,
    type: []const u8,
    response_id: []const u8,
    output_index: i64,
    item: RealtimeConversationItem,
};
pub const RealtimeBetaServerEventResponseTextDelta = struct {
    event_id: []const u8,
    type: []const u8,
    response_id: []const u8,
    item_id: []const u8,
    output_index: i64,
    content_index: i64,
    delta: []const u8,
};
pub const RealtimeBetaServerEventResponseTextDone = struct {
    event_id: []const u8,
    type: []const u8,
    response_id: []const u8,
    item_id: []const u8,
    output_index: i64,
    content_index: i64,
    text: []const u8,
};
pub const RealtimeBetaServerEventSessionCreated = struct {
    event_id: []const u8,
    type: []const u8,
    session: RealtimeSession,
};
pub const RealtimeBetaServerEventSessionUpdated = struct {
    event_id: []const u8,
    type: []const u8,
    session: RealtimeSession,
};
pub const RealtimeBetaServerEventTranscriptionSessionCreated = struct {
    event_id: []const u8,
    type: []const u8,
    session: RealtimeTranscriptionSessionCreateResponse,
};
pub const RealtimeBetaServerEventTranscriptionSessionUpdated = struct {
    event_id: []const u8,
    type: []const u8,
    session: RealtimeTranscriptionSessionCreateResponse,
};
pub const RealtimeCallCreateRequest = struct {
    sdp: []const u8,
    session: ?RealtimeSession,
};
pub const RealtimeCallReferRequest = struct {
    target_uri: []const u8,
};
pub const RealtimeCallRejectRequest = struct {
    status_code: ?i64,
};
pub const RealtimeClientEvent = union(enum) {
    conversation_item_create: RealtimeClientEventConversationItemCreate,
    conversation_item_delete: RealtimeClientEventConversationItemDelete,
    conversation_item_retrieve: RealtimeClientEventConversationItemRetrieve,
    conversation_item_truncate: RealtimeClientEventConversationItemTruncate,
    input_audio_buffer_append: RealtimeClientEventInputAudioBufferAppend,
    input_audio_buffer_clear: RealtimeClientEventInputAudioBufferClear,
    input_audio_buffer_commit: RealtimeClientEventInputAudioBufferCommit,
    output_audio_buffer_clear: RealtimeClientEventOutputAudioBufferClear,
    response_cancel: RealtimeClientEventResponseCancel,
    response_create: RealtimeClientEventResponseCreate,
    session_update: RealtimeClientEventSessionUpdate,
    transcription_session_update: RealtimeClientEventTranscriptionSessionUpdate,
    raw: JsonObject,

    pub fn forRaw(value: JsonObject) RealtimeClientEvent {
        return .{ .raw = value };
    }

    pub fn jsonStringify(self: RealtimeClientEvent, writer: anytype) !void {
        switch (self) {
            .conversation_item_create => |value| try writer.write(value),
            .conversation_item_delete => |value| try writer.write(value),
            .conversation_item_retrieve => |value| try writer.write(value),
            .conversation_item_truncate => |value| try writer.write(value),
            .input_audio_buffer_append => |value| try writer.write(value),
            .input_audio_buffer_clear => |value| try writer.write(value),
            .input_audio_buffer_commit => |value| try writer.write(value),
            .output_audio_buffer_clear => |value| try writer.write(value),
            .response_cancel => |value| try writer.write(value),
            .response_create => |value| try writer.write(value),
            .session_update => |value| try writer.write(value),
            .transcription_session_update => |value| try writer.write(value),
            .raw => |value| try writer.write(value),
        }
    }

    pub fn jsonParse(allocator: std.mem.Allocator, source: anytype, options: std.json.ParseOptions) !RealtimeClientEvent {
        const parsed = try std.json.Value.jsonParse(allocator, source, options);
        return try jsonParseFromValue(allocator, parsed, options);
    }

    pub fn jsonParseFromValue(
        allocator: std.mem.Allocator,
        source: std.json.Value,
        options: std.json.ParseOptions,
    ) !RealtimeClientEvent {
        switch (source) {
            .object => |root| {
                const event_type = root.get("type") orelse return .{ .raw = source };
                if (event_type != .string) return .{ .raw = source };

                if (std.mem.eql(u8, event_type.string, "conversation.item.create")) {
                    const parsed = std.json.parseFromValue(RealtimeClientEventConversationItemCreate, allocator, source, options) catch return .{ .raw = source };
                    defer parsed.deinit();
                    return .{ .conversation_item_create = parsed.value };
                }

                if (std.mem.eql(u8, event_type.string, "conversation.item.delete")) {
                    const parsed = std.json.parseFromValue(RealtimeClientEventConversationItemDelete, allocator, source, options) catch return .{ .raw = source };
                    defer parsed.deinit();
                    return .{ .conversation_item_delete = parsed.value };
                }

                if (std.mem.eql(u8, event_type.string, "conversation.item.retrieve")) {
                    const parsed = std.json.parseFromValue(RealtimeClientEventConversationItemRetrieve, allocator, source, options) catch return .{ .raw = source };
                    defer parsed.deinit();
                    return .{ .conversation_item_retrieve = parsed.value };
                }

                if (std.mem.eql(u8, event_type.string, "conversation.item.truncate")) {
                    const parsed = std.json.parseFromValue(RealtimeClientEventConversationItemTruncate, allocator, source, options) catch return .{ .raw = source };
                    defer parsed.deinit();
                    return .{ .conversation_item_truncate = parsed.value };
                }

                if (std.mem.eql(u8, event_type.string, "input_audio_buffer.append")) {
                    const parsed = std.json.parseFromValue(RealtimeClientEventInputAudioBufferAppend, allocator, source, options) catch return .{ .raw = source };
                    defer parsed.deinit();
                    return .{ .input_audio_buffer_append = parsed.value };
                }

                if (std.mem.eql(u8, event_type.string, "input_audio_buffer.clear")) {
                    const parsed = std.json.parseFromValue(RealtimeClientEventInputAudioBufferClear, allocator, source, options) catch return .{ .raw = source };
                    defer parsed.deinit();
                    return .{ .input_audio_buffer_clear = parsed.value };
                }

                if (std.mem.eql(u8, event_type.string, "input_audio_buffer.commit")) {
                    const parsed = std.json.parseFromValue(RealtimeClientEventInputAudioBufferCommit, allocator, source, options) catch return .{ .raw = source };
                    defer parsed.deinit();
                    return .{ .input_audio_buffer_commit = parsed.value };
                }

                if (std.mem.eql(u8, event_type.string, "output_audio_buffer.clear")) {
                    const parsed = std.json.parseFromValue(RealtimeClientEventOutputAudioBufferClear, allocator, source, options) catch return .{ .raw = source };
                    defer parsed.deinit();
                    return .{ .output_audio_buffer_clear = parsed.value };
                }

                if (std.mem.eql(u8, event_type.string, "response.cancel")) {
                    const parsed = std.json.parseFromValue(RealtimeClientEventResponseCancel, allocator, source, options) catch return .{ .raw = source };
                    defer parsed.deinit();
                    return .{ .response_cancel = parsed.value };
                }

                if (std.mem.eql(u8, event_type.string, "response.create")) {
                    const parsed = std.json.parseFromValue(RealtimeClientEventResponseCreate, allocator, source, options) catch return .{ .raw = source };
                    defer parsed.deinit();
                    return .{ .response_create = parsed.value };
                }

                if (std.mem.eql(u8, event_type.string, "session.update")) {
                    const parsed = std.json.parseFromValue(RealtimeClientEventSessionUpdate, allocator, source, options) catch return .{ .raw = source };
                    defer parsed.deinit();
                    return .{ .session_update = parsed.value };
                }

                if (std.mem.eql(u8, event_type.string, "transcription_session.update")) {
                    const parsed = std.json.parseFromValue(RealtimeClientEventTranscriptionSessionUpdate, allocator, source, options) catch return .{ .raw = source };
                    defer parsed.deinit();
                    return .{ .transcription_session_update = parsed.value };
                }

                return .{ .raw = source };
            },
            else => return .{ .raw = source },
        }
    }
};
pub const RealtimeClientEventConversationItemCreate = struct {
    event_id: ?[]const u8,
    type: []const u8,
    previous_item_id: ?[]const u8,
    item: RealtimeConversationItem,
};
pub const RealtimeClientEventConversationItemDelete = struct {
    event_id: ?[]const u8,
    type: []const u8,
    item_id: []const u8,
};
pub const RealtimeClientEventConversationItemRetrieve = struct {
    event_id: ?[]const u8,
    type: []const u8,
    item_id: []const u8,
};
pub const RealtimeClientEventConversationItemTruncate = struct {
    event_id: ?[]const u8,
    type: []const u8,
    item_id: []const u8,
    content_index: i64,
    audio_end_ms: i64,
};
pub const RealtimeClientEventInputAudioBufferAppend = struct {
    event_id: ?[]const u8,
    type: []const u8,
    audio: []const u8,
};
pub const RealtimeClientEventInputAudioBufferClear = struct {
    event_id: ?[]const u8,
    type: []const u8,
};
pub const RealtimeClientEventInputAudioBufferCommit = struct {
    event_id: ?[]const u8,
    type: []const u8,
};
pub const RealtimeClientEventOutputAudioBufferClear = struct {
    event_id: ?[]const u8,
    type: []const u8,
};
pub const RealtimeClientEventResponseCancel = struct {
    event_id: ?[]const u8,
    type: []const u8,
    response_id: ?[]const u8,
};
pub const RealtimeClientEventResponseCreate = struct {
    event_id: ?[]const u8,
    type: []const u8,
    response: ?RealtimeResponseCreateParams,
};
pub const RealtimeClientEventSessionUpdate = struct {
    event_id: ?[]const u8,
    type: []const u8,
    session: RealtimeSession,
};
pub const RealtimeClientEventTranscriptionSessionUpdate = struct {
    event_id: ?[]const u8,
    type: []const u8,
    session: RealtimeTranscriptionSessionCreateRequest,
};
pub const RealtimeConnectParams = struct {
    model: ?[]const u8,
    call_id: ?[]const u8,
};
pub const RealtimeConversationItem = union(enum) {
    function_call: RealtimeConversationItemFunctionCall,
    function_call_output: RealtimeConversationItemFunctionCallOutput,
    message_assistant: RealtimeConversationItemMessageAssistant,
    message_system: RealtimeConversationItemMessageSystem,
    message_user: RealtimeConversationItemMessageUser,
    message_with_reference: RealtimeConversationItemWithReference,
    mcp_approval_request: RealtimeMCPApprovalRequest,
    mcp_approval_response: RealtimeMCPApprovalResponse,
    mcp_list_tools: RealtimeMCPListTools,
    mcp_tool_call: RealtimeMCPToolCall,
    raw: std.json.Value,

    pub fn forFunctionCall(value: RealtimeConversationItemFunctionCall) RealtimeConversationItem {
        return .{ .function_call = value };
    }

    pub fn forRaw(value: std.json.Value) RealtimeConversationItem {
        return .{ .raw = value };
    }

    pub fn jsonStringify(self: RealtimeConversationItem, writer: anytype) !void {
        switch (self) {
            .function_call => |value| try writer.write(value),
            .function_call_output => |value| try writer.write(value),
            .message_assistant => |value| try writer.write(value),
            .message_system => |value| try writer.write(value),
            .message_user => |value| try writer.write(value),
            .message_with_reference => |value| try writer.write(value),
            .mcp_approval_request => |value| try writer.write(value),
            .mcp_approval_response => |value| try writer.write(value),
            .mcp_list_tools => |value| try writer.write(value),
            .mcp_tool_call => |value| try writer.write(value),
            .raw => |value| try writer.write(value),
        }
    }

    pub fn jsonParse(allocator: std.mem.Allocator, source: anytype, options: std.json.ParseOptions) !RealtimeConversationItem {
        const parsed = try std.json.Value.jsonParse(allocator, source, options);
        return try jsonParseFromValue(allocator, parsed, options);
    }

    pub fn jsonParseFromValue(
        allocator: std.mem.Allocator,
        source: std.json.Value,
        options: std.json.ParseOptions,
    ) !RealtimeConversationItem {
        switch (source) {
            .object => |root| {
                const item_type = root.get("type") orelse return .{ .raw = source };
                if (item_type != .string) return .{ .raw = source };

                if (std.mem.eql(u8, item_type.string, "function_call")) {
                    if (std.json.parseFromValue(
                        RealtimeConversationItemFunctionCall,
                        allocator,
                        source,
                        options,
                    )) |parsed| {
                        defer parsed.deinit();
                        return .{ .function_call = parsed.value };
                    } else |_| {}
                }

                if (std.mem.eql(u8, item_type.string, "function_call_output")) {
                    if (std.json.parseFromValue(
                        RealtimeConversationItemFunctionCallOutput,
                        allocator,
                        source,
                        options,
                    )) |parsed| {
                        defer parsed.deinit();
                        return .{ .function_call_output = parsed.value };
                    } else |_| {}
                }

                if (std.mem.eql(u8, item_type.string, "message")) {
                    const role = root.get("role");
                    if (role) |raw_role| {
                        if (raw_role == .string and std.mem.eql(u8, raw_role.string, "assistant")) {
                            if (std.json.parseFromValue(
                                RealtimeConversationItemMessageAssistant,
                                allocator,
                                source,
                                options,
                            )) |parsed| {
                                defer parsed.deinit();
                                return .{ .message_assistant = parsed.value };
                            } else |_| {}
                        } else if (raw_role == .string and std.mem.eql(u8, raw_role.string, "system")) {
                            if (std.json.parseFromValue(
                                RealtimeConversationItemMessageSystem,
                                allocator,
                                source,
                                options,
                            )) |parsed| {
                                defer parsed.deinit();
                                return .{ .message_system = parsed.value };
                            } else |_| {}
                        } else if (raw_role == .string and std.mem.eql(u8, raw_role.string, "user")) {
                            if (std.json.parseFromValue(
                                RealtimeConversationItemMessageUser,
                                allocator,
                                source,
                                options,
                            )) |parsed| {
                                defer parsed.deinit();
                                return .{ .message_user = parsed.value };
                            } else |_| {}
                        }
                    }

                    if (std.json.parseFromValue(
                        RealtimeConversationItemWithReference,
                        allocator,
                        source,
                        options,
                    )) |parsed| {
                        defer parsed.deinit();
                        return .{ .message_with_reference = parsed.value };
                    } else |_| {}
                }

                if (std.mem.eql(u8, item_type.string, "item_reference")) {
                    if (std.json.parseFromValue(
                        RealtimeConversationItemWithReference,
                        allocator,
                        source,
                        options,
                    )) |parsed| {
                        defer parsed.deinit();
                        return .{ .message_with_reference = parsed.value };
                    } else |_| {}
                }

                if (std.mem.eql(u8, item_type.string, "mcp_approval_request")) {
                    if (std.json.parseFromValue(
                        RealtimeMCPApprovalRequest,
                        allocator,
                        source,
                        options,
                    )) |parsed| {
                        defer parsed.deinit();
                        return .{ .mcp_approval_request = parsed.value };
                    } else |_| {}
                }

                if (std.mem.eql(u8, item_type.string, "mcp_approval_response")) {
                    if (std.json.parseFromValue(
                        RealtimeMCPApprovalResponse,
                        allocator,
                        source,
                        options,
                    )) |parsed| {
                        defer parsed.deinit();
                        return .{ .mcp_approval_response = parsed.value };
                    } else |_| {}
                }

                if (std.mem.eql(u8, item_type.string, "mcp_list_tools")) {
                    if (std.json.parseFromValue(
                        RealtimeMCPListTools,
                        allocator,
                        source,
                        options,
                    )) |parsed| {
                        defer parsed.deinit();
                        return .{ .mcp_list_tools = parsed.value };
                    } else |_| {}
                }

                if (std.mem.eql(u8, item_type.string, "mcp_call")) {
                    if (std.json.parseFromValue(
                        RealtimeMCPToolCall,
                        allocator,
                        source,
                        options,
                    )) |parsed| {
                        defer parsed.deinit();
                        return .{ .mcp_tool_call = parsed.value };
                    } else |_| {}
                }

                return .{ .raw = source };
            },
            .string, .number, .bool, .null, .array => return .{ .raw = source },
        }
    }
};
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
    session: ?RealtimeSession,
};
pub const RealtimeCreateClientSecretResponse = struct {
    value: []const u8,
    expires_at: i64,
    session: RealtimeSession,
};
pub const RealtimeFunctionTool = struct {
    type: ?[]const u8,
    name: ?[]const u8,
    description: ?[]const u8,
    parameters: ?FunctionParameters,
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
    reason: ?[]const u8,
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
    approval_request_id: ?[]const u8,
    output: ?[]const u8,
    _error: ?JsonObject,
};
pub const RealtimeMCPToolExecutionError = struct {
    type: []const u8,
    message: []const u8,
};
pub const RealtimeResponse = struct {
    id: ?[]const u8,
    object: ?[]const u8,
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
    max_output_tokens: ?i64,
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
    tools: ?[]const Tool,
    tool_choice: ?ToolChoiceParam,
    max_output_tokens: ?i64,
    conversation: ?ConversationParam,
    metadata: ?Metadata,
    prompt: ?Prompt,
    input: ?[]const RealtimeConversationItem,
};
pub const RealtimeServerEvent = union(enum) {
    conversation_created: RealtimeServerEventConversationCreated,
    conversation_item_added: RealtimeServerEventConversationItemAdded,
    conversation_item_created: RealtimeServerEventConversationItemCreated,
    conversation_item_deleted: RealtimeServerEventConversationItemDeleted,
    event_error: RealtimeServerEventError,
    response_created: RealtimeServerEventResponseCreated,
    response_done: RealtimeServerEventResponseDone,
    response_output_item_added: RealtimeServerEventResponseOutputItemAdded,
    response_output_item_done: RealtimeServerEventResponseOutputItemDone,
    response_text_delta: RealtimeServerEventResponseTextDelta,
    response_text_done: RealtimeServerEventResponseTextDone,
    session_created: RealtimeServerEventSessionCreated,
    session_updated: RealtimeServerEventSessionUpdated,
    transcription_session_updated: RealtimeServerEventTranscriptionSessionUpdated,
    raw: JsonObject,

    pub fn forRaw(value: JsonObject) RealtimeServerEvent {
        return .{ .raw = value };
    }

    pub fn jsonStringify(self: RealtimeServerEvent, writer: anytype) !void {
        switch (self) {
            .conversation_created => |value| try writer.write(value),
            .conversation_item_added => |value| try writer.write(value),
            .conversation_item_created => |value| try writer.write(value),
            .conversation_item_deleted => |value| try writer.write(value),
            .event_error => |value| try writer.write(value),
            .response_created => |value| try writer.write(value),
            .response_done => |value| try writer.write(value),
            .response_output_item_added => |value| try writer.write(value),
            .response_output_item_done => |value| try writer.write(value),
            .response_text_delta => |value| try writer.write(value),
            .response_text_done => |value| try writer.write(value),
            .session_created => |value| try writer.write(value),
            .session_updated => |value| try writer.write(value),
            .transcription_session_updated => |value| try writer.write(value),
            .raw => |value| try writer.write(value),
        }
    }

    pub fn jsonParse(allocator: std.mem.Allocator, source: anytype, options: std.json.ParseOptions) !RealtimeServerEvent {
        const parsed = try std.json.Value.jsonParse(allocator, source, options);
        return try jsonParseFromValue(allocator, parsed, options);
    }

    pub fn jsonParseFromValue(
        allocator: std.mem.Allocator,
        source: std.json.Value,
        options: std.json.ParseOptions,
    ) !RealtimeServerEvent {
        switch (source) {
            .object => |root| {
                const event_type = root.get("type") orelse return .{ .raw = source };
                if (event_type != .string) return .{ .raw = source };

                if (std.mem.eql(u8, event_type.string, "conversation.created")) {
                    const parsed = std.json.parseFromValue(RealtimeServerEventConversationCreated, allocator, source, options) catch return .{ .raw = source };
                    defer parsed.deinit();
                    return .{ .conversation_created = parsed.value };
                }

                if (std.mem.eql(u8, event_type.string, "conversation.item.added")) {
                    const parsed = std.json.parseFromValue(RealtimeServerEventConversationItemAdded, allocator, source, options) catch return .{ .raw = source };
                    defer parsed.deinit();
                    return .{ .conversation_item_added = parsed.value };
                }

                if (std.mem.eql(u8, event_type.string, "conversation.item.created")) {
                    const parsed = std.json.parseFromValue(RealtimeServerEventConversationItemCreated, allocator, source, options) catch return .{ .raw = source };
                    defer parsed.deinit();
                    return .{ .conversation_item_created = parsed.value };
                }

                if (std.mem.eql(u8, event_type.string, "conversation.item.deleted")) {
                    const parsed = std.json.parseFromValue(RealtimeServerEventConversationItemDeleted, allocator, source, options) catch return .{ .raw = source };
                    defer parsed.deinit();
                    return .{ .conversation_item_deleted = parsed.value };
                }

                if (std.mem.eql(u8, event_type.string, "error")) {
                    const parsed = std.json.parseFromValue(RealtimeServerEventError, allocator, source, options) catch return .{ .raw = source };
                    defer parsed.deinit();
                    return .{ .event_error = parsed.value };
                }

                if (std.mem.eql(u8, event_type.string, "response.created")) {
                    const parsed = std.json.parseFromValue(RealtimeServerEventResponseCreated, allocator, source, options) catch return .{ .raw = source };
                    defer parsed.deinit();
                    return .{ .response_created = parsed.value };
                }

                if (std.mem.eql(u8, event_type.string, "response.done")) {
                    const parsed = std.json.parseFromValue(RealtimeServerEventResponseDone, allocator, source, options) catch return .{ .raw = source };
                    defer parsed.deinit();
                    return .{ .response_done = parsed.value };
                }

                if (std.mem.eql(u8, event_type.string, "response.output_item.added")) {
                    const parsed = std.json.parseFromValue(RealtimeServerEventResponseOutputItemAdded, allocator, source, options) catch return .{ .raw = source };
                    defer parsed.deinit();
                    return .{ .response_output_item_added = parsed.value };
                }

                if (std.mem.eql(u8, event_type.string, "response.output_item.done")) {
                    const parsed = std.json.parseFromValue(RealtimeServerEventResponseOutputItemDone, allocator, source, options) catch return .{ .raw = source };
                    defer parsed.deinit();
                    return .{ .response_output_item_done = parsed.value };
                }

                if (std.mem.eql(u8, event_type.string, "response.text.delta")) {
                    const parsed = std.json.parseFromValue(RealtimeServerEventResponseTextDelta, allocator, source, options) catch return .{ .raw = source };
                    defer parsed.deinit();
                    return .{ .response_text_delta = parsed.value };
                }

                if (std.mem.eql(u8, event_type.string, "response.text.done")) {
                    const parsed = std.json.parseFromValue(RealtimeServerEventResponseTextDone, allocator, source, options) catch return .{ .raw = source };
                    defer parsed.deinit();
                    return .{ .response_text_done = parsed.value };
                }

                if (std.mem.eql(u8, event_type.string, "session.created")) {
                    const parsed = std.json.parseFromValue(RealtimeServerEventSessionCreated, allocator, source, options) catch return .{ .raw = source };
                    defer parsed.deinit();
                    return .{ .session_created = parsed.value };
                }

                if (std.mem.eql(u8, event_type.string, "session.updated")) {
                    const parsed = std.json.parseFromValue(RealtimeServerEventSessionUpdated, allocator, source, options) catch return .{ .raw = source };
                    defer parsed.deinit();
                    return .{ .session_updated = parsed.value };
                }

                if (std.mem.eql(u8, event_type.string, "transcription_session.updated")) {
                    const parsed = std.json.parseFromValue(RealtimeServerEventTranscriptionSessionUpdated, allocator, source, options) catch return .{ .raw = source };
                    defer parsed.deinit();
                    return .{ .transcription_session_updated = parsed.value };
                }

                return .{ .raw = source };
            },
            else => return .{ .raw = source },
        }
    }
};
pub const RealtimeServerEventConversationCreated = struct {
    event_id: []const u8,
    type: []const u8,
    conversation: struct {
        id: ?[]const u8,
        object: ?[]const u8,
    },
};
pub const RealtimeServerEventConversationItemAdded = struct {
    event_id: []const u8,
    type: []const u8,
    previous_item_id: ?[]const u8,
    item: RealtimeConversationItem,
};
pub const RealtimeServerEventConversationItemCreated = struct {
    event_id: []const u8,
    type: []const u8,
    previous_item_id: ?[]const u8,
    item: RealtimeConversationItem,
};
pub const RealtimeServerEventConversationItemDeleted = struct {
    event_id: []const u8,
    type: []const u8,
    item_id: []const u8,
};
pub const RealtimeServerEventConversationItemDone = struct {
    event_id: []const u8,
    type: []const u8,
    previous_item_id: ?[]const u8,
    item: RealtimeConversationItem,
};
pub const RealtimeServerEventConversationItemInputAudioTranscriptionCompleted = struct {
    event_id: []const u8,
    type: []const u8,
    item_id: []const u8,
    content_index: i64,
    transcript: []const u8,
    logprobs: ?[]const LogProbProperties,
    usage: TranscriptTextUsage,
};
pub const RealtimeServerEventConversationItemInputAudioTranscriptionDelta = struct {
    event_id: []const u8,
    type: []const u8,
    item_id: []const u8,
    content_index: ?i64,
    delta: ?[]const u8,
    logprobs: ?[]const LogProbProperties,
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
    type: []const u8,
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
    type: []const u8,
    item: RealtimeConversationItem,
};
pub const RealtimeServerEventConversationItemTruncated = struct {
    event_id: []const u8,
    type: []const u8,
    item_id: []const u8,
    content_index: i64,
    audio_end_ms: i64,
};
pub const RealtimeServerEventError = struct {
    event_id: []const u8,
    type: []const u8,
    _error: struct {
        type: []const u8,
        code: ?[]const u8,
        message: []const u8,
        param: ?[]const u8,
        event_id: ?[]const u8,
    },
};
pub const RealtimeServerEventInputAudioBufferCleared = struct {
    event_id: []const u8,
    type: []const u8,
};
pub const RealtimeServerEventInputAudioBufferCommitted = struct {
    event_id: []const u8,
    type: []const u8,
    previous_item_id: ?[]const u8,
    item_id: []const u8,
};
pub const RealtimeServerEventInputAudioBufferDtmfEventReceived = struct {
    type: []const u8,
    event: []const u8,
    received_at: i64,
};
pub const RealtimeServerEventInputAudioBufferSpeechStarted = struct {
    event_id: []const u8,
    type: []const u8,
    audio_start_ms: i64,
    item_id: []const u8,
};
pub const RealtimeServerEventInputAudioBufferSpeechStopped = struct {
    event_id: []const u8,
    type: []const u8,
    audio_end_ms: i64,
    item_id: []const u8,
};
pub const RealtimeServerEventInputAudioBufferTimeoutTriggered = struct {
    event_id: []const u8,
    type: []const u8,
    audio_start_ms: i64,
    audio_end_ms: i64,
    item_id: []const u8,
};
pub const RealtimeServerEventMCPListToolsCompleted = struct {
    event_id: []const u8,
    type: []const u8,
    item_id: []const u8,
};
pub const RealtimeServerEventMCPListToolsFailed = struct {
    event_id: []const u8,
    type: []const u8,
    item_id: []const u8,
};
pub const RealtimeServerEventMCPListToolsInProgress = struct {
    event_id: []const u8,
    type: []const u8,
    item_id: []const u8,
};
pub const RealtimeServerEventOutputAudioBufferCleared = struct {
    event_id: []const u8,
    type: []const u8,
    response_id: []const u8,
};
pub const RealtimeServerEventOutputAudioBufferStarted = struct {
    event_id: []const u8,
    type: []const u8,
    response_id: []const u8,
};
pub const RealtimeServerEventOutputAudioBufferStopped = struct {
    event_id: []const u8,
    type: []const u8,
    response_id: []const u8,
};
pub const RealtimeServerEventRateLimitsUpdated = struct {
    event_id: []const u8,
    type: []const u8,
    rate_limits: []const struct {
        name: ?[]const u8,
        limit: ?i64,
        remaining: ?i64,
        reset_seconds: ?f64,
    },
};
pub const RealtimeServerEventResponseAudioDelta = struct {
    event_id: []const u8,
    type: []const u8,
    response_id: []const u8,
    item_id: []const u8,
    output_index: i64,
    content_index: i64,
    delta: []const u8,
};
pub const RealtimeServerEventResponseAudioDone = struct {
    event_id: []const u8,
    type: []const u8,
    response_id: []const u8,
    item_id: []const u8,
    output_index: i64,
    content_index: i64,
};
pub const RealtimeServerEventResponseAudioTranscriptDelta = struct {
    event_id: []const u8,
    type: []const u8,
    response_id: []const u8,
    item_id: []const u8,
    output_index: i64,
    content_index: i64,
    delta: []const u8,
};
pub const RealtimeServerEventResponseAudioTranscriptDone = struct {
    event_id: []const u8,
    type: []const u8,
    response_id: []const u8,
    item_id: []const u8,
    output_index: i64,
    content_index: i64,
    transcript: []const u8,
};
pub const RealtimeServerEventResponseContentPartAdded = struct {
    event_id: []const u8,
    type: []const u8,
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
    type: []const u8,
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
    type: []const u8,
    response: RealtimeResponse,
};
pub const RealtimeServerEventResponseDone = struct {
    event_id: []const u8,
    type: []const u8,
    response: RealtimeResponse,
};
pub const RealtimeServerEventResponseFunctionCallArgumentsDelta = struct {
    event_id: []const u8,
    type: []const u8,
    response_id: []const u8,
    item_id: []const u8,
    output_index: i64,
    call_id: []const u8,
    delta: []const u8,
};
pub const RealtimeServerEventResponseFunctionCallArgumentsDone = struct {
    event_id: []const u8,
    type: []const u8,
    response_id: []const u8,
    item_id: []const u8,
    output_index: i64,
    call_id: []const u8,
    arguments: []const u8,
};
pub const RealtimeServerEventResponseMCPCallArgumentsDelta = struct {
    event_id: []const u8,
    type: []const u8,
    response_id: []const u8,
    item_id: []const u8,
    output_index: i64,
    delta: []const u8,
    obfuscation: ?RealtimeObfuscation,
};
pub const RealtimeServerEventResponseMCPCallArgumentsDone = struct {
    event_id: []const u8,
    type: []const u8,
    response_id: []const u8,
    item_id: []const u8,
    output_index: i64,
    arguments: []const u8,
};
pub const RealtimeServerEventResponseMCPCallCompleted = struct {
    event_id: []const u8,
    type: []const u8,
    output_index: i64,
    item_id: []const u8,
};
pub const RealtimeServerEventResponseMCPCallFailed = struct {
    event_id: []const u8,
    type: []const u8,
    output_index: i64,
    item_id: []const u8,
};
pub const RealtimeServerEventResponseMCPCallInProgress = struct {
    event_id: []const u8,
    type: []const u8,
    output_index: i64,
    item_id: []const u8,
};
pub const RealtimeServerEventResponseOutputItemAdded = struct {
    event_id: []const u8,
    type: []const u8,
    response_id: []const u8,
    output_index: i64,
    item: RealtimeConversationItem,
};
pub const RealtimeServerEventResponseOutputItemDone = struct {
    event_id: []const u8,
    type: []const u8,
    response_id: []const u8,
    output_index: i64,
    item: RealtimeConversationItem,
};
pub const RealtimeServerEventResponseTextDelta = struct {
    event_id: []const u8,
    type: []const u8,
    response_id: []const u8,
    item_id: []const u8,
    output_index: i64,
    content_index: i64,
    delta: []const u8,
};
pub const RealtimeServerEventResponseTextDone = struct {
    event_id: []const u8,
    type: []const u8,
    response_id: []const u8,
    item_id: []const u8,
    output_index: i64,
    content_index: i64,
    text: []const u8,
};
pub const RealtimeServerEventSessionCreated = struct {
    event_id: []const u8,
    type: []const u8,
    session: RealtimeSession,
};
pub const RealtimeServerEventSessionUpdated = struct {
    event_id: []const u8,
    type: []const u8,
    session: RealtimeSession,
};
pub const RealtimeServerEventTranscriptionSessionUpdated = struct {
    event_id: []const u8,
    type: []const u8,
    session: RealtimeTranscriptionSessionCreateResponse,
};
pub const RealtimeSession = struct {
    id: ?[]const u8,
    object: ?[]const u8,
    modalities: ?[]const []const u8,
    model: ?[]const u8,
    instructions: ?[]const u8,
    voice: ?VoiceIdsShared,
    input_audio_format: ?[]const u8,
    output_audio_format: ?[]const u8,
    input_audio_transcription: ?AudioTranscription,
    turn_detection: ?RealtimeTurnDetection,
    input_audio_noise_reduction: ?struct {
        type: ?NoiseReductionType,
    },
    speed: ?f64,
    tracing: ?WorkflowTracingParam,
    tools: ?[]const RealtimeFunctionTool,
    tool_choice: ?[]const u8,
    temperature: ?f64,
    max_response_output_tokens: ?i64,
    expires_at: ?i64,
    prompt: ?Prompt,
    include: ?[]const []const u8,
};
pub const RealtimeSessionCreateRequest = struct {
    client_secret: struct {
        value: []const u8,
        expires_at: i64,
    },
    modalities: ?[]const []const u8,
    instructions: ?[]const u8,
    voice: ?VoiceIdsShared,
    input_audio_format: ?[]const u8,
    output_audio_format: ?[]const u8,
    input_audio_transcription: ?struct {
        model: ?[]const u8,
    },
    speed: ?f64,
    tracing: ?WorkflowTracingParam,
    turn_detection: ?struct {
        type: ?[]const u8,
        threshold: ?f64,
        prefix_padding_ms: ?i64,
        silence_duration_ms: ?i64,
    },
    tools: ?[]const RealtimeFunctionTool,
    tool_choice: ?[]const u8,
    temperature: ?f64,
    max_response_output_tokens: ?i64,
    truncation: ?RealtimeTruncation,
    prompt: ?Prompt,
};
pub const RealtimeSessionCreateRequestGA = struct {
    type: []const u8,
    output_modalities: ?[]const []const u8,
    model: ?[]const u8,
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
    tracing: ?WorkflowTracingParam,
    tools: ?[]const Tool,
    tool_choice: ?ToolChoiceParam,
    max_output_tokens: ?i64,
    truncation: ?RealtimeTruncation,
    prompt: ?Prompt,
};
pub const RealtimeSessionCreateResponse = struct {
    id: ?[]const u8,
    object: ?[]const u8,
    expires_at: ?i64,
    include: ?[]const []const u8,
    model: ?[]const u8,
    output_modalities: ?[]const []const u8,
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
    tracing: ?WorkflowTracingParam,
    turn_detection: ?struct {
        type: ?[]const u8,
        threshold: ?f64,
        prefix_padding_ms: ?i64,
        silence_duration_ms: ?i64,
    },
    tools: ?[]const RealtimeFunctionTool,
    tool_choice: ?[]const u8,
    max_output_tokens: ?i64,
};
pub const RealtimeSessionCreateResponseGA = struct {
    client_secret: struct {
        value: []const u8,
        expires_at: i64,
    },
    type: []const u8,
    output_modalities: ?[]const []const u8,
    model: ?[]const u8,
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
    tracing: ?WorkflowTracingParam,
    tools: ?[]const Tool,
    tool_choice: ?ToolChoiceParam,
    max_output_tokens: ?i64,
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
    modalities: ?[]const []const u8,
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
pub const RealtimeTruncation = union(enum) {
    mode: []const u8,
    config: TruncationObject,
    raw: JsonObject,

    pub fn forMode(value: []const u8) RealtimeTruncation {
        return .{ .mode = value };
    }

    pub fn forConfig(value: TruncationObject) RealtimeTruncation {
        return .{ .config = value };
    }

    pub fn forRaw(value: JsonObject) RealtimeTruncation {
        return .{ .raw = value };
    }

    pub fn jsonStringify(self: RealtimeTruncation, writer: anytype) !void {
        switch (self) {
            .mode => |value| try writer.write(value),
            .config => |value| try writer.write(value),
            .raw => |value| try writer.write(value),
        }
    }

    pub fn jsonParse(allocator: std.mem.Allocator, source: anytype, options: std.json.ParseOptions) !RealtimeTruncation {
        const parsed = try std.json.Value.jsonParse(allocator, source, options);
        return jsonParseFromValue(allocator, parsed, options);
    }

    pub fn jsonParseFromValue(
        allocator: std.mem.Allocator,
        source: std.json.Value,
        options: std.json.ParseOptions,
    ) !RealtimeTruncation {
        switch (source) {
            .string => return .{ .mode = source.string },
            .object => {
                const parsed = std.json.parseFromValue(TruncationObject, allocator, source, options) catch return .{ .raw = source };
                defer parsed.deinit();
                return .{ .config = parsed.value };
            },
            else => return .{ .raw = source },
        }
    }
};
pub const RealtimeTurnDetection = struct {
    type: ?[]const u8,
    threshold: ?f64,
    prefix_padding_ms: ?i64,
    silence_duration_ms: ?i64,
};
pub const Reasoning = struct {
    effort: ?ReasoningEffort,
    summary: ?[]const u8,
    generate_summary: ?[]const u8,
};
pub const ReasoningEffort = []const u8;
pub const ReasoningItem = struct {
    type: []const u8,
    id: []const u8,
    encrypted_content: ?JsonObject,
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
pub const ResponseOutput = union(enum) {
    item: OutputItem,
    items: []const OutputItem,
    raw: std.json.Value,

    pub fn forItem(value: OutputItem) ResponseOutput {
        return .{ .item = value };
    }

    pub fn forItems(value: []const OutputItem) ResponseOutput {
        return .{ .items = value };
    }

    pub fn forRaw(value: std.json.Value) ResponseOutput {
        return .{ .raw = value };
    }

    pub fn jsonStringify(self: ResponseOutput, writer: anytype) !void {
        switch (self) {
            .item => |value| {
                try writer.write(value);
            },
            .items => |value| {
                try writer.write(value);
            },
            .raw => |value| {
                try writer.write(value);
            },
        }
    }

    pub fn jsonParse(allocator: std.mem.Allocator, source: anytype, options: std.json.ParseOptions) !ResponseOutput {
        const parsed = try std.json.Value.jsonParse(allocator, source, options);
        defer parsed.deinit();
        return try jsonParseFromValue(allocator, parsed.value, options);
    }

    pub fn jsonParseFromValue(
        allocator: std.mem.Allocator,
        source: std.json.Value,
        options: std.json.ParseOptions,
    ) !ResponseOutput {
        switch (source) {
            .object => {
                if (std.json.parseFromValue(
                    OutputItem,
                    allocator,
                    source,
                    options,
                )) |parsed| {
                    defer parsed.deinit();
                    return .{ .item = parsed.value };
                } else |_| {}
                return .{ .raw = source };
            },
            .array => {
                const parsed = std.json.parseFromValue(
                    []const OutputItem,
                    allocator,
                    source,
                    options,
                ) catch return .{ .raw = source };
                defer parsed.deinit();
                return .{ .items = parsed.value };
            },
            else => return .{ .raw = source },
        }
    }
};
pub const ResponseObject = struct {
    id: ?[]const u8 = null,
    object: ?[]const u8 = null,
    created_at: ?i64 = null,
    status: ?[]const u8 = null,
    model: ?[]const u8 = null,
    @"error": ?ResponseError = null,
    output: ?ResponseOutput = null,
    instructions: ?[]const u8 = null,
    stream: ?bool = null,
    usage: ?ResponseUsage = null,
    metadata: ?Metadata = null,
    finish_reason: ?[]const u8 = null,
};

pub const Response = union(enum) {
    object: ResponseObject,
    raw: std.json.Value,

    pub fn forObject(value: ResponseObject) Response {
        return .{ .object = value };
    }

    pub fn forRaw(value: std.json.Value) Response {
        return .{ .raw = value };
    }

    pub fn jsonStringify(self: Response, writer: anytype) !void {
        switch (self) {
            .object => |value| {
                try writer.write(value);
            },
            .raw => |value| {
                try writer.write(value);
            },
        }
    }

    pub fn jsonParse(allocator: std.mem.Allocator, source: anytype, options: std.json.ParseOptions) !Response {
        const parsed = try std.json.Value.jsonParse(allocator, source, options);
        return jsonParseFromValue(allocator, parsed, options);
    }

    pub fn jsonParseFromValue(
        allocator: std.mem.Allocator,
        source: std.json.Value,
        options: std.json.ParseOptions,
    ) !Response {
        const parsed = std.json.parseFromValue(
            ResponseObject,
            allocator,
            source,
            options,
        ) catch return .{ .raw = source };
        defer parsed.deinit();

        return .{ .object = parsed.value };
    }
};
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
pub const ResponseErrorCode = []const u8;
pub const ResponseError = union(enum) {
    object: struct {
        type: ?[]const u8 = null,
        code: ?ResponseErrorCode = null,
        message: []const u8,
        param: ?[]const u8 = null,
    },
    raw: std.json.Value,

    pub fn forObject(
        error_type: ?[]const u8,
        code: ?ResponseErrorCode,
        message: []const u8,
        param: ?[]const u8,
    ) ResponseError {
        return .{ .object = .{
            .type = error_type,
            .code = code,
            .message = message,
            .param = param,
        } };
    }

    pub fn forRaw(value: std.json.Value) ResponseError {
        return .{ .raw = value };
    }

    pub fn jsonStringify(self: ResponseError, writer: anytype) !void {
        switch (self) {
            .object => |value| {
                try writer.write(value);
            },
            .raw => |value| {
                try writer.write(value);
            },
        }
    }

    pub fn jsonParse(allocator: std.mem.Allocator, source: anytype, options: std.json.ParseOptions) !ResponseError {
        const parsed = try std.json.Value.jsonParse(allocator, source, options);
        return jsonParseFromValue(allocator, parsed, options);
    }

    pub fn jsonParseFromValue(
        allocator: std.mem.Allocator,
        source: std.json.Value,
        options: std.json.ParseOptions,
    ) !ResponseError {
        const parsed = std.json.parseFromValue(
            struct {
                type: ?[]const u8 = null,
                code: ?ResponseErrorCode = null,
                message: ?[]const u8 = null,
                param: ?[]const u8 = null,
            },
            allocator,
            source,
            options,
        ) catch return .{ .raw = source };
        defer parsed.deinit();

        if (parsed.value.message) |message| {
            return .{
                .object = .{
                    .type = parsed.value.type,
                    .code = parsed.value.code,
                    .message = message,
                    .param = parsed.value.param,
                },
            };
        }
        return .{ .raw = source };
    }
};
pub const ResponseErrorEvent = struct {
    type: []const u8,
    code: ?[]const u8,
    message: []const u8,
    param: ?[]const u8,
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
        strict: ?bool,
    },
};
pub const ResponseFormatJsonSchemaSchema = JsonObject;
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
    object: []const u8,
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
pub const ResponseModalities = []const []const u8;
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
    annotations: ?[]const Annotation = null,
};
pub const ResponseOutputTextAnnotationAddedEvent = struct {
    type: []const u8,
    item_id: []const u8,
    output_index: i64,
    content_index: i64,
    annotation_index: i64,
    sequence_number: i64,
    annotation: Annotation,
};
pub const ResponsePromptVariables = JsonObject;
pub const ResponseProperties = struct {
    previous_response_id: ?[]const u8,
    model: ?ModelIdsResponses,
    reasoning: ?Reasoning,
    background: ?bool,
    max_output_tokens: ?i64,
    max_tool_calls: ?i64,
    text: ?ResponseTextParam,
    tools: ?ToolsArray,
    tool_choice: ?ToolChoiceParam,
    prompt: ?Prompt,
    truncation: ?[]const u8,
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
pub const ResponseStreamEventAudioDelta = struct {
    type: []const u8,
    sequence_number: i64,
    delta: []const u8,
};
pub const ResponseStreamEventAudioDone = struct {
    type: []const u8,
    sequence_number: i64,
};
pub const ResponseStreamEventAudioTranscriptDelta = struct {
    type: []const u8,
    delta: []const u8,
    sequence_number: i64,
};
pub const ResponseStreamEventAudioTranscriptDone = struct {
    type: []const u8,
    sequence_number: i64,
};
pub const ResponseStreamEventCodeInterpreterCallCodeDelta = struct {
    type: []const u8,
    output_index: i64,
    item_id: []const u8,
    delta: []const u8,
    sequence_number: i64,
};
pub const ResponseStreamEventCodeInterpreterCallCodeDone = struct {
    type: []const u8,
    output_index: i64,
    item_id: []const u8,
    code: []const u8,
    sequence_number: i64,
};
pub const ResponseStreamEventCodeInterpreterCallCompleted = struct {
    type: []const u8,
    output_index: i64,
    item_id: []const u8,
    sequence_number: i64,
};
pub const ResponseStreamEventCodeInterpreterCallInProgress = struct {
    type: []const u8,
    output_index: i64,
    item_id: []const u8,
    sequence_number: i64,
};
pub const ResponseStreamEventCodeInterpreterCallInterpreting = struct {
    type: []const u8,
    output_index: i64,
    item_id: []const u8,
    sequence_number: i64,
};
pub const ResponseStreamEventCompleted = struct {
    type: []const u8,
    response: Response,
    sequence_number: i64,
};
pub const ResponseStreamEventContentPartAdded = struct {
    type: []const u8,
    item_id: []const u8,
    output_index: i64,
    content_index: i64,
    part: OutputContent,
    sequence_number: i64,
};
pub const ResponseStreamEventContentPartDone = struct {
    type: []const u8,
    item_id: []const u8,
    output_index: i64,
    content_index: i64,
    sequence_number: i64,
    part: OutputContent,
};
pub const ResponseStreamEventCreated = struct {
    type: []const u8,
    response: Response,
    sequence_number: i64,
};
pub const ResponseStreamEventCustomToolCallInputDelta = struct {
    type: []const u8,
    sequence_number: i64,
    output_index: i64,
    item_id: []const u8,
    delta: []const u8,
};
pub const ResponseStreamEventCustomToolCallInputDone = struct {
    type: []const u8,
    sequence_number: i64,
    output_index: i64,
    item_id: []const u8,
    input: []const u8,
};
pub const ResponseStreamEventError = struct {
    type: []const u8,
    code: ?[]const u8,
    message: []const u8,
    param: ?[]const u8,
    sequence_number: i64,
};
pub const ResponseStreamEventFailed = struct {
    type: []const u8,
    sequence_number: i64,
    response: Response,
};
pub const ResponseStreamEventFileSearchCallCompleted = struct {
    type: []const u8,
    output_index: i64,
    item_id: []const u8,
    sequence_number: i64,
};
pub const ResponseStreamEventFileSearchCallInProgress = struct {
    type: []const u8,
    output_index: i64,
    item_id: []const u8,
    sequence_number: i64,
};
pub const ResponseStreamEventFileSearchCallSearching = struct {
    type: []const u8,
    output_index: i64,
    item_id: []const u8,
    sequence_number: i64,
};
pub const ResponseStreamEventFunctionCallArgumentsDelta = struct {
    type: []const u8,
    item_id: []const u8,
    output_index: i64,
    sequence_number: i64,
    delta: []const u8,
};
pub const ResponseStreamEventFunctionCallArgumentsDone = struct {
    type: []const u8,
    item_id: []const u8,
    name: []const u8,
    output_index: i64,
    sequence_number: i64,
    arguments: []const u8,
};
pub const ResponseStreamEventImageGenCallCompleted = struct {
    type: []const u8,
    output_index: i64,
    sequence_number: i64,
    item_id: []const u8,
};
pub const ResponseStreamEventImageGenCallGenerating = struct {
    type: []const u8,
    output_index: i64,
    item_id: []const u8,
    sequence_number: i64,
};
pub const ResponseStreamEventImageGenCallInProgress = struct {
    type: []const u8,
    output_index: i64,
    item_id: []const u8,
    sequence_number: i64,
};
pub const ResponseStreamEventImageGenCallPartialImage = struct {
    type: []const u8,
    output_index: i64,
    item_id: []const u8,
    sequence_number: i64,
    partial_image_index: i64,
    partial_image_b64: []const u8,
};
pub const ResponseStreamEventInProgress = struct {
    type: []const u8,
    response: Response,
    sequence_number: i64,
};
pub const ResponseStreamEventIncomplete = struct {
    type: []const u8,
    response: Response,
    sequence_number: i64,
};
pub const ResponseStreamEventMCPCallArgumentsDelta = struct {
    type: []const u8,
    output_index: i64,
    item_id: []const u8,
    delta: []const u8,
    sequence_number: i64,
};
pub const ResponseStreamEventMCPCallArgumentsDone = struct {
    type: []const u8,
    output_index: i64,
    item_id: []const u8,
    arguments: []const u8,
    sequence_number: i64,
};
pub const ResponseStreamEventMCPCallCompleted = struct {
    type: []const u8,
    item_id: []const u8,
    output_index: i64,
    sequence_number: i64,
};
pub const ResponseStreamEventMCPCallFailed = struct {
    type: []const u8,
    item_id: []const u8,
    output_index: i64,
    sequence_number: i64,
};
pub const ResponseStreamEventMCPCallInProgress = struct {
    type: []const u8,
    output_index: i64,
    item_id: []const u8,
    sequence_number: i64,
};
pub const ResponseStreamEventMCPListToolsCompleted = struct {
    type: []const u8,
    item_id: []const u8,
    output_index: i64,
    sequence_number: i64,
};
pub const ResponseStreamEventMCPListToolsFailed = struct {
    type: []const u8,
    item_id: []const u8,
    output_index: i64,
    sequence_number: i64,
};
pub const ResponseStreamEventMCPListToolsInProgress = struct {
    type: []const u8,
    item_id: []const u8,
    output_index: i64,
    sequence_number: i64,
};
pub const ResponseStreamEventOutputItemAdded = struct {
    type: []const u8,
    output_index: i64,
    sequence_number: i64,
    item: OutputItem,
};
pub const ResponseStreamEventOutputItemDone = struct {
    type: []const u8,
    output_index: i64,
    sequence_number: i64,
    item: OutputItem,
};
pub const ResponseStreamEventOutputTextAnnotationAdded = struct {
    type: []const u8,
    item_id: []const u8,
    output_index: i64,
    content_index: i64,
    annotation_index: i64,
    sequence_number: i64,
    annotation: Annotation,
};
pub const ResponseStreamEventQueued = struct {
    type: []const u8,
    response: Response,
    sequence_number: i64,
};
pub const ResponseStreamEventReasoningSummaryPartAdded = struct {
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
pub const ResponseStreamEventReasoningSummaryPartDone = struct {
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
pub const ResponseStreamEventReasoningSummaryTextDelta = struct {
    type: []const u8,
    item_id: []const u8,
    output_index: i64,
    summary_index: i64,
    delta: []const u8,
    sequence_number: i64,
};
pub const ResponseStreamEventReasoningSummaryTextDone = struct {
    type: []const u8,
    item_id: []const u8,
    output_index: i64,
    summary_index: i64,
    text: []const u8,
    sequence_number: i64,
};
pub const ResponseStreamEventReasoningTextDelta = struct {
    type: []const u8,
    item_id: []const u8,
    output_index: i64,
    content_index: i64,
    delta: []const u8,
    sequence_number: i64,
};
pub const ResponseStreamEventReasoningTextDone = struct {
    type: []const u8,
    item_id: []const u8,
    output_index: i64,
    content_index: i64,
    text: []const u8,
    sequence_number: i64,
};
pub const ResponseStreamEventRefusalDelta = struct {
    type: []const u8,
    item_id: []const u8,
    output_index: i64,
    content_index: i64,
    delta: []const u8,
    sequence_number: i64,
};
pub const ResponseStreamEventRefusalDone = struct {
    type: []const u8,
    item_id: []const u8,
    output_index: i64,
    content_index: i64,
    refusal: []const u8,
    sequence_number: i64,
};
pub const ResponseStreamEventTextDelta = struct {
    type: []const u8,
    item_id: []const u8,
    output_index: i64,
    content_index: i64,
    delta: []const u8,
    sequence_number: i64,
    logprobs: []const ResponseLogProb,
};
pub const ResponseStreamEventTextDone = struct {
    type: []const u8,
    item_id: []const u8,
    output_index: i64,
    content_index: i64,
    text: []const u8,
    sequence_number: i64,
    logprobs: []const ResponseLogProb,
};
pub const ResponseStreamEventWebSearchCallCompleted = struct {
    type: []const u8,
    output_index: i64,
    item_id: []const u8,
    sequence_number: i64,
};
pub const ResponseStreamEventWebSearchCallInProgress = struct {
    type: []const u8,
    output_index: i64,
    item_id: []const u8,
    sequence_number: i64,
};
pub const ResponseStreamEventWebSearchCallSearching = struct {
    type: []const u8,
    output_index: i64,
    item_id: []const u8,
    sequence_number: i64,
};
pub const ResponseStreamEvent = union(enum) {
    audio_delta: ResponseStreamEventAudioDelta,
    audio_done: ResponseStreamEventAudioDone,
    audio_transcript_delta: ResponseStreamEventAudioTranscriptDelta,
    audio_transcript_done: ResponseStreamEventAudioTranscriptDone,
    code_interpreter_call_code_delta: ResponseStreamEventCodeInterpreterCallCodeDelta,
    code_interpreter_call_code_done: ResponseStreamEventCodeInterpreterCallCodeDone,
    code_interpreter_call_completed: ResponseStreamEventCodeInterpreterCallCompleted,
    code_interpreter_call_in_progress: ResponseStreamEventCodeInterpreterCallInProgress,
    code_interpreter_call_interpreting: ResponseStreamEventCodeInterpreterCallInterpreting,
    completed: ResponseStreamEventCompleted,
    content_part_added: ResponseStreamEventContentPartAdded,
    content_part_done: ResponseStreamEventContentPartDone,
    created: ResponseStreamEventCreated,
    custom_tool_call_input_delta: ResponseStreamEventCustomToolCallInputDelta,
    custom_tool_call_input_done: ResponseStreamEventCustomToolCallInputDone,
    err: ResponseStreamEventError,
    failed: ResponseStreamEventFailed,
    file_search_call_completed: ResponseStreamEventFileSearchCallCompleted,
    file_search_call_in_progress: ResponseStreamEventFileSearchCallInProgress,
    file_search_call_searching: ResponseStreamEventFileSearchCallSearching,
    function_call_arguments_delta: ResponseStreamEventFunctionCallArgumentsDelta,
    function_call_arguments_done: ResponseStreamEventFunctionCallArgumentsDone,
    image_gen_call_completed: ResponseStreamEventImageGenCallCompleted,
    image_gen_call_generating: ResponseStreamEventImageGenCallGenerating,
    image_gen_call_in_progress: ResponseStreamEventImageGenCallInProgress,
    image_gen_call_partial_image: ResponseStreamEventImageGenCallPartialImage,
    in_progress: ResponseStreamEventInProgress,
    incomplete: ResponseStreamEventIncomplete,
    mcp_call_arguments_delta: ResponseStreamEventMCPCallArgumentsDelta,
    mcp_call_arguments_done: ResponseStreamEventMCPCallArgumentsDone,
    mcp_call_completed: ResponseStreamEventMCPCallCompleted,
    mcp_call_failed: ResponseStreamEventMCPCallFailed,
    mcp_call_in_progress: ResponseStreamEventMCPCallInProgress,
    mcp_list_tools_completed: ResponseStreamEventMCPListToolsCompleted,
    mcp_list_tools_failed: ResponseStreamEventMCPListToolsFailed,
    mcp_list_tools_in_progress: ResponseStreamEventMCPListToolsInProgress,
    output_item_added: ResponseStreamEventOutputItemAdded,
    output_item_done: ResponseStreamEventOutputItemDone,
    output_text_annotation_added: ResponseStreamEventOutputTextAnnotationAdded,
    queued: ResponseStreamEventQueued,
    reasoning_summary_part_added: ResponseStreamEventReasoningSummaryPartAdded,
    reasoning_summary_part_done: ResponseStreamEventReasoningSummaryPartDone,
    reasoning_summary_text_delta: ResponseStreamEventReasoningSummaryTextDelta,
    reasoning_summary_text_done: ResponseStreamEventReasoningSummaryTextDone,
    reasoning_text_delta: ResponseStreamEventReasoningTextDelta,
    reasoning_text_done: ResponseStreamEventReasoningTextDone,
    refusal_delta: ResponseStreamEventRefusalDelta,
    refusal_done: ResponseStreamEventRefusalDone,
    text_delta: ResponseStreamEventTextDelta,
    text_done: ResponseStreamEventTextDone,
    web_search_call_completed: ResponseStreamEventWebSearchCallCompleted,
    web_search_call_in_progress: ResponseStreamEventWebSearchCallInProgress,
    web_search_call_searching: ResponseStreamEventWebSearchCallSearching,
    raw: std.json.Value,

    pub fn forAudioDelta(value: ResponseStreamEventAudioDelta) ResponseStreamEvent {
        return .{ .audio_delta = value };
    }

    pub fn forAudioDone(value: ResponseStreamEventAudioDone) ResponseStreamEvent {
        return .{ .audio_done = value };
    }

    pub fn forAudioTranscriptDelta(value: ResponseStreamEventAudioTranscriptDelta) ResponseStreamEvent {
        return .{ .audio_transcript_delta = value };
    }

    pub fn forAudioTranscriptDone(value: ResponseStreamEventAudioTranscriptDone) ResponseStreamEvent {
        return .{ .audio_transcript_done = value };
    }

    pub fn forCodeInterpreterCallCodeDelta(value: ResponseStreamEventCodeInterpreterCallCodeDelta) ResponseStreamEvent {
        return .{ .code_interpreter_call_code_delta = value };
    }

    pub fn forCodeInterpreterCallCodeDone(value: ResponseStreamEventCodeInterpreterCallCodeDone) ResponseStreamEvent {
        return .{ .code_interpreter_call_code_done = value };
    }

    pub fn forCodeInterpreterCallCompleted(value: ResponseStreamEventCodeInterpreterCallCompleted) ResponseStreamEvent {
        return .{ .code_interpreter_call_completed = value };
    }

    pub fn forCodeInterpreterCallInProgress(value: ResponseStreamEventCodeInterpreterCallInProgress) ResponseStreamEvent {
        return .{ .code_interpreter_call_in_progress = value };
    }

    pub fn forCodeInterpreterCallInterpreting(value: ResponseStreamEventCodeInterpreterCallInterpreting) ResponseStreamEvent {
        return .{ .code_interpreter_call_interpreting = value };
    }

    pub fn forCompleted(value: ResponseStreamEventCompleted) ResponseStreamEvent {
        return .{ .completed = value };
    }

    pub fn forContentPartAdded(value: ResponseStreamEventContentPartAdded) ResponseStreamEvent {
        return .{ .content_part_added = value };
    }

    pub fn forContentPartDone(value: ResponseStreamEventContentPartDone) ResponseStreamEvent {
        return .{ .content_part_done = value };
    }

    pub fn forCreated(value: ResponseStreamEventCreated) ResponseStreamEvent {
        return .{ .created = value };
    }

    pub fn forCustomToolCallInputDelta(value: ResponseStreamEventCustomToolCallInputDelta) ResponseStreamEvent {
        return .{ .custom_tool_call_input_delta = value };
    }

    pub fn forCustomToolCallInputDone(value: ResponseStreamEventCustomToolCallInputDone) ResponseStreamEvent {
        return .{ .custom_tool_call_input_done = value };
    }

    pub fn forError(value: ResponseStreamEventError) ResponseStreamEvent {
        return .{ .err = value };
    }

    pub fn forFailed(value: ResponseStreamEventFailed) ResponseStreamEvent {
        return .{ .failed = value };
    }

    pub fn forFileSearchCallCompleted(value: ResponseStreamEventFileSearchCallCompleted) ResponseStreamEvent {
        return .{ .file_search_call_completed = value };
    }

    pub fn forFileSearchCallInProgress(value: ResponseStreamEventFileSearchCallInProgress) ResponseStreamEvent {
        return .{ .file_search_call_in_progress = value };
    }

    pub fn forFileSearchCallSearching(value: ResponseStreamEventFileSearchCallSearching) ResponseStreamEvent {
        return .{ .file_search_call_searching = value };
    }

    pub fn forFunctionCallArgumentsDelta(value: ResponseStreamEventFunctionCallArgumentsDelta) ResponseStreamEvent {
        return .{ .function_call_arguments_delta = value };
    }

    pub fn forFunctionCallArgumentsDone(value: ResponseStreamEventFunctionCallArgumentsDone) ResponseStreamEvent {
        return .{ .function_call_arguments_done = value };
    }

    pub fn forImageGenCallCompleted(value: ResponseStreamEventImageGenCallCompleted) ResponseStreamEvent {
        return .{ .image_gen_call_completed = value };
    }

    pub fn forImageGenCallGenerating(value: ResponseStreamEventImageGenCallGenerating) ResponseStreamEvent {
        return .{ .image_gen_call_generating = value };
    }

    pub fn forImageGenCallInProgress(value: ResponseStreamEventImageGenCallInProgress) ResponseStreamEvent {
        return .{ .image_gen_call_in_progress = value };
    }

    pub fn forImageGenCallPartialImage(value: ResponseStreamEventImageGenCallPartialImage) ResponseStreamEvent {
        return .{ .image_gen_call_partial_image = value };
    }

    pub fn forInProgress(value: ResponseStreamEventInProgress) ResponseStreamEvent {
        return .{ .in_progress = value };
    }

    pub fn forIncomplete(value: ResponseStreamEventIncomplete) ResponseStreamEvent {
        return .{ .incomplete = value };
    }

    pub fn forMCPCallArgumentsDelta(value: ResponseStreamEventMCPCallArgumentsDelta) ResponseStreamEvent {
        return .{ .mcp_call_arguments_delta = value };
    }

    pub fn forMCPCallArgumentsDone(value: ResponseStreamEventMCPCallArgumentsDone) ResponseStreamEvent {
        return .{ .mcp_call_arguments_done = value };
    }

    pub fn forMCPCallCompleted(value: ResponseStreamEventMCPCallCompleted) ResponseStreamEvent {
        return .{ .mcp_call_completed = value };
    }

    pub fn forMCPCallFailed(value: ResponseStreamEventMCPCallFailed) ResponseStreamEvent {
        return .{ .mcp_call_failed = value };
    }

    pub fn forMCPCallInProgress(value: ResponseStreamEventMCPCallInProgress) ResponseStreamEvent {
        return .{ .mcp_call_in_progress = value };
    }

    pub fn forMCPListToolsCompleted(value: ResponseStreamEventMCPListToolsCompleted) ResponseStreamEvent {
        return .{ .mcp_list_tools_completed = value };
    }

    pub fn forMCPListToolsFailed(value: ResponseStreamEventMCPListToolsFailed) ResponseStreamEvent {
        return .{ .mcp_list_tools_failed = value };
    }

    pub fn forMCPListToolsInProgress(value: ResponseStreamEventMCPListToolsInProgress) ResponseStreamEvent {
        return .{ .mcp_list_tools_in_progress = value };
    }

    pub fn forOutputItemAdded(value: ResponseStreamEventOutputItemAdded) ResponseStreamEvent {
        return .{ .output_item_added = value };
    }

    pub fn forOutputItemDone(value: ResponseStreamEventOutputItemDone) ResponseStreamEvent {
        return .{ .output_item_done = value };
    }

    pub fn forOutputTextAnnotationAdded(value: ResponseStreamEventOutputTextAnnotationAdded) ResponseStreamEvent {
        return .{ .output_text_annotation_added = value };
    }

    pub fn forQueued(value: ResponseStreamEventQueued) ResponseStreamEvent {
        return .{ .queued = value };
    }

    pub fn forReasoningSummaryPartAdded(value: ResponseStreamEventReasoningSummaryPartAdded) ResponseStreamEvent {
        return .{ .reasoning_summary_part_added = value };
    }

    pub fn forReasoningSummaryPartDone(value: ResponseStreamEventReasoningSummaryPartDone) ResponseStreamEvent {
        return .{ .reasoning_summary_part_done = value };
    }

    pub fn forReasoningSummaryTextDelta(value: ResponseStreamEventReasoningSummaryTextDelta) ResponseStreamEvent {
        return .{ .reasoning_summary_text_delta = value };
    }

    pub fn forReasoningSummaryTextDone(value: ResponseStreamEventReasoningSummaryTextDone) ResponseStreamEvent {
        return .{ .reasoning_summary_text_done = value };
    }

    pub fn forReasoningTextDelta(value: ResponseStreamEventReasoningTextDelta) ResponseStreamEvent {
        return .{ .reasoning_text_delta = value };
    }

    pub fn forReasoningTextDone(value: ResponseStreamEventReasoningTextDone) ResponseStreamEvent {
        return .{ .reasoning_text_done = value };
    }

    pub fn forRefusalDelta(value: ResponseStreamEventRefusalDelta) ResponseStreamEvent {
        return .{ .refusal_delta = value };
    }

    pub fn forRefusalDone(value: ResponseStreamEventRefusalDone) ResponseStreamEvent {
        return .{ .refusal_done = value };
    }

    pub fn forTextDelta(value: ResponseStreamEventTextDelta) ResponseStreamEvent {
        return .{ .text_delta = value };
    }

    pub fn forTextDone(value: ResponseStreamEventTextDone) ResponseStreamEvent {
        return .{ .text_done = value };
    }

    pub fn forWebSearchCallCompleted(value: ResponseStreamEventWebSearchCallCompleted) ResponseStreamEvent {
        return .{ .web_search_call_completed = value };
    }

    pub fn forWebSearchCallInProgress(value: ResponseStreamEventWebSearchCallInProgress) ResponseStreamEvent {
        return .{ .web_search_call_in_progress = value };
    }

    pub fn forWebSearchCallSearching(value: ResponseStreamEventWebSearchCallSearching) ResponseStreamEvent {
        return .{ .web_search_call_searching = value };
    }

    pub fn forRaw(value: std.json.Value) ResponseStreamEvent {
        return .{ .raw = value };
    }

    pub fn jsonStringify(self: ResponseStreamEvent, writer: anytype) !void {
        switch (self) {
            .audio_delta => |value| try writer.write(value),
            .audio_done => |value| try writer.write(value),
            .audio_transcript_delta => |value| try writer.write(value),
            .audio_transcript_done => |value| try writer.write(value),
            .code_interpreter_call_code_delta => |value| try writer.write(value),
            .code_interpreter_call_code_done => |value| try writer.write(value),
            .code_interpreter_call_completed => |value| try writer.write(value),
            .code_interpreter_call_in_progress => |value| try writer.write(value),
            .code_interpreter_call_interpreting => |value| try writer.write(value),
            .completed => |value| try writer.write(value),
            .content_part_added => |value| try writer.write(value),
            .content_part_done => |value| try writer.write(value),
            .created => |value| try writer.write(value),
            .custom_tool_call_input_delta => |value| try writer.write(value),
            .custom_tool_call_input_done => |value| try writer.write(value),
            .err => |value| try writer.write(value),
            .failed => |value| try writer.write(value),
            .file_search_call_completed => |value| try writer.write(value),
            .file_search_call_in_progress => |value| try writer.write(value),
            .file_search_call_searching => |value| try writer.write(value),
            .function_call_arguments_delta => |value| try writer.write(value),
            .function_call_arguments_done => |value| try writer.write(value),
            .image_gen_call_completed => |value| try writer.write(value),
            .image_gen_call_generating => |value| try writer.write(value),
            .image_gen_call_in_progress => |value| try writer.write(value),
            .image_gen_call_partial_image => |value| try writer.write(value),
            .in_progress => |value| try writer.write(value),
            .incomplete => |value| try writer.write(value),
            .mcp_call_arguments_delta => |value| try writer.write(value),
            .mcp_call_arguments_done => |value| try writer.write(value),
            .mcp_call_completed => |value| try writer.write(value),
            .mcp_call_failed => |value| try writer.write(value),
            .mcp_call_in_progress => |value| try writer.write(value),
            .mcp_list_tools_completed => |value| try writer.write(value),
            .mcp_list_tools_failed => |value| try writer.write(value),
            .mcp_list_tools_in_progress => |value| try writer.write(value),
            .output_item_added => |value| try writer.write(value),
            .output_item_done => |value| try writer.write(value),
            .output_text_annotation_added => |value| try writer.write(value),
            .queued => |value| try writer.write(value),
            .reasoning_summary_part_added => |value| try writer.write(value),
            .reasoning_summary_part_done => |value| try writer.write(value),
            .reasoning_summary_text_delta => |value| try writer.write(value),
            .reasoning_summary_text_done => |value| try writer.write(value),
            .reasoning_text_delta => |value| try writer.write(value),
            .reasoning_text_done => |value| try writer.write(value),
            .refusal_delta => |value| try writer.write(value),
            .refusal_done => |value| try writer.write(value),
            .text_delta => |value| try writer.write(value),
            .text_done => |value| try writer.write(value),
            .web_search_call_completed => |value| try writer.write(value),
            .web_search_call_in_progress => |value| try writer.write(value),
            .web_search_call_searching => |value| try writer.write(value),
            .raw => |value| try writer.write(value),
        }
    }

    pub fn jsonParse(allocator: std.mem.Allocator, source: anytype, options: std.json.ParseOptions) !ResponseStreamEvent {
        const parsed = try std.json.Value.jsonParse(allocator, source, options);
        return jsonParseFromValue(allocator, parsed, options);
    }

    pub fn jsonParseFromValue(
        allocator: std.mem.Allocator,
        source: std.json.Value,
        options: std.json.ParseOptions,
    ) !ResponseStreamEvent {
        switch (source) {
            .object => |root| {
                const event = root.get("type") orelse return .{ .raw = source };
                if (event != .string) return .{ .raw = source };

                if (std.mem.eql(u8, event.string, "response.audio.delta")) {
                    const parsed = std.json.parseFromValue(
                        ResponseStreamEventAudioDelta,
                        allocator,
                        source,
                        options,
                    ) catch return .{ .raw = source };
                    defer parsed.deinit();
                    return .{ .audio_delta = parsed.value };
                }

                if (std.mem.eql(u8, event.string, "response.audio.done")) {
                    const parsed = std.json.parseFromValue(
                        ResponseStreamEventAudioDone,
                        allocator,
                        source,
                        options,
                    ) catch return .{ .raw = source };
                    defer parsed.deinit();
                    return .{ .audio_done = parsed.value };
                }

                if (std.mem.eql(u8, event.string, "response.audio.transcript.delta")) {
                    const parsed = std.json.parseFromValue(
                        ResponseStreamEventAudioTranscriptDelta,
                        allocator,
                        source,
                        options,
                    ) catch return .{ .raw = source };
                    defer parsed.deinit();
                    return .{ .audio_transcript_delta = parsed.value };
                }

                if (std.mem.eql(u8, event.string, "response.audio.transcript.done")) {
                    const parsed = std.json.parseFromValue(
                        ResponseStreamEventAudioTranscriptDone,
                        allocator,
                        source,
                        options,
                    ) catch return .{ .raw = source };
                    defer parsed.deinit();
                    return .{ .audio_transcript_done = parsed.value };
                }

                if (std.mem.eql(u8, event.string, "response.code_interpreter_call_code.delta")) {
                    const parsed = std.json.parseFromValue(
                        ResponseStreamEventCodeInterpreterCallCodeDelta,
                        allocator,
                        source,
                        options,
                    ) catch return .{ .raw = source };
                    defer parsed.deinit();
                    return .{ .code_interpreter_call_code_delta = parsed.value };
                }

                if (std.mem.eql(u8, event.string, "response.code_interpreter_call_code.done")) {
                    const parsed = std.json.parseFromValue(
                        ResponseStreamEventCodeInterpreterCallCodeDone,
                        allocator,
                        source,
                        options,
                    ) catch return .{ .raw = source };
                    defer parsed.deinit();
                    return .{ .code_interpreter_call_code_done = parsed.value };
                }

                if (std.mem.eql(u8, event.string, "response.code_interpreter_call.completed")) {
                    const parsed = std.json.parseFromValue(
                        ResponseStreamEventCodeInterpreterCallCompleted,
                        allocator,
                        source,
                        options,
                    ) catch return .{ .raw = source };
                    defer parsed.deinit();
                    return .{ .code_interpreter_call_completed = parsed.value };
                }

                if (std.mem.eql(u8, event.string, "response.code_interpreter_call.in_progress")) {
                    const parsed = std.json.parseFromValue(
                        ResponseStreamEventCodeInterpreterCallInProgress,
                        allocator,
                        source,
                        options,
                    ) catch return .{ .raw = source };
                    defer parsed.deinit();
                    return .{ .code_interpreter_call_in_progress = parsed.value };
                }

                if (std.mem.eql(u8, event.string, "response.code_interpreter_call.interpreting")) {
                    const parsed = std.json.parseFromValue(
                        ResponseStreamEventCodeInterpreterCallInterpreting,
                        allocator,
                        source,
                        options,
                    ) catch return .{ .raw = source };
                    defer parsed.deinit();
                    return .{ .code_interpreter_call_interpreting = parsed.value };
                }

                if (std.mem.eql(u8, event.string, "response.completed")) {
                    const parsed = std.json.parseFromValue(
                        ResponseStreamEventCompleted,
                        allocator,
                        source,
                        options,
                    ) catch return .{ .raw = source };
                    defer parsed.deinit();
                    return .{ .completed = parsed.value };
                }

                if (std.mem.eql(u8, event.string, "response.content_part.added")) {
                    const parsed = std.json.parseFromValue(
                        ResponseStreamEventContentPartAdded,
                        allocator,
                        source,
                        options,
                    ) catch return .{ .raw = source };
                    defer parsed.deinit();
                    return .{ .content_part_added = parsed.value };
                }

                if (std.mem.eql(u8, event.string, "response.content_part.done")) {
                    const parsed = std.json.parseFromValue(
                        ResponseStreamEventContentPartDone,
                        allocator,
                        source,
                        options,
                    ) catch return .{ .raw = source };
                    defer parsed.deinit();
                    return .{ .content_part_done = parsed.value };
                }

                if (std.mem.eql(u8, event.string, "response.created")) {
                    const parsed = std.json.parseFromValue(
                        ResponseStreamEventCreated,
                        allocator,
                        source,
                        options,
                    ) catch return .{ .raw = source };
                    defer parsed.deinit();
                    return .{ .created = parsed.value };
                }

                if (std.mem.eql(u8, event.string, "response.custom_tool_call_input.delta")) {
                    const parsed = std.json.parseFromValue(
                        ResponseStreamEventCustomToolCallInputDelta,
                        allocator,
                        source,
                        options,
                    ) catch return .{ .raw = source };
                    defer parsed.deinit();
                    return .{ .custom_tool_call_input_delta = parsed.value };
                }

                if (std.mem.eql(u8, event.string, "response.custom_tool_call_input.done")) {
                    const parsed = std.json.parseFromValue(
                        ResponseStreamEventCustomToolCallInputDone,
                        allocator,
                        source,
                        options,
                    ) catch return .{ .raw = source };
                    defer parsed.deinit();
                    return .{ .custom_tool_call_input_done = parsed.value };
                }

                if (std.mem.eql(u8, event.string, "error")) {
                    const parsed = std.json.parseFromValue(
                        ResponseStreamEventError,
                        allocator,
                        source,
                        options,
                    ) catch return .{ .raw = source };
                    defer parsed.deinit();
                    return .{ .err = parsed.value };
                }

                if (std.mem.eql(u8, event.string, "response.failed")) {
                    const parsed = std.json.parseFromValue(
                        ResponseStreamEventFailed,
                        allocator,
                        source,
                        options,
                    ) catch return .{ .raw = source };
                    defer parsed.deinit();
                    return .{ .failed = parsed.value };
                }

                if (std.mem.eql(u8, event.string, "response.file_search_call.completed")) {
                    const parsed = std.json.parseFromValue(
                        ResponseStreamEventFileSearchCallCompleted,
                        allocator,
                        source,
                        options,
                    ) catch return .{ .raw = source };
                    defer parsed.deinit();
                    return .{ .file_search_call_completed = parsed.value };
                }

                if (std.mem.eql(u8, event.string, "response.file_search_call.in_progress")) {
                    const parsed = std.json.parseFromValue(
                        ResponseStreamEventFileSearchCallInProgress,
                        allocator,
                        source,
                        options,
                    ) catch return .{ .raw = source };
                    defer parsed.deinit();
                    return .{ .file_search_call_in_progress = parsed.value };
                }

                if (std.mem.eql(u8, event.string, "response.file_search_call.searching")) {
                    const parsed = std.json.parseFromValue(
                        ResponseStreamEventFileSearchCallSearching,
                        allocator,
                        source,
                        options,
                    ) catch return .{ .raw = source };
                    defer parsed.deinit();
                    return .{ .file_search_call_searching = parsed.value };
                }

                if (std.mem.eql(u8, event.string, "response.function_call_arguments.delta")) {
                    const parsed = std.json.parseFromValue(
                        ResponseStreamEventFunctionCallArgumentsDelta,
                        allocator,
                        source,
                        options,
                    ) catch return .{ .raw = source };
                    defer parsed.deinit();
                    return .{ .function_call_arguments_delta = parsed.value };
                }

                if (std.mem.eql(u8, event.string, "response.function_call_arguments.done")) {
                    const parsed = std.json.parseFromValue(
                        ResponseStreamEventFunctionCallArgumentsDone,
                        allocator,
                        source,
                        options,
                    ) catch return .{ .raw = source };
                    defer parsed.deinit();
                    return .{ .function_call_arguments_done = parsed.value };
                }

                if (std.mem.eql(u8, event.string, "response.image_generation_call.completed")) {
                    const parsed = std.json.parseFromValue(
                        ResponseStreamEventImageGenCallCompleted,
                        allocator,
                        source,
                        options,
                    ) catch return .{ .raw = source };
                    defer parsed.deinit();
                    return .{ .image_gen_call_completed = parsed.value };
                }

                if (std.mem.eql(u8, event.string, "response.image_generation_call.generating")) {
                    const parsed = std.json.parseFromValue(
                        ResponseStreamEventImageGenCallGenerating,
                        allocator,
                        source,
                        options,
                    ) catch return .{ .raw = source };
                    defer parsed.deinit();
                    return .{ .image_gen_call_generating = parsed.value };
                }

                if (std.mem.eql(u8, event.string, "response.image_generation_call.in_progress")) {
                    const parsed = std.json.parseFromValue(
                        ResponseStreamEventImageGenCallInProgress,
                        allocator,
                        source,
                        options,
                    ) catch return .{ .raw = source };
                    defer parsed.deinit();
                    return .{ .image_gen_call_in_progress = parsed.value };
                }

                if (std.mem.eql(u8, event.string, "response.image_generation_call.partial_image")) {
                    const parsed = std.json.parseFromValue(
                        ResponseStreamEventImageGenCallPartialImage,
                        allocator,
                        source,
                        options,
                    ) catch return .{ .raw = source };
                    defer parsed.deinit();
                    return .{ .image_gen_call_partial_image = parsed.value };
                }

                if (std.mem.eql(u8, event.string, "response.in_progress")) {
                    const parsed = std.json.parseFromValue(
                        ResponseStreamEventInProgress,
                        allocator,
                        source,
                        options,
                    ) catch return .{ .raw = source };
                    defer parsed.deinit();
                    return .{ .in_progress = parsed.value };
                }

                if (std.mem.eql(u8, event.string, "response.incomplete")) {
                    const parsed = std.json.parseFromValue(
                        ResponseStreamEventIncomplete,
                        allocator,
                        source,
                        options,
                    ) catch return .{ .raw = source };
                    defer parsed.deinit();
                    return .{ .incomplete = parsed.value };
                }

                if (std.mem.eql(u8, event.string, "response.mcp_call_arguments.delta")) {
                    const parsed = std.json.parseFromValue(
                        ResponseStreamEventMCPCallArgumentsDelta,
                        allocator,
                        source,
                        options,
                    ) catch return .{ .raw = source };
                    defer parsed.deinit();
                    return .{ .mcp_call_arguments_delta = parsed.value };
                }

                if (std.mem.eql(u8, event.string, "response.mcp_call_arguments.done")) {
                    const parsed = std.json.parseFromValue(
                        ResponseStreamEventMCPCallArgumentsDone,
                        allocator,
                        source,
                        options,
                    ) catch return .{ .raw = source };
                    defer parsed.deinit();
                    return .{ .mcp_call_arguments_done = parsed.value };
                }

                if (std.mem.eql(u8, event.string, "response.mcp_call.completed")) {
                    const parsed = std.json.parseFromValue(
                        ResponseStreamEventMCPCallCompleted,
                        allocator,
                        source,
                        options,
                    ) catch return .{ .raw = source };
                    defer parsed.deinit();
                    return .{ .mcp_call_completed = parsed.value };
                }

                if (std.mem.eql(u8, event.string, "response.mcp_call.failed")) {
                    const parsed = std.json.parseFromValue(
                        ResponseStreamEventMCPCallFailed,
                        allocator,
                        source,
                        options,
                    ) catch return .{ .raw = source };
                    defer parsed.deinit();
                    return .{ .mcp_call_failed = parsed.value };
                }

                if (std.mem.eql(u8, event.string, "response.mcp_call.in_progress")) {
                    const parsed = std.json.parseFromValue(
                        ResponseStreamEventMCPCallInProgress,
                        allocator,
                        source,
                        options,
                    ) catch return .{ .raw = source };
                    defer parsed.deinit();
                    return .{ .mcp_call_in_progress = parsed.value };
                }

                if (std.mem.eql(u8, event.string, "response.mcp_list_tools.completed")) {
                    const parsed = std.json.parseFromValue(
                        ResponseStreamEventMCPListToolsCompleted,
                        allocator,
                        source,
                        options,
                    ) catch return .{ .raw = source };
                    defer parsed.deinit();
                    return .{ .mcp_list_tools_completed = parsed.value };
                }

                if (std.mem.eql(u8, event.string, "response.mcp_list_tools.failed")) {
                    const parsed = std.json.parseFromValue(
                        ResponseStreamEventMCPListToolsFailed,
                        allocator,
                        source,
                        options,
                    ) catch return .{ .raw = source };
                    defer parsed.deinit();
                    return .{ .mcp_list_tools_failed = parsed.value };
                }

                if (std.mem.eql(u8, event.string, "response.mcp_list_tools.in_progress")) {
                    const parsed = std.json.parseFromValue(
                        ResponseStreamEventMCPListToolsInProgress,
                        allocator,
                        source,
                        options,
                    ) catch return .{ .raw = source };
                    defer parsed.deinit();
                    return .{ .mcp_list_tools_in_progress = parsed.value };
                }

                if (std.mem.eql(u8, event.string, "response.output_item.added")) {
                    const parsed = std.json.parseFromValue(
                        ResponseStreamEventOutputItemAdded,
                        allocator,
                        source,
                        options,
                    ) catch return .{ .raw = source };
                    defer parsed.deinit();
                    return .{ .output_item_added = parsed.value };
                }

                if (std.mem.eql(u8, event.string, "response.output_item.done")) {
                    const parsed = std.json.parseFromValue(
                        ResponseStreamEventOutputItemDone,
                        allocator,
                        source,
                        options,
                    ) catch return .{ .raw = source };
                    defer parsed.deinit();
                    return .{ .output_item_done = parsed.value };
                }

                if (std.mem.eql(u8, event.string, "response.output_text.annotation.added")) {
                    const parsed = std.json.parseFromValue(
                        ResponseStreamEventOutputTextAnnotationAdded,
                        allocator,
                        source,
                        options,
                    ) catch return .{ .raw = source };
                    defer parsed.deinit();
                    return .{ .output_text_annotation_added = parsed.value };
                }

                if (std.mem.eql(u8, event.string, "response.queued")) {
                    const parsed = std.json.parseFromValue(
                        ResponseStreamEventQueued,
                        allocator,
                        source,
                        options,
                    ) catch return .{ .raw = source };
                    defer parsed.deinit();
                    return .{ .queued = parsed.value };
                }

                if (std.mem.eql(u8, event.string, "response.reasoning_summary_part.added")) {
                    const parsed = std.json.parseFromValue(
                        ResponseStreamEventReasoningSummaryPartAdded,
                        allocator,
                        source,
                        options,
                    ) catch return .{ .raw = source };
                    defer parsed.deinit();
                    return .{ .reasoning_summary_part_added = parsed.value };
                }

                if (std.mem.eql(u8, event.string, "response.reasoning_summary_part.done")) {
                    const parsed = std.json.parseFromValue(
                        ResponseStreamEventReasoningSummaryPartDone,
                        allocator,
                        source,
                        options,
                    ) catch return .{ .raw = source };
                    defer parsed.deinit();
                    return .{ .reasoning_summary_part_done = parsed.value };
                }

                if (std.mem.eql(u8, event.string, "response.reasoning_summary_text.delta")) {
                    const parsed = std.json.parseFromValue(
                        ResponseStreamEventReasoningSummaryTextDelta,
                        allocator,
                        source,
                        options,
                    ) catch return .{ .raw = source };
                    defer parsed.deinit();
                    return .{ .reasoning_summary_text_delta = parsed.value };
                }

                if (std.mem.eql(u8, event.string, "response.reasoning_summary_text.done")) {
                    const parsed = std.json.parseFromValue(
                        ResponseStreamEventReasoningSummaryTextDone,
                        allocator,
                        source,
                        options,
                    ) catch return .{ .raw = source };
                    defer parsed.deinit();
                    return .{ .reasoning_summary_text_done = parsed.value };
                }

                if (std.mem.eql(u8, event.string, "response.reasoning_text.delta")) {
                    const parsed = std.json.parseFromValue(
                        ResponseStreamEventReasoningTextDelta,
                        allocator,
                        source,
                        options,
                    ) catch return .{ .raw = source };
                    defer parsed.deinit();
                    return .{ .reasoning_text_delta = parsed.value };
                }

                if (std.mem.eql(u8, event.string, "response.reasoning_text.done")) {
                    const parsed = std.json.parseFromValue(
                        ResponseStreamEventReasoningTextDone,
                        allocator,
                        source,
                        options,
                    ) catch return .{ .raw = source };
                    defer parsed.deinit();
                    return .{ .reasoning_text_done = parsed.value };
                }

                if (std.mem.eql(u8, event.string, "response.refusal.delta")) {
                    const parsed = std.json.parseFromValue(
                        ResponseStreamEventRefusalDelta,
                        allocator,
                        source,
                        options,
                    ) catch return .{ .raw = source };
                    defer parsed.deinit();
                    return .{ .refusal_delta = parsed.value };
                }

                if (std.mem.eql(u8, event.string, "response.refusal.done")) {
                    const parsed = std.json.parseFromValue(
                        ResponseStreamEventRefusalDone,
                        allocator,
                        source,
                        options,
                    ) catch return .{ .raw = source };
                    defer parsed.deinit();
                    return .{ .refusal_done = parsed.value };
                }

                if (std.mem.eql(u8, event.string, "response.output_text.delta")) {
                    const parsed = std.json.parseFromValue(
                        ResponseStreamEventTextDelta,
                        allocator,
                        source,
                        options,
                    ) catch return .{ .raw = source };
                    defer parsed.deinit();
                    return .{ .text_delta = parsed.value };
                }

                if (std.mem.eql(u8, event.string, "response.output_text.done")) {
                    const parsed = std.json.parseFromValue(
                        ResponseStreamEventTextDone,
                        allocator,
                        source,
                        options,
                    ) catch return .{ .raw = source };
                    defer parsed.deinit();
                    return .{ .text_done = parsed.value };
                }

                if (std.mem.eql(u8, event.string, "response.web_search_call.completed")) {
                    const parsed = std.json.parseFromValue(
                        ResponseStreamEventWebSearchCallCompleted,
                        allocator,
                        source,
                        options,
                    ) catch return .{ .raw = source };
                    defer parsed.deinit();
                    return .{ .web_search_call_completed = parsed.value };
                }

                if (std.mem.eql(u8, event.string, "response.web_search_call.in_progress")) {
                    const parsed = std.json.parseFromValue(
                        ResponseStreamEventWebSearchCallInProgress,
                        allocator,
                        source,
                        options,
                    ) catch return .{ .raw = source };
                    defer parsed.deinit();
                    return .{ .web_search_call_in_progress = parsed.value };
                }

                if (std.mem.eql(u8, event.string, "response.web_search_call.searching")) {
                    const parsed = std.json.parseFromValue(
                        ResponseStreamEventWebSearchCallSearching,
                        allocator,
                        source,
                        options,
                    ) catch return .{ .raw = source };
                    defer parsed.deinit();
                    return .{ .web_search_call_searching = parsed.value };
                }

                return .{ .raw = source };
            },
            else => return .{ .raw = source },
        }
    }
};
pub const ResponseStreamOptions = struct {
    include_obfuscation: ?bool = null,
};
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
    description: ?[]const u8,
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
    next: ?[]const u8,
};
pub const RunCompletionUsage = ?struct {
    completion_tokens: i64,
    prompt_tokens: i64,
    total_tokens: i64,
};
pub const RunGraderRequest = struct {
    grader: EvalGraderConfig,
    item: ?EvalItemContent,
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
            python_grader_server_error_type: ?[]const u8,
            python_grader_runtime_error: bool,
            python_grader_runtime_error_details: ?[]const u8,
            model_grader_server_error: bool,
            model_grader_refusal_error: bool,
            model_grader_parse_error: bool,
            model_grader_server_error_details: ?[]const u8,
        },
        execution_time: f64,
        scores: JsonObject,
        token_usage: ?i64,
        sampled_model_name: ?[]const u8,
    },
    sub_rewards: JsonObject,
    model_grader_token_usage_per_model: JsonObject,
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
    truncation_strategy: JsonObject,
    tool_choice: AssistantsApiToolChoiceOption,
    parallel_tool_calls: ParallelToolCalls,
    response_format: AssistantsApiResponseFormatOption,
};
pub const RunStatus = []const u8;
pub const RunStepCompletionUsage = ?struct {
    completion_tokens: i64,
    prompt_tokens: i64,
    total_tokens: i64,
};
pub const RunStepDeltaObject = struct {
    id: []const u8,
    object: []const u8,
    delta: RunStepDeltaObjectDelta,
};
pub const RunStepDeltaObjectDelta = struct {
    step_details: ?RunStepDeltaStepDetails,
};
pub const RunStepDeltaStepDetailsMessageCreationObject = struct {
    type: []const u8,
    message_creation: ?struct {
        message_id: ?[]const u8,
    },
};
pub const RunStepDeltaStepDetailsToolCall = union(enum) {
    code_interpreter: RunStepDeltaStepDetailsToolCallsCodeObject,
    file_search: RunStepDeltaStepDetailsToolCallsFileSearchObject,
    function: RunStepDeltaStepDetailsToolCallsFunctionObject,
    raw: std.json.Value,

    pub fn jsonStringify(self: RunStepDeltaStepDetailsToolCall, writer: anytype) !void {
        switch (self) {
            .code_interpreter => |value| {
                try writer.write(value);
            },
            .file_search => |value| {
                try writer.write(value);
            },
            .function => |value| {
                try writer.write(value);
            },
            .raw => |value| {
                try writer.write(value);
            },
        }
    }

    pub fn jsonParse(allocator: std.mem.Allocator, source: anytype, options: std.json.ParseOptions) !RunStepDeltaStepDetailsToolCall {
        return .{
            .raw = try std.json.Value.jsonParse(allocator, source, options),
        };
    }

    pub fn jsonParseFromValue(
        allocator: std.mem.Allocator,
        source: std.json.Value,
        options: std.json.ParseOptions,
    ) !RunStepDeltaStepDetailsToolCall {
        _ = allocator;
        _ = options;
        return .{ .raw = source };
    }
};
pub const RunStepDeltaStepDetailsToolCallsCodeObject = struct {
    index: i64,
    id: ?[]const u8,
    type: []const u8,
    code_interpreter: ?struct {
        input: ?[]const u8,
        outputs: ?[]const CodeInterpreterOutput,
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
    file_search: JsonObject,
};
pub const RunStepDeltaStepDetailsToolCallsFunctionObject = struct {
    index: i64,
    id: ?[]const u8,
    type: []const u8,
    function: ?struct {
        name: ?[]const u8,
        arguments: ?[]const u8,
        output: ?[]const u8,
    },
};
pub const RunStepDeltaStepDetailsToolCallsObject = struct {
    type: []const u8,
    tool_calls: ?[]const RunStepDeltaStepDetailsToolCall,
};
pub const RunStepDeltaStepDetails = union(enum) {
    message_creation: RunStepDeltaStepDetailsMessageCreationObject,
    tool_calls: RunStepDeltaStepDetailsToolCallsObject,
    raw: std.json.Value,

    pub fn jsonStringify(self: RunStepDeltaStepDetails, writer: anytype) !void {
        switch (self) {
            .message_creation => |value| {
                try writer.write(value);
            },
            .tool_calls => |value| {
                try writer.write(value);
            },
            .raw => |value| {
                try writer.write(value);
            },
        }
    }

    pub fn jsonParse(allocator: std.mem.Allocator, source: anytype, options: std.json.ParseOptions) !RunStepDeltaStepDetails {
        return .{
            .raw = try std.json.Value.jsonParse(allocator, source, options),
        };
    }

    pub fn jsonParseFromValue(
        allocator: std.mem.Allocator,
        source: std.json.Value,
        options: std.json.ParseOptions,
    ) !RunStepDeltaStepDetails {
        _ = allocator;
        _ = options;
        return .{ .raw = source };
    }
};
pub const RunStepDetailsMessageCreationObject = struct {
    type: []const u8,
    message_creation: struct {
        message_id: []const u8,
    },
};
pub const RunStepDetailsToolCall = union(enum) {
    code_interpreter: RunStepDetailsToolCallsCodeObject,
    file_search: RunStepDetailsToolCallsFileSearchObject,
    function: RunStepDetailsToolCallsFunctionObject,
    raw: std.json.Value,

    pub fn jsonStringify(self: RunStepDetailsToolCall, writer: anytype) !void {
        switch (self) {
            .code_interpreter => |value| {
                try writer.write(value);
            },
            .file_search => |value| {
                try writer.write(value);
            },
            .function => |value| {
                try writer.write(value);
            },
            .raw => |value| {
                try writer.write(value);
            },
        }
    }

    pub fn jsonParse(allocator: std.mem.Allocator, source: anytype, options: std.json.ParseOptions) !RunStepDetailsToolCall {
        return .{
            .raw = try std.json.Value.jsonParse(allocator, source, options),
        };
    }

    pub fn jsonParseFromValue(
        allocator: std.mem.Allocator,
        source: std.json.Value,
        options: std.json.ParseOptions,
    ) !RunStepDetailsToolCall {
        _ = allocator;
        _ = options;
        return .{ .raw = source };
    }
};
pub const RunStepDetailsToolCallsCodeObject = struct {
    id: []const u8,
    type: []const u8,
    code_interpreter: struct {
        input: []const u8,
        outputs: []const CodeInterpreterOutput,
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
        output: ?[]const u8,
    },
};
pub const RunStepDetailsToolCallsObject = struct {
    type: []const u8,
    tool_calls: []const RunStepDetailsToolCall,
};
pub const RunStepDetails = union(enum) {
    message_creation: RunStepDetailsMessageCreationObject,
    tool_calls: RunStepDetailsToolCallsObject,
    raw: std.json.Value,

    pub fn jsonStringify(self: RunStepDetails, writer: anytype) !void {
        switch (self) {
            .message_creation => |value| {
                try writer.write(value);
            },
            .tool_calls => |value| {
                try writer.write(value);
            },
            .raw => |value| {
                try writer.write(value);
            },
        }
    }

    pub fn jsonParse(allocator: std.mem.Allocator, source: anytype, options: std.json.ParseOptions) !RunStepDetails {
        return .{
            .raw = try std.json.Value.jsonParse(allocator, source, options),
        };
    }

    pub fn jsonParseFromValue(
        allocator: std.mem.Allocator,
        source: std.json.Value,
        options: std.json.ParseOptions,
    ) !RunStepDetails {
        _ = allocator;
        _ = options;
        return .{ .raw = source };
    }
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
    step_details: RunStepDetails,
    last_error: ?RunStepLastError,
    expired_at: ?i64,
    cancelled_at: ?i64,
    failed_at: ?i64,
    completed_at: ?i64,
    metadata: Metadata,
    usage: RunStepCompletionUsage,
};

pub const RunStepLastError = struct {
    code: ?[]const u8,
    message: ?[]const u8,
};
pub const RunStepStreamEventCreated = struct {
    event: []const u8,
    data: RunStepObject,
};
pub const RunStepStreamEventInProgress = struct {
    event: []const u8,
    data: RunStepObject,
};
pub const RunStepStreamEventDelta = struct {
    event: []const u8,
    data: RunStepDeltaObject,
};
pub const RunStepStreamEventCompleted = struct {
    event: []const u8,
    data: RunStepObject,
};
pub const RunStepStreamEventFailed = struct {
    event: []const u8,
    data: RunStepObject,
};
pub const RunStepStreamEventCancelled = struct {
    event: []const u8,
    data: RunStepObject,
};
pub const RunStepStreamEventExpired = struct {
    event: []const u8,
    data: RunStepObject,
};
pub const RunStepStreamEvent = union(enum) {
    created: RunStepStreamEventCreated,
    in_progress: RunStepStreamEventInProgress,
    delta: RunStepStreamEventDelta,
    completed: RunStepStreamEventCompleted,
    failed: RunStepStreamEventFailed,
    cancelled: RunStepStreamEventCancelled,
    expired: RunStepStreamEventExpired,
    raw: std.json.Value,

    pub fn forCreated(value: RunStepStreamEventCreated) RunStepStreamEvent {
        return .{ .created = value };
    }

    pub fn forInProgress(value: RunStepStreamEventInProgress) RunStepStreamEvent {
        return .{ .in_progress = value };
    }

    pub fn forDelta(value: RunStepStreamEventDelta) RunStepStreamEvent {
        return .{ .delta = value };
    }

    pub fn forCompleted(value: RunStepStreamEventCompleted) RunStepStreamEvent {
        return .{ .completed = value };
    }

    pub fn forFailed(value: RunStepStreamEventFailed) RunStepStreamEvent {
        return .{ .failed = value };
    }

    pub fn forCancelled(value: RunStepStreamEventCancelled) RunStepStreamEvent {
        return .{ .cancelled = value };
    }

    pub fn forExpired(value: RunStepStreamEventExpired) RunStepStreamEvent {
        return .{ .expired = value };
    }

    pub fn forRaw(value: std.json.Value) RunStepStreamEvent {
        return .{ .raw = value };
    }

    pub fn jsonStringify(self: RunStepStreamEvent, writer: anytype) !void {
        switch (self) {
            .created => |value| {
                try writer.write(value);
            },
            .in_progress => |value| {
                try writer.write(value);
            },
            .delta => |value| {
                try writer.write(value);
            },
            .completed => |value| {
                try writer.write(value);
            },
            .failed => |value| {
                try writer.write(value);
            },
            .cancelled => |value| {
                try writer.write(value);
            },
            .expired => |value| {
                try writer.write(value);
            },
            .raw => |value| {
                try writer.write(value);
            },
        }
    }

    pub fn jsonParse(allocator: std.mem.Allocator, source: anytype, options: std.json.ParseOptions) !RunStepStreamEvent {
        const parsed = try std.json.Value.jsonParse(allocator, source, options);
        return jsonParseFromValue(allocator, parsed, options);
    }

    pub fn jsonParseFromValue(
        allocator: std.mem.Allocator,
        source: std.json.Value,
        options: std.json.ParseOptions,
    ) !RunStepStreamEvent {
        switch (source) {
            .object => |root| {
                const event = root.get("event") orelse return .{ .raw = source };
                if (event != .string) return .{ .raw = source };

                if (std.mem.eql(u8, event.string, "thread.run.step.created")) {
                    const parsed = std.json.parseFromValue(
                        RunStepStreamEventCreated,
                        allocator,
                        source,
                        options,
                    ) catch return .{ .raw = source };
                    defer parsed.deinit();
                    return .{ .created = parsed.value };
                }

                if (std.mem.eql(u8, event.string, "thread.run.step.in_progress")) {
                    const parsed = std.json.parseFromValue(
                        RunStepStreamEventInProgress,
                        allocator,
                        source,
                        options,
                    ) catch return .{ .raw = source };
                    defer parsed.deinit();
                    return .{ .in_progress = parsed.value };
                }

                if (std.mem.eql(u8, event.string, "thread.run.step.delta")) {
                    const parsed = std.json.parseFromValue(
                        RunStepStreamEventDelta,
                        allocator,
                        source,
                        options,
                    ) catch return .{ .raw = source };
                    defer parsed.deinit();
                    return .{ .delta = parsed.value };
                }

                if (std.mem.eql(u8, event.string, "thread.run.step.completed")) {
                    const parsed = std.json.parseFromValue(
                        RunStepStreamEventCompleted,
                        allocator,
                        source,
                        options,
                    ) catch return .{ .raw = source };
                    defer parsed.deinit();
                    return .{ .completed = parsed.value };
                }

                if (std.mem.eql(u8, event.string, "thread.run.step.failed")) {
                    const parsed = std.json.parseFromValue(
                        RunStepStreamEventFailed,
                        allocator,
                        source,
                        options,
                    ) catch return .{ .raw = source };
                    defer parsed.deinit();
                    return .{ .failed = parsed.value };
                }

                if (std.mem.eql(u8, event.string, "thread.run.step.cancelled")) {
                    const parsed = std.json.parseFromValue(
                        RunStepStreamEventCancelled,
                        allocator,
                        source,
                        options,
                    ) catch return .{ .raw = source };
                    defer parsed.deinit();
                    return .{ .cancelled = parsed.value };
                }

                if (std.mem.eql(u8, event.string, "thread.run.step.expired")) {
                    const parsed = std.json.parseFromValue(
                        RunStepStreamEventExpired,
                        allocator,
                        source,
                        options,
                    ) catch return .{ .raw = source };
                    defer parsed.deinit();
                    return .{ .expired = parsed.value };
                }

                return .{ .raw = source };
            },
            else => return .{ .raw = source },
        }
    }
};
pub const RunStreamEventCreated = struct {
    event: []const u8,
    data: RunObject,
};
pub const RunStreamEventQueued = struct {
    event: []const u8,
    data: RunObject,
};
pub const RunStreamEventInProgress = struct {
    event: []const u8,
    data: RunObject,
};
pub const RunStreamEventRequiresAction = struct {
    event: []const u8,
    data: RunObject,
};
pub const RunStreamEventCompleted = struct {
    event: []const u8,
    data: RunObject,
};
pub const RunStreamEventIncomplete = struct {
    event: []const u8,
    data: RunObject,
};
pub const RunStreamEventFailed = struct {
    event: []const u8,
    data: RunObject,
};
pub const RunStreamEventCancelling = struct {
    event: []const u8,
    data: RunObject,
};
pub const RunStreamEventCancelled = struct {
    event: []const u8,
    data: RunObject,
};
pub const RunStreamEventExpired = struct {
    event: []const u8,
    data: RunObject,
};
pub const RunStreamEvent = union(enum) {
    created: RunStreamEventCreated,
    queued: RunStreamEventQueued,
    in_progress: RunStreamEventInProgress,
    requires_action: RunStreamEventRequiresAction,
    completed: RunStreamEventCompleted,
    incomplete: RunStreamEventIncomplete,
    failed: RunStreamEventFailed,
    cancelling: RunStreamEventCancelling,
    cancelled: RunStreamEventCancelled,
    expired: RunStreamEventExpired,
    raw: std.json.Value,

    pub fn forCreated(value: RunStreamEventCreated) RunStreamEvent {
        return .{ .created = value };
    }

    pub fn forQueued(value: RunStreamEventQueued) RunStreamEvent {
        return .{ .queued = value };
    }

    pub fn forInProgress(value: RunStreamEventInProgress) RunStreamEvent {
        return .{ .in_progress = value };
    }

    pub fn forRequiresAction(value: RunStreamEventRequiresAction) RunStreamEvent {
        return .{ .requires_action = value };
    }

    pub fn forCompleted(value: RunStreamEventCompleted) RunStreamEvent {
        return .{ .completed = value };
    }

    pub fn forIncomplete(value: RunStreamEventIncomplete) RunStreamEvent {
        return .{ .incomplete = value };
    }

    pub fn forFailed(value: RunStreamEventFailed) RunStreamEvent {
        return .{ .failed = value };
    }

    pub fn forCancelling(value: RunStreamEventCancelling) RunStreamEvent {
        return .{ .cancelling = value };
    }

    pub fn forCancelled(value: RunStreamEventCancelled) RunStreamEvent {
        return .{ .cancelled = value };
    }

    pub fn forExpired(value: RunStreamEventExpired) RunStreamEvent {
        return .{ .expired = value };
    }

    pub fn forRaw(value: std.json.Value) RunStreamEvent {
        return .{ .raw = value };
    }

    pub fn jsonStringify(self: RunStreamEvent, writer: anytype) !void {
        switch (self) {
            .created => |value| {
                try writer.write(value);
            },
            .queued => |value| {
                try writer.write(value);
            },
            .in_progress => |value| {
                try writer.write(value);
            },
            .requires_action => |value| {
                try writer.write(value);
            },
            .completed => |value| {
                try writer.write(value);
            },
            .incomplete => |value| {
                try writer.write(value);
            },
            .failed => |value| {
                try writer.write(value);
            },
            .cancelling => |value| {
                try writer.write(value);
            },
            .cancelled => |value| {
                try writer.write(value);
            },
            .expired => |value| {
                try writer.write(value);
            },
            .raw => |value| {
                try writer.write(value);
            },
        }
    }

    pub fn jsonParse(allocator: std.mem.Allocator, source: anytype, options: std.json.ParseOptions) !RunStreamEvent {
        const parsed = try std.json.Value.jsonParse(allocator, source, options);
        return jsonParseFromValue(allocator, parsed, options);
    }

    pub fn jsonParseFromValue(
        allocator: std.mem.Allocator,
        source: std.json.Value,
        options: std.json.ParseOptions,
    ) !RunStreamEvent {
        switch (source) {
            .object => |root| {
                const event = root.get("event") orelse return .{ .raw = source };
                if (event != .string) return .{ .raw = source };

                if (std.mem.eql(u8, event.string, "thread.run.created")) {
                    const parsed = std.json.parseFromValue(
                        RunStreamEventCreated,
                        allocator,
                        source,
                        options,
                    ) catch return .{ .raw = source };
                    defer parsed.deinit();
                    return .{ .created = parsed.value };
                }

                if (std.mem.eql(u8, event.string, "thread.run.queued")) {
                    const parsed = std.json.parseFromValue(
                        RunStreamEventQueued,
                        allocator,
                        source,
                        options,
                    ) catch return .{ .raw = source };
                    defer parsed.deinit();
                    return .{ .queued = parsed.value };
                }

                if (std.mem.eql(u8, event.string, "thread.run.in_progress")) {
                    const parsed = std.json.parseFromValue(
                        RunStreamEventInProgress,
                        allocator,
                        source,
                        options,
                    ) catch return .{ .raw = source };
                    defer parsed.deinit();
                    return .{ .in_progress = parsed.value };
                }

                if (std.mem.eql(u8, event.string, "thread.run.requires_action")) {
                    const parsed = std.json.parseFromValue(
                        RunStreamEventRequiresAction,
                        allocator,
                        source,
                        options,
                    ) catch return .{ .raw = source };
                    defer parsed.deinit();
                    return .{ .requires_action = parsed.value };
                }

                if (std.mem.eql(u8, event.string, "thread.run.completed")) {
                    const parsed = std.json.parseFromValue(
                        RunStreamEventCompleted,
                        allocator,
                        source,
                        options,
                    ) catch return .{ .raw = source };
                    defer parsed.deinit();
                    return .{ .completed = parsed.value };
                }

                if (std.mem.eql(u8, event.string, "thread.run.incomplete")) {
                    const parsed = std.json.parseFromValue(
                        RunStreamEventIncomplete,
                        allocator,
                        source,
                        options,
                    ) catch return .{ .raw = source };
                    defer parsed.deinit();
                    return .{ .incomplete = parsed.value };
                }

                if (std.mem.eql(u8, event.string, "thread.run.failed")) {
                    const parsed = std.json.parseFromValue(
                        RunStreamEventFailed,
                        allocator,
                        source,
                        options,
                    ) catch return .{ .raw = source };
                    defer parsed.deinit();
                    return .{ .failed = parsed.value };
                }

                if (std.mem.eql(u8, event.string, "thread.run.cancelling")) {
                    const parsed = std.json.parseFromValue(
                        RunStreamEventCancelling,
                        allocator,
                        source,
                        options,
                    ) catch return .{ .raw = source };
                    defer parsed.deinit();
                    return .{ .cancelling = parsed.value };
                }

                if (std.mem.eql(u8, event.string, "thread.run.cancelled")) {
                    const parsed = std.json.parseFromValue(
                        RunStreamEventCancelled,
                        allocator,
                        source,
                        options,
                    ) catch return .{ .raw = source };
                    defer parsed.deinit();
                    return .{ .cancelled = parsed.value };
                }

                if (std.mem.eql(u8, event.string, "thread.run.expired")) {
                    const parsed = std.json.parseFromValue(
                        RunStreamEventExpired,
                        allocator,
                        source,
                        options,
                    ) catch return .{ .raw = source };
                    defer parsed.deinit();
                    return .{ .expired = parsed.value };
                }

                return .{ .raw = source };
            },
            else => return .{ .raw = source },
        }
    }
};
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
pub const ServiceTier = []const u8;
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
pub const StopConfiguration = union(enum) {
    single: []const u8,
    multiple: []const []const u8,
    raw: std.json.Value,

    pub fn jsonStringify(self: StopConfiguration, writer: anytype) !void {
        switch (self) {
            .single => |value| {
                try writer.write(value);
            },
            .multiple => |values| {
                try writer.write(values);
            },
            .raw => |value| {
                try writer.write(value);
            },
        }
    }

    pub fn forSingle(value: []const u8) StopConfiguration {
        return .{ .single = value };
    }

    pub fn forMultiple(values: []const []const u8) StopConfiguration {
        return .{ .multiple = values };
    }

    pub fn forRaw(value: std.json.Value) StopConfiguration {
        return .{ .raw = value };
    }
};
pub const SubmitToolOutputsRunRequest = struct {
    tool_outputs: []const struct {
        tool_call_id: ?[]const u8,
        output: ?[]const u8,
    },
    stream: ?bool,
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
    heading: ?[]const u8,
    summary: ?[]const u8,
};
pub const TaskItem = struct {
    id: []const u8,
    object: []const u8,
    created_at: i64,
    thread_id: []const u8,
    type: []const u8,
    task_type: TaskType,
    heading: ?[]const u8,
    summary: ?[]const u8,
};
pub const TaskType = []const u8;
pub const TextAnnotation = MessageTextAnnotation;
pub const TextAnnotationDelta = MessageTextAnnotationDelta;
pub const TextContent = struct {
    type: []const u8,
    text: []const u8,
};
pub const TextResponseFormatConfiguration = union(enum) {
    text: ResponseFormatText,
    json_schema: TextResponseFormatJsonSchema,
    json_object: ResponseFormatJsonObject,
    raw: std.json.Value,

    pub fn forText(value: ResponseFormatText) TextResponseFormatConfiguration {
        return .{ .text = value };
    }

    pub fn forJsonSchema(value: TextResponseFormatJsonSchema) TextResponseFormatConfiguration {
        return .{ .json_schema = value };
    }

    pub fn forJsonObject(value: ResponseFormatJsonObject) TextResponseFormatConfiguration {
        return .{ .json_object = value };
    }

    pub fn forRaw(value: std.json.Value) TextResponseFormatConfiguration {
        return .{ .raw = value };
    }

    pub fn jsonStringify(self: TextResponseFormatConfiguration, writer: anytype) !void {
        switch (self) {
            .text => |value| {
                try writer.write(value);
            },
            .json_schema => |value| {
                try writer.write(value);
            },
            .json_object => |value| {
                try writer.write(value);
            },
            .raw => |value| {
                try writer.write(value);
            },
        }
    }

    pub fn jsonParse(allocator: std.mem.Allocator, source: anytype, options: std.json.ParseOptions) !TextResponseFormatConfiguration {
        const parsed = try std.json.Value.jsonParse(allocator, source, options);
        return jsonParseFromValue(allocator, parsed, options);
    }

    pub fn jsonParseFromValue(
        allocator: std.mem.Allocator,
        source: std.json.Value,
        options: std.json.ParseOptions,
    ) !TextResponseFormatConfiguration {
        switch (source) {
            .object => |root| {
                const kind = root.get("type") orelse return .{ .raw = source };
                if (kind != .string) return .{ .raw = source };

                if (std.mem.eql(u8, kind.string, "text")) {
                    const parsed = std.json.parseFromValue(
                        ResponseFormatText,
                        allocator,
                        source,
                        options,
                    ) catch return .{ .raw = source };
                    defer parsed.deinit();
                    return .{ .text = parsed.value };
                }

                if (std.mem.eql(u8, kind.string, "json_object")) {
                    const parsed = std.json.parseFromValue(
                        ResponseFormatJsonObject,
                        allocator,
                        source,
                        options,
                    ) catch return .{ .raw = source };
                    defer parsed.deinit();
                    return .{ .json_object = parsed.value };
                }

                if (std.mem.eql(u8, kind.string, "json_schema")) {
                    const parsed = std.json.parseFromValue(
                        TextResponseFormatJsonSchema,
                        allocator,
                        source,
                        options,
                    ) catch return .{ .raw = source };
                    defer parsed.deinit();
                    return .{ .json_schema = parsed.value };
                }

                return .{ .raw = source };
            },
            else => return .{ .raw = source },
        }
    }
};
pub const TextResponseFormatJsonSchema = struct {
    type: []const u8,
    description: ?[]const u8,
    name: []const u8,
    schema: ResponseFormatJsonSchemaSchema,
    strict: ?bool,
};
pub const ThreadItem = union(enum) {
    user: UserMessageItem,
    assistant: AssistantMessageItem,
    widget: WidgetMessageItem,
    client_tool_call: ClientToolCallItem,
    task: TaskItem,
    task_group: TaskGroupItem,
    raw: std.json.Value,

    pub fn forUser(value: UserMessageItem) ThreadItem {
        return .{ .user = value };
    }

    pub fn forAssistant(value: AssistantMessageItem) ThreadItem {
        return .{ .assistant = value };
    }

    pub fn forWidget(value: WidgetMessageItem) ThreadItem {
        return .{ .widget = value };
    }

    pub fn forClientToolCall(value: ClientToolCallItem) ThreadItem {
        return .{ .client_tool_call = value };
    }

    pub fn forTask(value: TaskItem) ThreadItem {
        return .{ .task = value };
    }

    pub fn forTaskGroup(value: TaskGroupItem) ThreadItem {
        return .{ .task_group = value };
    }

    pub fn forRaw(value: std.json.Value) ThreadItem {
        return .{ .raw = value };
    }

    pub fn jsonStringify(self: ThreadItem, writer: anytype) !void {
        switch (self) {
            .user => |value| {
                try writer.write(value);
            },
            .assistant => |value| {
                try writer.write(value);
            },
            .widget => |value| {
                try writer.write(value);
            },
            .client_tool_call => |value| {
                try writer.write(value);
            },
            .task => |value| {
                try writer.write(value);
            },
            .task_group => |value| {
                try writer.write(value);
            },
            .raw => |value| {
                try writer.write(value);
            },
        }
    }

    pub fn jsonParse(allocator: std.mem.Allocator, source: anytype, options: std.json.ParseOptions) !ThreadItem {
        const parsed = try std.json.Value.jsonParse(allocator, source, options);
        return jsonParseFromValue(allocator, parsed, options);
    }

    pub fn jsonParseFromValue(
        allocator: std.mem.Allocator,
        source: std.json.Value,
        options: std.json.ParseOptions,
    ) !ThreadItem {
        switch (source) {
            .object => |root| {
                const kind = root.get("type") orelse return .{ .raw = source };
                if (kind != .string) return .{ .raw = source };

                if (std.mem.eql(u8, kind.string, "chatkit.user_message")) {
                    const parsed = std.json.parseFromValue(
                        UserMessageItem,
                        allocator,
                        source,
                        options,
                    ) catch return .{ .raw = source };
                    defer parsed.deinit();
                    return .{ .user = parsed.value };
                }

                if (std.mem.eql(u8, kind.string, "chatkit.assistant_message")) {
                    const parsed = std.json.parseFromValue(
                        AssistantMessageItem,
                        allocator,
                        source,
                        options,
                    ) catch return .{ .raw = source };
                    defer parsed.deinit();
                    return .{ .assistant = parsed.value };
                }

                if (std.mem.eql(u8, kind.string, "chatkit.widget")) {
                    const parsed = std.json.parseFromValue(
                        WidgetMessageItem,
                        allocator,
                        source,
                        options,
                    ) catch return .{ .raw = source };
                    defer parsed.deinit();
                    return .{ .widget = parsed.value };
                }

                if (std.mem.eql(u8, kind.string, "chatkit.client_tool_call")) {
                    const parsed = std.json.parseFromValue(
                        ClientToolCallItem,
                        allocator,
                        source,
                        options,
                    ) catch return .{ .raw = source };
                    defer parsed.deinit();
                    return .{ .client_tool_call = parsed.value };
                }

                if (std.mem.eql(u8, kind.string, "chatkit.task")) {
                    const parsed = std.json.parseFromValue(
                        TaskItem,
                        allocator,
                        source,
                        options,
                    ) catch return .{ .raw = source };
                    defer parsed.deinit();
                    return .{ .task = parsed.value };
                }

                if (std.mem.eql(u8, kind.string, "chatkit.task_group")) {
                    const parsed = std.json.parseFromValue(
                        TaskGroupItem,
                        allocator,
                        source,
                        options,
                    ) catch return .{ .raw = source };
                    defer parsed.deinit();
                    return .{ .task_group = parsed.value };
                }

                return .{ .raw = source };
            },
            else => return .{ .raw = source },
        }
    }
};
pub const ThreadItemListResource = struct {
    object: []const u8,
    data: []const ThreadItem,
    first_id: []const u8,
    last_id: []const u8,
    has_more: bool,
};
pub const ThreadListResource = struct {
    object: []const u8,
    data: []const ThreadResource,
    first_id: []const u8,
    last_id: []const u8,
    has_more: bool,
};
pub const ThreadObject = struct {
    id: []const u8,
    object: []const u8,
    created_at: i64,
    tool_resources: ?AssistantToolResources,
    metadata: Metadata,
};
pub const ThreadResource = struct {
    id: []const u8,
    object: []const u8,
    created_at: i64,
    title: ?[]const u8,
    status: ?[]const u8,
    user: []const u8,
};
pub const ThreadStreamEventCreated = struct {
    enabled: ?bool,
    event: []const u8,
    data: ThreadObject,
};
pub const ThreadStreamEvent = union(enum) {
    created: ThreadStreamEventCreated,
    raw: std.json.Value,

    pub fn forCreated(value: ThreadStreamEventCreated) ThreadStreamEvent {
        return .{ .created = value };
    }

    pub fn forRaw(value: std.json.Value) ThreadStreamEvent {
        return .{ .raw = value };
    }

    pub fn jsonStringify(self: ThreadStreamEvent, writer: anytype) !void {
        switch (self) {
            .created => |value| {
                try writer.write(value);
            },
            .raw => |value| {
                try writer.write(value);
            },
        }
    }

    pub fn jsonParse(allocator: std.mem.Allocator, source: anytype, options: std.json.ParseOptions) !ThreadStreamEvent {
        const parsed = try std.json.Value.jsonParse(allocator, source, options);
        return jsonParseFromValue(allocator, parsed, options);
    }

    pub fn jsonParseFromValue(
        allocator: std.mem.Allocator,
        source: std.json.Value,
        options: std.json.ParseOptions,
    ) !ThreadStreamEvent {
        switch (source) {
            .object => |root| {
                const event = root.get("event") orelse return .{ .raw = source };
                if (event != .string) return .{ .raw = source };

                if (std.mem.eql(u8, event.string, "thread.created")) {
                    const parsed = std.json.parseFromValue(
                        ThreadStreamEventCreated,
                        allocator,
                        source,
                        options,
                    ) catch return .{ .raw = source };
                    defer parsed.deinit();
                    return .{ .created = parsed.value };
                }

                return .{ .raw = source };
            },
            else => return .{ .raw = source },
        }
    }
};
pub const ToggleCertificatesRequest = struct {
    certificate_ids: []const []const u8,
};
pub const TokenCountsBody = struct {
    model: ?[]const u8,
    input: ?InputParam,
    previous_response_id: ?[]const u8,
    tools: ?[]const Tool,
    text: ?ResponseTextParam,
    reasoning: ?Reasoning,
    truncation: ?TruncationEnum,
    instructions: ?[]const u8,
    conversation: ?ConversationParam,
    tool_choice: ?ToolChoiceParam,
    parallel_tool_calls: ?ParallelToolCalls,
};
pub const TokenCountsResource = struct {
    object: []const u8,
    input_tokens: i64,
};
pub const Tool = union(enum) {
    function: FunctionTool,
    file_search: FileSearchTool,
    code_interpreter: CodeInterpreterTool,
    computer: ComputerUsePreviewTool,
    custom: CustomToolParam,
    mcp: MCPTool,
    raw: std.json.Value,

    pub fn forFunction(function: FunctionTool) Tool {
        return .{ .function = function };
    }

    pub fn forFileSearch(file_search: FileSearchTool) Tool {
        return .{ .file_search = file_search };
    }

    pub fn forCodeInterpreter(tool: CodeInterpreterTool) Tool {
        return .{ .code_interpreter = tool };
    }

    pub fn forComputer(tool: ComputerUsePreviewTool) Tool {
        return .{ .computer = tool };
    }

    pub fn forCustom(tool: CustomToolParam) Tool {
        return .{ .custom = tool };
    }

    pub fn forMCP(tool: MCPTool) Tool {
        return .{ .mcp = tool };
    }

    pub fn forRaw(value: std.json.Value) Tool {
        return .{ .raw = value };
    }

    pub fn jsonStringify(self: Tool, writer: anytype) !void {
        switch (self) {
            .function => |value| {
                try writer.write(value);
            },
            .file_search => |value| {
                try writer.write(value);
            },
            .code_interpreter => |value| {
                try writer.write(value);
            },
            .computer => |value| {
                try writer.write(value);
            },
            .custom => |value| {
                try writer.write(value);
            },
            .mcp => |value| {
                try writer.write(value);
            },
            .raw => |value| {
                try writer.write(value);
            },
        }
    }

    pub fn jsonParse(allocator: std.mem.Allocator, source: anytype, options: std.json.ParseOptions) !Tool {
        return .{
            .raw = try std.json.Value.jsonParse(allocator, source, options),
        };
    }

    pub fn jsonParseFromValue(
        allocator: std.mem.Allocator,
        source: std.json.Value,
        options: std.json.ParseOptions,
    ) !Tool {
        _ = allocator;
        _ = options;
        return .{ .raw = source };
    }
};
pub const ToolChoice = struct {
    id: []const u8,
};
pub const ToolChoiceAllowed = struct {
    type: []const u8,
    mode: []const u8,
    tools: []const ToolChoiceTypes,
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
    name: ?[]const u8,
};
pub const ToolChoiceOptions = []const u8;
pub const ToolChoiceParam = union(enum) {
    none: void,
    auto: void,
    required: void,
    named: AssistantsNamedToolChoice,
    function: ToolChoiceFunction,
    custom: ToolChoiceCustom,
    mcp: ToolChoiceMCP,
    allowed: ToolChoiceAllowed,
    raw: std.json.Value,

    pub fn forNone() ToolChoiceParam {
        return .none;
    }

    pub fn forAuto() ToolChoiceParam {
        return .auto;
    }

    pub fn forRequired() ToolChoiceParam {
        return .required;
    }

    pub fn forNamed(name: []const u8) ToolChoiceParam {
        return .{
            .named = .{
                .type = "function",
                .function = .{
                    .name = name,
                },
            },
        };
    }

    pub fn forFunction(name: []const u8) ToolChoiceParam {
        return .{
            .function = .{
                .type = "function",
                .name = name,
            },
        };
    }

    pub fn forCustom(name: []const u8) ToolChoiceParam {
        return .{
            .custom = .{
                .type = "custom",
                .name = name,
            },
        };
    }

    pub fn forMCP(server_label: []const u8, name: []const u8) ToolChoiceParam {
        return .{
            .mcp = .{
                .type = "mcp",
                .server_label = server_label,
                .name = name,
            },
        };
    }

    pub fn forRaw(value: std.json.Value) ToolChoiceParam {
        return .{ .raw = value };
    }

    pub fn jsonStringify(self: ToolChoiceParam, writer: anytype) !void {
        switch (self) {
            .none => {
                try writer.write("none");
            },
            .auto => {
                try writer.write("auto");
            },
            .required => {
                try writer.write("required");
            },
            .named => |value| {
                try writer.write(value);
            },
            .function => |value| {
                try writer.write(value);
            },
            .custom => |value| {
                try writer.write(value);
            },
            .mcp => |value| {
                try writer.write(value);
            },
            .allowed => |value| {
                try writer.write(value);
            },
            .raw => |value| {
                try writer.write(value);
            },
        }
    }

    pub fn jsonParse(allocator: std.mem.Allocator, source: anytype, options: std.json.ParseOptions) !ToolChoiceParam {
        return .{
            .raw = try std.json.Value.jsonParse(allocator, source, options),
        };
    }

    pub fn jsonParseFromValue(
        allocator: std.mem.Allocator,
        source: std.json.Value,
        options: std.json.ParseOptions,
    ) !ToolChoiceParam {
        _ = allocator;
        _ = options;
        return .{ .raw = source };
    }
};
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
pub const TranscriptTextUsage = struct {
    type: []const u8,
    seconds: ?f64 = null,
    input_tokens: ?i64 = null,
    input_token_details: ?struct {
        text_tokens: ?i64 = null,
        audio_tokens: ?i64 = null,
    } = null,
    output_tokens: ?i64 = null,
    total_tokens: ?i64 = null,
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
pub const TranscriptionChunkingStrategy = ChunkingStrategyRequestParam;
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
    last_messages: ?i64,
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
    expires_after: ?VectorStoreExpirationAfter,
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
    file: ?OpenAIFile,
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
    project_id: ?[]const u8,
    user_id: ?[]const u8,
    api_key_id: ?[]const u8,
    model: ?[]const u8,
};
pub const UsageAudioTranscriptionsResult = struct {
    object: []const u8,
    seconds: i64,
    num_model_requests: i64,
    project_id: ?[]const u8,
    user_id: ?[]const u8,
    api_key_id: ?[]const u8,
    model: ?[]const u8,
};
pub const UsageCodeInterpreterSessionsResult = struct {
    object: []const u8,
    num_sessions: ?i64,
    project_id: ?[]const u8,
};
pub const UsageCompletionsResult = struct {
    object: []const u8,
    input_tokens: i64,
    input_cached_tokens: ?i64,
    output_tokens: i64,
    input_audio_tokens: ?i64,
    output_audio_tokens: ?i64,
    num_model_requests: i64,
    project_id: ?[]const u8,
    user_id: ?[]const u8,
    api_key_id: ?[]const u8,
    model: ?[]const u8,
    batch: ?[]const u8,
    service_tier: ?[]const u8,
};
pub const UsageEmbeddingsResult = struct {
    object: []const u8,
    input_tokens: i64,
    num_model_requests: i64,
    project_id: ?[]const u8,
    user_id: ?[]const u8,
    api_key_id: ?[]const u8,
    model: ?[]const u8,
};
pub const UsageImagesResult = struct {
    object: []const u8,
    images: i64,
    num_model_requests: i64,
    source: ?[]const u8,
    size: ?[]const u8,
    project_id: ?[]const u8,
    user_id: ?[]const u8,
    api_key_id: ?[]const u8,
    model: ?[]const u8,
};
pub const UsageModerationsResult = struct {
    object: []const u8,
    input_tokens: i64,
    num_model_requests: i64,
    project_id: ?[]const u8,
    user_id: ?[]const u8,
    api_key_id: ?[]const u8,
    model: ?[]const u8,
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
    result: JsonObjectArray,
};
pub const UsageVectorStoresResult = struct {
    object: []const u8,
    usage_bytes: i64,
    project_id: ?[]const u8,
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
    next: ?[]const u8,
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
pub const UserMessageItemContent = union(enum) {
    input_text: UserMessageInputText,
    quoted_text: UserMessageQuotedText,
    raw: std.json.Value,

    pub fn forInputText(value: UserMessageInputText) UserMessageItemContent {
        return .{ .input_text = value };
    }

    pub fn forQuotedText(value: UserMessageQuotedText) UserMessageItemContent {
        return .{ .quoted_text = value };
    }

    pub fn forRaw(value: std.json.Value) UserMessageItemContent {
        return .{ .raw = value };
    }

    pub fn jsonStringify(self: UserMessageItemContent, writer: anytype) !void {
        switch (self) {
            .input_text => |value| {
                try writer.write(value);
            },
            .quoted_text => |value| {
                try writer.write(value);
            },
            .raw => |value| {
                try writer.write(value);
            },
        }
    }

    pub fn jsonParse(allocator: std.mem.Allocator, source: anytype, options: std.json.ParseOptions) !UserMessageItemContent {
        const parsed = try std.json.Value.jsonParse(allocator, source, options);
        return jsonParseFromValue(allocator, parsed, options);
    }

    pub fn jsonParseFromValue(
        allocator: std.mem.Allocator,
        source: std.json.Value,
        options: std.json.ParseOptions,
    ) !UserMessageItemContent {
        switch (source) {
            .object => |root| {
                const kind = root.get("type") orelse return .{ .raw = source };
                if (kind != .string) return .{ .raw = source };

                if (std.mem.eql(u8, kind.string, "input_text")) {
                    const parsed = std.json.parseFromValue(
                        UserMessageInputText,
                        allocator,
                        source,
                        options,
                    ) catch return .{ .raw = source };
                    defer parsed.deinit();
                    return .{ .input_text = parsed.value };
                }

                if (std.mem.eql(u8, kind.string, "quoted_text")) {
                    const parsed = std.json.parseFromValue(
                        UserMessageQuotedText,
                        allocator,
                        source,
                        options,
                    ) catch return .{ .raw = source };
                    defer parsed.deinit();
                    return .{ .quoted_text = parsed.value };
                }

                return .{ .raw = source };
            },
            else => return .{ .raw = source },
        }
    }
};
pub const UserMessageItem = struct {
    id: []const u8,
    object: []const u8,
    created_at: i64,
    thread_id: []const u8,
    type: []const u8,
    content: []const UserMessageItemContent,
    attachments: []const Attachment,
    inference_options: InferenceOptions,
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
    grader: EvalGraderConfig,
};
pub const ValidateGraderResponse = struct {
    grader: ?EvalGraderConfig,
};
pub const VectorStoreExpirationAfter = struct {
    anchor: []const u8,
    days: i64,
};
pub const VectorStoreFileAttributes = JsonObject;
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
    next_page: ?[]const u8,
};
pub const VectorStoreFileObject = struct {
    id: []const u8,
    object: []const u8,
    usage_bytes: i64,
    created_at: i64,
    vector_store_id: []const u8,
    status: []const u8,
    last_error: ?VectorStoreFileError,
    chunking_strategy: ?ChunkingStrategyResponse,
    attributes: ?VectorStoreFileAttributes,
};

pub const VectorStoreFileError = struct {
    code: ?[]const u8,
    message: ?[]const u8,
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
    expires_at: ?i64,
    last_active_at: ?i64,
    metadata: Metadata,
};
pub const VectorStoreSearchRequest = struct {
    query: []const u8,
    rewrite_query: ?bool,
    max_num_results: ?i64,
    filters: ?Filters,
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
    next_page: ?[]const u8,
};
pub const Verbosity = []const u8;
pub const VideoContentVariant = []const u8;
pub const VideoListResource = struct {
    object: []const u8,
    data: []const VideoResource,
    first_id: ?[]const u8,
    last_id: ?[]const u8,
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
    completed_at: ?i64,
    expires_at: ?i64,
    prompt: ?[]const u8,
    size: VideoSize,
    seconds: VideoSeconds,
    remixed_from_video_id: ?[]const u8,
    _error: ?VideoError,
};

pub const VideoError = struct {
    code: ?[]const u8,
    message: ?[]const u8,
    param: ?[]const u8,
    type: ?[]const u8,
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
    first_id: ?[]const u8,
    last_id: ?[]const u8,
    has_more: bool,
};
pub const VoiceConsentResource = struct {
    object: []const u8,
    id: []const u8,
    name: []const u8,
    language: []const u8,
    created_at: i64,
};
pub const VoiceIdsShared = []const u8;
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
pub const WebSearchApproximateLocation = struct {
    type: ?[]const u8 = null,
    country: ?[]const u8 = null,
    region: ?[]const u8 = null,
    city: ?[]const u8 = null,
    timezone: ?[]const u8 = null,
};
pub const WebSearchContextSize = []const u8;
pub const WebSearchLocation = struct {
    country: ?[]const u8,
    region: ?[]const u8,
    city: ?[]const u8,
    timezone: ?[]const u8,
};
pub const WebSearchPreviewTool = struct {
    type: []const u8,
    user_location: ?WebSearchApproximateLocation,
    search_context_size: ?SearchContextSize,
};
pub const WebSearchTool = struct {
    type: []const u8,
    filters: ?Filters,
    user_location: ?WebSearchApproximateLocation,
    search_context_size: ?[]const u8,
};
pub const WebSearchToolCall = struct {
    id: []const u8,
    type: []const u8,
    status: []const u8,
    action: JsonObject,
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
    state_variables: ?ResponsePromptVariables,
    tracing: ?WorkflowTracingParam,
};
pub const WorkflowTracingParam = struct {
    enabled: ?bool,
};
