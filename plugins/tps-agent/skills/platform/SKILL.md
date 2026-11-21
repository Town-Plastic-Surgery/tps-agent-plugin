---
name: platform
description: Work the TPS platform's records through the tps-agent connector, beyond packets. Use when the operator asks about received determinations (find one, why we lost one, which losses share a reason, mark paid, carrier follow-up emails), the directory (carriers, aliases, contacts, providers, IDREs, CSV imports), patients and match reviews, scheduled runs, or practice numbers and FAIR Health charts.
---

# TPS platform work

The TPS Agent's own guidance, in its vault, holds the rules for every kind of platform
work: which tool to use, in what order, what needs a human, and what never reaches a packet.
The TPS packet agent follows those pages. Follow the same pages, so you and the agent work
the same way. They are not copied here, because a copy would drift.

## Before the first call for a kind of work

1. `vault_read` `reference/tool-map.md`. It names the skill for each tool family.
2. `vault_read` that skill (for example `skills/managing-determinations/SKILL.md`), and any
   sub-page it tells you to read for the step you are on.
3. Follow it. Where it speaks to "the agent", it means whoever calls the tools, so it means
   you.

Read the pages once per conversation for each kind of work. If a page changes while you
work, the newest version wins.

## Or hand it to the agent

Anything you can do here, the TPS packet agent can do in a chat. Start one with
`send_agent_message` and watch it as the `packets` skill describes. Hand it over when the
work needs a letter read, a site visited (IDR Claims, Symplast, Drive) or many steps.

## Hard stops

The `packets` skill's hard stops apply here too: never move money, never submit anything to
a payer, an IDRE or the federal portal, never send email or delete anything unless the
operator asks for that exact action in this conversation, and never invent a figure. When a
call returns a TPS approval link, give it to the operator.

## Examples

- "Why did we lose DISP-8088269?": read `skills/managing-determinations/loss-analysis.md`,
  then `read_determination` and answer from its recorded reasons, quotes and factor weights.
- "Which losses were defaults?": `search_determinations` with `lossReason`
  `no_offer_or_fee`, following every page.
- "Add this alias to Cigna": read `skills/managing-the-directory/SKILL.md` first; aliases
  change how every later letter is matched.
