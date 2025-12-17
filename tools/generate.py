#!/usr/bin/env python3
"""
OpenAPI → IR + typed schema outlines.

Reads spec/openapi.documented.yml and produces:
  - generated/ir.json (normalized operations + schemas)
  - generated/types.zig (coarse Zig type hints from schemas)

This is for inspection and future codegen; it no longer emits stub resources.
"""

from __future__ import annotations

import argparse
import json
import pathlib
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


def sanitize_ident(name: str) -> str:
    out = []
    for ch in name:
        if ch.isalnum() or ch == "_":
            out.append(ch)
        else:
            out.append("_")
    ident = "".join(out)
    if ident and ident[0].isdigit():
        ident = "_" + ident
    return ident


ZIG_KEYWORDS = {
    "addrspace",
    "align",
    "allowzero",
    "and",
    "anyframe",
    "asm",
    "async",
    "await",
    "break",
    "catch",
    "comptime",
    "const",
    "continue",
    "defer",
    "else",
    "enum",
    "errdefer",
    "error",
    "export",
    "extern",
    "fn",
    "for",
    "if",
    "inline",
    "noalias",
    "nosuspend",
    "or",
    "orelse",
    "packed",
    "pub",
    "resume",
    "return",
    "linksection",
    "struct",
    "suspend",
    "switch",
    "test",
    "threadlocal",
    "try",
    "union",
    "unreachable",
    "usingnamespace",
    "var",
    "volatile",
    "while",
}


def safe_ident(name: str) -> str:
    ident = sanitize_ident(name)
    if ident in ZIG_KEYWORDS:
        ident = "_" + ident
    return ident


def collect_parameters(
    raw_params: List[Dict[str, Any]],
) -> Dict[str, List[Dict[str, Any]]]:
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


def normalize_operation(
    path: str, method: str, op: Dict[str, Any], inherited_params: List[Dict[str, Any]]
):
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
            normalized[status] = {
                "description": resp.get("description"),
                "content": entries,
            }
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
            if method.lower() not in {
                "get",
                "post",
                "put",
                "patch",
                "delete",
                "options",
                "head",
            }:
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
    (out_dir / "ir.json").write_text(
        json.dumps(ir, indent=2, ensure_ascii=False), encoding="utf-8"
    )


def zig_type_from_schema(name: str, schema: Dict[str, Any]) -> str:
    """Coarse mapper from OpenAPI schema to Zig type string. Falls back to std.json.Value."""
    DYNAMIC_SCHEMAS = {
        # These responses are too loose in practice; keep them fully dynamic.
        "CreateChatCompletionResponse",
    }
    OPTIONAL_SCHEMAS = {
        # Chat completions responses are loosely specified in practice; treat fields as optional.
        "CreateChatCompletionResponse",
        "ChatCompletionResponseMessage",
        "ChatCompletionMessageList",
        "ChatCompletionList",
    }
    if name in DYNAMIC_SCHEMAS:
        return "std.json.Value"
    if not schema:
        return "std.json.Value"
    if "$ref" in schema:
        ref = schema["$ref"].split("/")[-1]
        return safe_ident(ref)
    t = schema.get("type")
    if t == "string":
        return "[]const u8"
    if t == "integer":
        return "i64"
    if t == "number":
        return "f64"
    if t == "boolean":
        return "bool"
    if t == "array":
        item_ty = zig_type_from_schema(name + "_item", schema.get("items") or {})
        return "[]const " + item_ty
    if t == "object":
        props = schema.get("properties") or {}
        required = set(schema.get("required") or [])
        if name in OPTIONAL_SCHEMAS:
            required = set()
        if not props:
            return "std.json.Value"
        fields = []
        for prop_name, prop_schema in props.items():
            field_name = safe_ident(to_snake(prop_name))
            field_ty = zig_type_from_schema(prop_name, prop_schema)
            if prop_name not in required:
                field_ty = "?" + field_ty
            fields.append(f"    {field_name}: {field_ty},")
        return "struct {\n" + "\n".join(fields) + "\n}"
    if "enum" in schema:
        return "[]const u8"
    if "anyOf" in schema or "oneOf" in schema or "allOf" in schema:
        return "std.json.Value"
    if schema.get("nullable"):
        inner = zig_type_from_schema(
            name, {k: v for k, v in schema.items() if k != "nullable"}
        )
        return "?" + inner
    return "std.json.Value"


def emit_schema_types(ir: Dict[str, Any], out_dir: pathlib.Path) -> None:
    out_dir.mkdir(parents=True, exist_ok=True)
    path = out_dir / "types.zig"
    lines = ['const std = @import("std");', ""]
    for name, schema in sorted(ir["schemas"].items()):
        ident = safe_ident(name)
        ty = zig_type_from_schema(name, schema)
        lines.append(f"pub const {ident} = {ty};")
    path.write_text("\n".join(lines) + "\n", encoding="utf-8")


def main() -> None:
    parser = argparse.ArgumentParser(
        description="Generate IR and type hints from OpenAPI spec"
    )
    parser.add_argument(
        "--spec", type=pathlib.Path, default=pathlib.Path("spec/openapi.documented.yml")
    )
    parser.add_argument(
        "--ir-out", type=pathlib.Path, default=pathlib.Path("generated"), help="Directory for ir.json"
    )
    parser.add_argument(
        "--types-out", type=pathlib.Path, default=pathlib.Path("src/generated"), help="Directory for types.zig"
    )
    args = parser.parse_args()

    spec = load_spec(args.spec)
    ir = build_ir(spec)
    write_ir(ir, args.ir_out)
    emit_schema_types(ir, args.types_out)

    print(f"operations: {len(ir['operations'])}")
    print(f"schemas: {len(ir['schemas'])}")
    print(f"IR written to {args.ir_out / 'ir.json'}")
    print(f"Types written to {args.types_out / 'types.zig'}")


if __name__ == "__main__":
    main()
