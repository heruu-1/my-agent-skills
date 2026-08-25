# Agent compatibility

The source layout follows the Agent Skills convention: each skill is a directory containing `SKILL.md` with `name` and `description` metadata.

| Agent | Supported path or package | Verification status |
| --- | --- | --- |
| Codex | `.agents/skills`, `.codex-plugin` | deterministic local validation |
| Claude Code | `.claude/skills`, `.claude-plugin` | manifest present; CLI smoke test required |
| Gemini CLI | `.agents/skills` or native Gemini install | native smoke test required |
| Cursor | `.cursor/skills` | path discovery smoke test required |
| Vercel Skills CLI | public repository adapter | pin CLI version before CI use |

Vendor-specific options such as Cursor `paths` or `disable-model-invocation` belong in generated adapters, not universal source frontmatter.
