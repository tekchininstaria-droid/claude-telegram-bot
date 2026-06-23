FROM oven/bun:1
RUN apt-get update \
    && apt-get install -y --no-install-recommends nodejs npm git ca-certificates ripgrep openssh-client \
    && rm -rf /var/lib/apt/lists/*
RUN npm install -g @anthropic-ai/claude-code
WORKDIR /app
COPY package.json bun.lockb* ./
RUN bun install --frozen-lockfile || bun install
COPY . .
RUN chmod +x /app/entrypoint.sh
ENV HOME=/root
# entrypoint syncs claude-config into /root/.claude, then runs the CMD (the bot)
ENTRYPOINT ["/app/entrypoint.sh"]
CMD ["bun", "run", "src/index.ts"]
