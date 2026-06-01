# UnrealClaude - Claude Code Instructions for Unreal Engine

This file provides guidance to Claude Code when working with the UnrealClaude plugin.

## Project Attribution

This project is based on [UnrealClaude](https://github.com/Natfii/UnrealClaude) by Natali Caggiano.
Customizations include:
- Automated build/deploy scripts (Build.ps1, Deploy.ps1)
- Traditional Chinese documentation (README_ZH.md)
- UE 5.6/5.7 compatibility support

## Setup

Copy this file to `CLAUDE.md` in your Unreal project root and customize the build paths.

## Build Commands

For automated build:

```powershell
# Auto-detect UE version
.\Build.ps1

# Specify version
.\Build.ps1 -Version 5.7
.\Build.ps1 -Version 5.6

# Clean build
.\Build.ps1 -Clean
```

For deployment:

```powershell
# Deploy to engine marketplace
.\Deploy.ps1 -Target Engine

# Deploy to project plugins
.\Deploy.ps1 -Target Project -ProjectPath "C:\YourProject"
```

## Project Overview

**UnrealClaude** is an Unreal Engine plugin that provides MCP integration, enabling Claude AI to interact directly with the Unreal Editor.

### MCP Tool Priority

When working with Unreal Editor content, ALWAYS prefer MCP tools over filesystem tools:
- Use `asset_search` instead of Glob/Grep to find assets
- Use `spawn_actor` instead of writing Python scripts to create actors
- Use `get_level_actors` instead of reading level files to see what's in a scene

### Domain Tools

Use the domain router for complex operations:
- `unreal_ue` with `domain: "blueprint"` - Blueprint modification
- `unreal_ue` with `domain: "anim"` - Animation Blueprint
- `unreal_ue` with `domain: "asset"` - Asset operations
- `unreal_ue` with `domain: "material"` - Material editing

## Supported Features

| Feature | Status |
|---------|--------|
| UE 5.7 | ✅ Fully Tested |
| UE 5.6 | ⚠️ Requires Engine Fix |
| MCP Bridge | ✅ |
| PCG Integration | 🔜 Planned |

## Notes

- UE 5.6 builds may fail due to missing BuildRules in the engine installation
- For UE 5.6, either fix the engine or use UE 5.7
- All MCP tools operate on live editor state, not serialized files

## Attribution

Based on original work by [Natali Caggiano](https://github.com/Natfii)