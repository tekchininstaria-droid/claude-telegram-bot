#!/usr/bin/env bash
# Sync the portable Claude config (skills/agents/commands + MCP servers) into the
# persistent /root/.claude volume on every boot, then start the bot.
# Everything here is best-effort: a failure never blocks the bot from starting.
set -uo pipefail

CONFIG_REPO="${CLAUDE_CONFIG_REPO:-git@github.com:tekchininstaria-droid/claude-config.git}"
CONFIG_DIR=/root/.claude/claude-config

# Materialize the read-only deploy key (base64 in env) so we can clone the
# private claude-config repo over SSH.
if [ -n "${CLAUDE_CONFIG_DEPLOY_KEY_B64:-}" ]; then
  mkdir -p /root/.ssh && chmod 700 /root/.ssh
  printf '%s' "$CLAUDE_CONFIG_DEPLOY_KEY_B64" | base64 -d > /root/.ssh/claude_config_deploy
  chmod 600 /root/.ssh/claude_config_deploy
  export GIT_SSH_COMMAND="ssh -i /root/.ssh/claude_config_deploy -o IdentitiesOnly=yes -o StrictHostKeyChecking=accept-new"
fi

echo "[entrypoint] syncing claude-config from $CONFIG_REPO ..."
if [ -d "$CONFIG_DIR/.git" ]; then
  git -C "$CONFIG_DIR" pull --ff-only || echo "[entrypoint] pull failed, using existing checkout"
else
  git clone --depth 1 "$CONFIG_REPO" "$CONFIG_DIR" || echo "[entrypoint] clone failed (config not applied)"
fi

if [ -f "$CONFIG_DIR/install.sh" ]; then
  # INSTALL_SETTINGS=0 -> only link skills/agents/commands + register MCP servers;
  # keep the container's own auth and settings untouched.
  INSTALL_SETTINGS=0 bash "$CONFIG_DIR/install.sh" || echo "[entrypoint] install.sh failed, continuing"
fi

exec "$@"
