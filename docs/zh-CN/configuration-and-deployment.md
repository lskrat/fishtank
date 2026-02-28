# 配置与部署指南 (Configuration & Deployment)

本文档详细介绍 OpenClaw 的配置文件 `openclaw.json` 以及生产环境的部署方案。

## 1. 配置文件详解 (Configuration Reference)

OpenClaw 的主配置文件通常位于 `~/.openclaw/openclaw.json`。

### 基础结构

```json
{
  "gateway": { ... },
  "agents": { ... },
  "channels": { ... },
  "skills": { ... },
  "models": { ... }
}
```

### 关键配置项

#### Gateway (网关)

```json
"gateway": {
  "port": 18789,
  "mode": "local", // local 或 remote
  "bind": "loopback", // loopback (127.0.0.1), lan (0.0.0.0), tailnet
  "auth": {
    "mode": "token", // token, password, trusted-proxy
    "token": "your-secret-token"
  }
}
```

#### Agents (智能体)

定义 Agent 的行为和默认模型。

```json
"agents": {
  "defaults": {
    "model": "openai/gpt-4o",
    "temperature": 0.7
  },
  "list": [
    {
      "id": "main",
      "name": "My Assistant",
      "skills": ["web-search", "calculator"]
    }
  ]
}
```

#### Channels (渠道)

配置各个消息渠道的凭证。

```json
"channels": {
  "telegram": {
    "enabled": true,
    "token": "YOUR_TELEGRAM_BOT_TOKEN"
  },
  "discord": {
    "enabled": true,
    "token": "YOUR_DISCORD_BOT_TOKEN"
  }
}
```

#### Models (模型)

配置 LLM 提供商。

```json
"models": {
  "openai": {
    "apiKey": "sk-..."
  },
  "anthropic": {
    "apiKey": "sk-ant-..."
  }
}
```

## 2. 生产环境部署 (Deployment Guide)

### Docker 部署

推荐使用 Docker 进行生产环境部署。

**Dockerfile 示例**:

```dockerfile
FROM node:22-slim

WORKDIR /app

# 安装依赖
COPY package.json pnpm-lock.yaml ./
RUN npm install -g pnpm && pnpm install --prod

# 复制源码
COPY . .

# 构建
RUN pnpm build

# 暴露端口
EXPOSE 18789

# 启动
CMD ["node", "dist/index.js", "gateway", "run"]
```

**运行命令**:

```bash
docker run -d \
  -p 18789:18789 \
  -v ~/.openclaw:/root/.openclaw \
  --name openclaw \
  openclaw-image
```

### PM2 部署

如果你在裸机或虚拟机上运行，可以使用 PM2 进行进程管理。

1.  **安装 PM2**: `npm install -g pm2`
2.  **启动**:
    ```bash
    pm2 start dist/index.js --name openclaw -- gateway run
    ```
3.  **保存**: `pm2 save`
4.  **开机自启**: `pm2 startup`

### 环境变量

OpenClaw 支持通过环境变量覆盖配置，这在容器化部署中非常有用。

*   `OPENCLAW_GATEWAY_TOKEN`: 覆盖 `gateway.auth.token`
*   `OPENCLAW_MODEL_OPENAI_API_KEY`: 覆盖 OpenAI API Key
*   `OPENCLAW_CHANNEL_TELEGRAM_TOKEN`: 覆盖 Telegram Token

### 反向代理 (Nginx)

建议在 Gateway 前部署 Nginx 处理 SSL 和负载均衡。

```nginx
server {
    listen 443 ssl;
    server_name gateway.example.com;

    location / {
        proxy_pass http://localhost:18789;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host $host;
    }
}
```
