#!/bin/sh
# TPS Agent plugin: session-start sign-in reminder.
#
# Purpose: when the TPS Agent connector is installed but not signed in, show the
# user one line telling them how to sign in. Called by Claude Code at session
# start through hooks/hooks.json.
#
# Intent: installing the plugin does not start the sign-in. Claude Code only
# lists the connector as needing authentication when asked, so a new user saw
# tools fail with no hint of what to do.
#
# Pattern decision: ask the CLI for the connector's own status instead of
# printing the reminder every session, so a signed-in user never sees it. Any
# doubt (no `claude` on PATH, a status this script does not recognise, an
# error) stays silent: a reminder that cannot tell is noise, and this hook must
# never block or fail a session. It prints a message and does not open a
# browser, because a hook has no terminal for the sign-in command to use.
command -v claude >/dev/null 2>&1 || exit 0
status=$(claude mcp get "plugin:tps-agent:tps-agent" 2>/dev/null) || exit 0
case "$status" in
  *"Needs authentication"*)
    printf '%s\n' '{"systemMessage":"TPS Agent is installed but not signed in. Run this in a terminal: claude mcp login plugin:tps-agent:tps-agent   Your browser opens on TPS: sign in, then choose Allow connection. Inside Claude Code you can also run /mcp and pick tps-agent."}'
    ;;
esac
exit 0
