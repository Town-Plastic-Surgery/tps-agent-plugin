# TPS Agent plugin

Connects Claude to the TPS Agent (https://app.tps-agents.com) and adds the `packets` skill
for building binders and drafting IDR packets in bulk.

## Install (Claude Code)

```
claude plugin marketplace add Town-Plastic-Surgery/tps-agent-plugin
claude plugin install tps-agent@tps
```

Then in Claude Code run `/plugin`, open Marketplaces, select `tps` and turn on auto-update,
so new versions arrive at the next session start. Run `/mcp`, choose `tps-agent` and sign
in with your TPS account.

Use it by asking, for example, "start binders for 11/23 through 11/30", or run
`/tps-agent:packets`.

## Releasing

Bump `version` in `plugins/tps-agent/.claude-plugin/plugin.json` on every change. Users
receive nothing until the version changes.
