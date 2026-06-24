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
  printf '%s' "$CLAUDE_CONFIG_DEPLOY_KEY_B64" | tr -d '[:space:]' | base64 -d > /root/.ssh/claude_config_deploy
  chmod 600 /root/.ssh/claude_config_deploy
  export GIT_SSH_COMMAND="ssh -i /root/.ssh/claude_config_deploy -o IdentitiesOnly=yes -o StrictHostKeyChecking=accept-new"
fi

echo "[entrypoint] syncing claude-config from $CONFIG_REPO ..."
if [ -d "$CONFIG_DIR/.git" ]; then
  # Hard-reset to origin/main: the checkout is disposable, so a locally-dirty
  # file (e.g. servers.sh) must never block updates the way `pull --ff-only` did.
  if git -C "$CONFIG_DIR" fetch --depth 1 origin main; then
    git -C "$CONFIG_DIR" reset --hard origin/main || echo "[entrypoint] reset failed, using existing checkout"
  else
    echo "[entrypoint] fetch failed, using existing checkout"
  fi
else
  git clone --depth 1 "$CONFIG_REPO" "$CONFIG_DIR" || echo "[entrypoint] clone failed (config not applied)"
fi

if [ -f "$CONFIG_DIR/install.sh" ]; then
  # INSTALL_SETTINGS=0 -> only link skills/agents/commands + register MCP servers;
  # keep the container's own auth and settings untouched.
  INSTALL_SETTINGS=0 bash "$CONFIG_DIR/install.sh" || echo "[entrypoint] install.sh failed, continuing"
fi

# Give the bot's Claude git access to GitHub over HTTPS using a PAT. Stored in
# the container's ephemeral /root (not a volume), re-created each boot. Does not
# touch the git@github.com SSH path used to clone claude-config above.
if [ -n "${GITHUB_TOKEN:-}" ]; then
  git config --global credential.helper store
  printf 'https://x-access-token:%s@github.com\n' "$GITHUB_TOKEN" > /root/.git-credentials
  chmod 600 /root/.git-credentials
  git config --global user.name "${GIT_AUTHOR_NAME:-claude-tg}"
  git config --global user.email "${GIT_AUTHOR_EMAIL:-tekchininstaria@gmail.com}"
  echo "[entrypoint] configured GitHub HTTPS credentials for git"
fi

# Seed the vault with the assistant brain + memory structure on first boot.
# cp -n never overwrites, so anything I've since edited in Obsidian is preserved;
# only missing files (e.g. a brand-new vault) get the starter scaffold.
if [ -d /app/vault-seed ] && [ -d /vault ]; then
  cp -rn /app/vault-seed/. /vault/ 2>/dev/null || true
  echo "[entrypoint] seeded vault scaffold (missing files only)"
fi

exec "$@"
