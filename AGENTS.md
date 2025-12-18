# OpenAI Zig SDK - Agent Guide

This document provides essential information for AI agents working in this repository.

## Project Overview

This is an **in-progress Zig SDK** for the OpenAI API, generated from `spec/openapi.documented.yml`. It includes a minimal runtime and several implemented endpoints to validate the transport/JSON path.

- **Language**: Zig 0.15.x (see `minimum_zig_version` in `build.zig.zon`)
- **Purpose**: OpenAI API client library
- **Status**: Runtime implemented; many resources are stubs; generator can overwrite stubs.

## Essential Commands

All commands should be run from the project root.

### Build
```sh
zig build          # compile the library and demo executable
```

### Run the demo
```sh
zig build run      # runs `src/main.zig` (models list + chat completion)
```

### Run examples
```sh
zig build -Dexamples=true run-examples  # builds and runs all examples
zig build -Dexamples=true run-<name>    # runs a single example (e.g., `run-models_list`)
```

Available example names (see `build.zig`):
- `models_list`
- `chat_completion`
- `chat_multiturn`
- `chat_json_extract`
- `files_list`
- `chat_list`
- `audio_speech`

### Testing
```sh
zig build test     # runs all test blocks (currently only one client‑init test)
```

Tests are defined as inline `test` blocks in source files (Zig's built‑in test framework). The build script creates two test executables (module and executable) and runs them in parallel.

### Code Formatting
```sh
zig fmt .          # format all Zig files in the project
```

## Configuration

The SDK reads a TOML config file at `config/config.toml` (relative to project root). Example:

```toml
api_key = "sk-..."
base_url = "https://api.deepseek.com/v1"
model = "deepseek-chat"
```

- `api_key` is required for live API calls.
- `base_url` defaults to DeepSeek if omitted.
- `model` is used by the demo and examples.

If the config file is missing, the defaults above are used.

## Code Organization

```
src/
├── root.zig               # module root (exports everything)
├── lib.zig                # aggregates all submodules
├── client.zig             # main Client struct with resource accessors
├── errors.zig             # error set and error utilities
├── config.zig             # TOML config loader
├── transport/http.zig     # HTTP transport layer
├── resources/             # API resource implementations (one per tag)
│   ├── models.zig         # e.g., models.list_models()
│   ├── chat.zig
│   └── ...
├── generated/types.zig    # generated Zig types from OpenAPI spec
└── main.zig               # demo entry point (models list + chat completion)

examples/                  # standalone example binaries
generated/ir.json         # intermediate representation from generator
tools/generate.py         # generator script (OpenAPI → IR + types)
spec/openapi.documented.yml  # OpenAPI spec
```

## Naming Conventions

- **Types**: PascalCase (`ListModelsResponse`, `ChatMessage`)
- **Fields**: snake_case (`redacted_value`, `created_at`)
- **Functions**: snake_case (`list_models`, `create_chat_completion`)
- **Variables**: snake_case (`resp`, `body`, `allocator`)
- **Constants**: snake_case with `const` (Zig convention)

## Patterns and Conventions

### Memory Management
- Every function that allocates takes an `allocator: std.mem.Allocator` as its first parameter.
- The caller is responsible for freeing memory; use `defer` where appropriate.
- The transport layer uses an arena allocator per request.

### Error Handling
- The SDK defines a custom error set `errors.Error` (see `src/errors.zig`).
- Functions return `errors.Error!T`.
- HTTP errors are logged and returned as `Error.HttpError`.
- JSON parsing errors are mapped to `Error.DeserializeError`.

### JSON Serialization/Deserialization
- Uses `std.json.parseFromSlice` returning `std.json.Parsed(T)`.
- The parsed value must be deinitialized with `.deinit()`.
- Stringify with `std.json.Stringify` and a writer.

### Resource Methods
Each resource file (e.g., `src/resources/models.zig`) exports a `Resource` struct with methods:
- Takes `*const Resource` (or `*Resource`) as first parameter.
- Returns `errors.Error!std.json.Parsed(SomeGeneratedType)`.
- Path parameters are passed as function arguments.
- Request bodies are passed as struct literals.

Example:
```zig
pub fn list_models(
    self: *const Resource,
    allocator: std.mem.Allocator,
) errors.Error!std.json.Parsed(gen.ListModelsResponse)
```

## Generation (OpenAPI Spec)

The project includes a generator that reads the OpenAPI spec and produces:
- `generated/ir.json` (normalized operations + schemas)
- `generated/types.zig` (coarse Zig type hints)

**Important**: The generator will overwrite `src/resources/*.zig` stubs. Avoid running it if you have manual edits in those files until merge logic is added.

### Regenerate
```sh
python3 tools/generate.py
```

## Dependencies

- `zig_toml` (parsing config TOML) – fetched from GitHub via `build.zig.zon`.

No other external dependencies; uses Zig's standard library.

## Gotchas

1. **Generator overwrites stubs** – Do not run `tools/generate.py` if you have manually edited files under `src/resources/`.
2. **Config path** – The config file must be placed at `config/config.toml` (relative to the working directory of the executable).
3. **API key required** – The demo and examples will exit with a helpful message if the API key is missing.
4. **HTTP errors** – The transport currently logs status and body but returns a generic `HttpError`. More detailed error mapping is a planned enhancement.
5. **Unimplemented endpoints** – Many resources are still stubs; calling them returns `Error.Unimplemented`.

## Testing Notes

- Only one test exists (`test "client init/deinit"` in `src/main.zig`).
- The test uses `std.heap.page_allocator` and does not make network calls.
- Future tests should cover JSON parse/stringify and core endpoints (per README).

## Useful References

- `README.md` – project status and basic usage
- `TODO.md` – planned improvements
- `build.zig` – full build configuration (defines examples, tests)
- `src/main.zig` – example of client usage

## Contribution Guidelines (Inferred)

- Follow existing naming and code patterns.
- Use snake_case for functions and variables.
- Pass allocator as first parameter for allocation.
- Handle errors with the SDK's error set.
- Add inline `test` blocks for new functionality.
- Be cautious with the generator; manual edits to resources may be lost.