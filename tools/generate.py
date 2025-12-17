#!/usr/bin/env python3
"""
Minimal OpenAPI → IR → Zig stub generator.
Reads spec/openapi.documented.yml and produces:
  - generated/ir.json (normalized operations + schemas)
  - stub resource files for a small set of tags to keep the SDK compiling

This is intentionally conservative: it resolves parameters/requestBody/responses
into a small IR without attempting to fully lower schemas. The goal is to have
an inspectable IR and a starting point for fleshing out models and resources.
"""
from __future__ import annotations

import argparse
import json
import pathlib
from collections import defaultdict
from typing import Any, Dict, List, Optional

import yaml


def load_spec(path: pathlib.Path) -> Dict[str, Any]:
    with path.open("r", encoding="utf-8") as f:
        return yaml.safe_load(f)


def to_snake(name: str) -> str:
    out = []
    for i, ch in enumerate(name):
        if ch.isupper() and i > 0:
            out.append("_")
        out.append(ch.lower())
    return "".join(out)


def collect_parameters(raw_params: List[Dict[str, Any]]) -> Dict[str, List[Dict[str, Any]]]:
    grouped: Dict[str, List[Dict[str, Any]]] = {"path": [], "query": [], "header": []}
    for p in raw_params:
        location = p.get("in")
        if location not in grouped:
            continue
        grouped[location].append(
            {
                "name": p.get("name"),
                "required": bool(p.get("required")),
                "schema": p.get("schema") or {},
                "description": p.get("description"),
            }
        )
    return grouped


def normalize_operation(path: str, method: str, op: Dict[str, Any], inherited_params: List[Dict[str, Any]]):
    params = collect_parameters(inherited_params + op.get("parameters", []))

    def normalize_request_body(body: Dict[str, Any]) -> Optional[Dict[str, Any]]:
        if not body:
            return None
        content = body.get("content") or {}
        entries = []
        for ctype, schema in content.items():
            entries.append({"content_type": ctype, "schema": schema.get("schema")})
        return {"required": bool(body.get("required")), "content": entries}

    def normalize_responses(raw: Dict[str, Any]) -> Dict[str, Any]:
        normalized = {}
        for status, resp in raw.items():
            content = resp.get("content") or {}
            entries = []
            for ctype, schema in content.items():
                entries.append({"content_type": ctype, "schema": schema.get("schema")})
            normalized[status] = {"description": resp.get("description"), "content": entries}
        return normalized

    return {
        "id": op.get("operationId"),
        "method": method.upper(),
        "path": path,
        "tag": (op.get("tags") or ["default"])[0],
        "summary": op.get("summary"),
        "description": op.get("description"),
        "parameters": params,
        "request_body": normalize_request_body(op.get("requestBody") or {}),
        "responses": normalize_responses(op.get("responses") or {}),
        "security": op.get("security"),
    }


def build_ir(spec: Dict[str, Any]) -> Dict[str, Any]:
    operations = []
    for path, path_item in spec.get("paths", {}).items():
        if not isinstance(path_item, dict):
            continue
        inherited_params = path_item.get("parameters", [])
        for method, op in path_item.items():
            if method.lower() not in {"get", "post", "put", "patch", "delete", "options", "head"}:
                continue
            if not isinstance(op, dict):
                continue
            if not op.get("operationId"):
                continue
            operations.append(normalize_operation(path, method, op, inherited_params))

    schemas = spec.get("components", {}).get("schemas", {})
    return {"info": spec.get("info"), "operations": operations, "schemas": schemas}


def write_ir(ir: Dict[str, Any], out_dir: pathlib.Path) -> None:
    out_dir.mkdir(parents=True, exist_ok=True)
    (out_dir / "ir.json").write_text(json.dumps(ir, indent=2, ensure_ascii=False), encoding="utf-8")


STUB_TAGS = {"Audio", "Chat", "Models", "Files"}


def emit_stub_resources(ir: Dict[str, Any], src_dir: pathlib.Path) -> None:
    resources_dir = src_dir / "resources"
    resources_dir.mkdir(parents=True, exist_ok=True)

    operations_by_tag: Dict[str, List[Dict[str, Any]]] = defaultdict(list)
    for op in ir["operations"]:
        operations_by_tag[op["tag"]].append(op)

    for tag, ops in operations_by_tag.items():
        if tag not in STUB_TAGS:
            continue
        name_snake = to_snake(tag)
        zig_path = resources_dir / f"{name_snake}.zig"
        with zig_path.open("w", encoding="utf-8") as f:
            f.write(
                """const errors = @import("../errors.zig");
const transport_mod = @import("../transport/http.zig");

pub const Resource = struct {
    transport: *transport_mod.Transport;

    pub fn init(transport: *transport_mod.Transport) Resource {
        return Resource{ .transport = transport };
    }

"""
            )
            for op in ops:
                fn_name = to_snake(op["id"])
                f.write(f"    pub fn {fn_name}(self: *const Resource) errors.Error!void {{\n")
                f.write("        _ = self;\n")
                f.write(f"        return errors.unimplemented(\"{tag}.{op['id']}\");\n")
                f.write("    }\n\n")
            f.write("};\n")

    # Master resources.zig that re-exports generated stubs.
    aggregator = [
        'const audio_mod = @import("resources/audio.zig");',
        'const chat_mod = @import("resources/chat.zig");',
        'const models_mod = @import("resources/models.zig");',
        'const files_mod = @import("resources/files.zig");',
        "",
        "pub const audio = audio_mod;",
        "pub const chat = chat_mod;",
        "pub const models = models_mod;",
        "pub const files = files_mod;",
        "",
        "pub const AudioResource = audio_mod.Resource;",
        "pub const ChatResource = chat_mod.Resource;",
        "pub const ModelsResource = models_mod.Resource;",
        "pub const FilesResource = files_mod.Resource;",
        "",
    ]
    (src_dir / "resources.zig").write_text("\n".join(aggregator), encoding="utf-8")


def main() -> None:
    parser = argparse.ArgumentParser(description="Generate Zig SDK stubs from OpenAPI spec")
    parser.add_argument("--spec", type=pathlib.Path, default=pathlib.Path("spec/openapi.documented.yml"))
    parser.add_argument("--out", type=pathlib.Path, default=pathlib.Path("generated"))
    parser.add_argument("--src", type=pathlib.Path, default=pathlib.Path("src"))
    args = parser.parse_args()

    spec = load_spec(args.spec)
    ir = build_ir(spec)
    write_ir(ir, args.out)
    emit_stub_resources(ir, args.src)

    print(f"operations: {len(ir['operations'])}")
    print(f"schemas: {len(ir['schemas'])}")
    print(f"stub tags: {', '.join(sorted(STUB_TAGS))}")
    print(f"IR written to {args.out/'ir.json'}")


if __name__ == "__main__":
    main()
