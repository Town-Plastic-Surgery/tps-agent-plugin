# TPS Agent plugin

Connects Claude to the TPS Agent (https://app.tps-agents.com) and adds the `packets` skill
for building binders and drafting IDR packets in bulk.

## Install (Claude Code)

One command, in a terminal:

```
claude plugin install tps-agent --marketplace Town-Plastic-Surgery/tps-agent-plugin
```

Then sign in once:

```
claude mcp login plugin:tps-agent:tps-agent
```

Your browser opens on TPS. Sign in with your TPS account and choose "Allow connection".
There is nothing to copy or paste. If you skip this step, Claude Code reminds you at the
start of each session until you are signed in. Inside Claude Code you can also run `/mcp`,
choose `tps-agent` and authenticate.

Use it by asking, for example, "start binders for 11/23 through 11/30", or run
`/tps-agent:packets`. Through the connector you can do what your own TPS account can do in
the app.

To get new versions automatically, run `/plugin` in Claude Code, open Marketplaces, select
`tps` and turn on auto-update.

To disconnect, open Settings in the TPS app, go to AI connections and disconnect Claude
Code.

## Releasing

Bump `version` in `plugins/tps-agent/.claude-plugin/plugin.json` on every change. Users
receive nothing until the version changes.
