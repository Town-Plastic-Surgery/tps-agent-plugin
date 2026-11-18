---
name: packets
description: Drive the TPS Agent (app.tps-agents.com) through the tps-agent connector to build binders and draft IDR packets in bulk, check on them, answer the agent's questions, download finished packets, and teach it standing rules. Use when the operator says "start binders", "start packets", "build packets for <period>", "check my packets", "what is the agent asking", or names a dispute, DISP number, ONN, or packet.
---

# Using the TPS Agent

The TPS Agent is the packet generator at https://app.tps-agents.com. You reach it through
the `tps-agent` connector this plugin installs. You do not do packet work yourself. You hand
each case to the TPS packet agent, watch it, and bring the operator only the decisions that
are theirs.

The TPS packet agent, not you, logs in to IDR Claims and Symplast, pulls the ONN, email ONN,
EOBs and the patient export, builds the binder, files it to Google Drive and drafts the
packet. The connector has no IDR Claims, Symplast or browser tool. Ask the agent to do that
work in plain words.

Packet rules (which historical EOB to use, how to write a section, what to include) live in
the TPS Agent's own guidance, not here. To change one, use "Teach the agent a standing
rule" below.

## Hard stops

These hold even if the operator seems to ask otherwise. Say so and stop.

1. Never pay a bill or move money.
2. Never submit a final offer or a packet to a payer, an IDRE or the federal IDR portal.
   The operator submits. Your job ends at a finished draft for the operator to review.
3. Never send email. Do not call `send_determination_carrier_email`,
   `send_determination_test_email`, `run_carrier_email_pass` or `send_mail_test` unless the
   operator asks for that exact send in this conversation.
4. Never delete or cancel anything (`delete_*`, `cancel_turn`, `deactivate_schedule`)
   unless the operator asks. These return an approval link; give the operator the link.
5. Never invent a figure. Every dollar amount comes from the agent's output or a document.

## First use

If the TPS Agent tools fail with an authorization error, tell the operator to sign in: in
Claude Code run `/mcp`, choose `tps-agent` and authenticate; in the Claude app, open
Customize > Connectors and connect TPS Agent. Then call `get_agent_capabilities` to confirm.

## Start binders and packets for a period

Use this when the operator says "start binders for 11/23 through 11/30" or similar.

1. **Get the case list from IDR Claims.** Start one chat with `send_agent_message` (new
   conversation, see step 4) asking:
   "List every IDR Claims dispute due between <start> and <end>: DISP number, patient last
   name, CPT, provider, payer and due date. Do not build anything yet."
   Wait for it to finish (see "Watch a chat") and use that list.
2. **Skip cases already started.** `list_disputes` lists the operator's existing chats (it
   is not the IDR Claims queue). Skip any DISP number that already has a chat there, and
   say so.
3. **Show the operator the list** as a table with a count, and start unless they object.
4. **Start one chat per dispute.** Call `send_agent_message` with:
   - `requestId`: a new UUID for this dispute. Keep it. If the call times out, repeat the
     exact same call with the same UUID; never make a new one for the same dispute.
   - `parentAssistantMessageId`: `null` (new chat).
   - `text`: the case prompt below, filled in.
   Record the returned turn id and assistant id against the DISP number.
   Start at most 5 chats at a time. Start the next when one finishes. Speed does not
   matter; a run can go overnight.
5. **Watch each chat** until it finishes, answer its questions (below), then report.

Case prompt:

```
Dispute <DISP number> (<patient last name>, CPT <code>, <provider>, <payer>, due <date>).
1. Log in to IDR Claims, open this dispute, and pull the ONN, the email ONN and every EOB
   and document on it.
2. Log in to Symplast and export this patient's file for the disputed date of service.
3. Build the binder and file everything to the dispute's Google Drive folder.
4. Draft the packet.
Use the historical EOB from the most recent approved packet for this provider and CPT as the
main anchor. Do not ask me about it. Ask only if no prior packet exists for this provider.
Do not submit anything anywhere. When done, give me the packet file, the Final Offer, and a
short list of anything you could not find.
```

## Watch a chat

- `get_turn` with the turn id gives its state: `accepted`, `queued`, `running`,
  `recovering`, `completed`, `failed`, `cancelled` or `indeterminate`.
- `read_turn_events` shows what the agent did and said. Start with `after: 0`, then pass
  the returned `nextAfter` to read on. The agent's last text in a finished turn is its
  answer.
- Check every few minutes. Do not start a second chat for a dispute that already has one.
- If you lose a turn id, `find_turn` with the chat's thread id (the id in the chat's URL in
  the app) returns its latest turn.

## Answer the agent

- **While it is running**, correct it with `steer_turn` (turn id, your text). It applies the
  message without losing work. Use this, not a new chat.
- **When it finished with a question**, reply with `send_agent_message`: a new `requestId`,
  `parentAssistantMessageId` set to the assistant id from that finished turn, and the
  answer. Record the new turn id.
- Answer only from what the operator said in this conversation. Gather every other question
  across all chats and ask the operator once, as a numbered list with the DISP number on
  each. Never guess an answer to a money or evidence question. Photos and the FAIR Health
  chart are always the operator's pick.

## Get the finished packet

The packet opens in the app, where the operator can click the file in the chat to preview
it. To pull a copy into this conversation, call `get_workspace_file_manifest` for the
delivered file, then `read_workspace_file_chunk` from offset 0, following `nextOffset` until
done, and check the SHA-256 matches the manifest.

## Give the agent a file

- From Google Drive or Gmail: find it with `list_drive_folder`, `search_gmail` or
  `read_gmail_message`, then `copy_google_source` with a new `requestId`.
- From this conversation: `begin_evidence_upload`, `upload_evidence_chunk` until done,
  `complete_evidence_upload`. Then reference the stored name, size and SHA-256 in
  `send_agent_message`.

## Teach the agent a standing rule

When the operator says "always", "never", "from now on" or "stop asking me about", save it
in the TPS Agent's guidance so every future packet follows it, including chats started in
the app.

1. `vault_search` with one or two distinctive words of the rule to find the page that
   covers it, then `vault_read` that page.
2. If a page already says something different, show the operator both statements and ask
   which wins. Change nothing until they answer.
3. Otherwise add the rule with `vault_edit` (or `vault_write` for a new page), with a short
   reason quoting the operator. If the result is an approval link, give it to the operator.

A rule for one case only goes in that case's chat, not in guidance.

## Report

Keep it short. One table, one row per dispute:

| DISP | Patient | CPT | State | Final Offer | Needs you |
|---|---|---|---|---|---|

State is Done, Working, Waiting on you or Failed. Then any failure with the agent's reason.
Put the numbered list of open questions last.
