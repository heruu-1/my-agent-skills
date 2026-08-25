# Agent compatibility

The source layout follows the Agent Skills convention: each skill is a directory containing `SKILL.md` with `name` and `description` metadata.

| Agent | Supported path or package | Verification status |
| --- | --- | --- |
| Codex | `.agents/skills`, `.codex-plugin` | local junction verified; public `npx skills --list` smoke test passed |
| Claude Code | `.claude/skills`, `.claude-plugin` | manifest and junction verified; native CLI unavailable on the validation host |
| Gemini CLI | `.agents/skills` | native discovery passed with 39 shared skills and no duplicate conflicts |
| Cursor | `.cursor/skills` | global junction target verified |
| Vercel Skills CLI | public repository adapter | public repository discovery passed with all 39 skills |

Vendor-specific options such as Cursor `paths` or `disable-model-invocation` belong in generated adapters, not universal source frontmatter.
