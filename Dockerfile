FROM oven/bun:1
RUN apt-get update \
    && apt-get install -y --no-install-recommends nodejs npm git ca-certificates ripgrep \
    && rm -rf /var/lib/apt/lists/*
RUN npm install -g @anthropic-ai/claude-code
WORKDIR /app
COPY package.json bun.lockb* ./
RUN bun install --frozen-lockfile || bun install
COPY . .
ENV HOME=/root
CMD ["bun", "run", "src/index.ts"]
