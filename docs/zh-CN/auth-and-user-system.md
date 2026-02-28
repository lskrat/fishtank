# 用户体系与鉴权指南 (User System & Auth)

本文档详细介绍 OpenClaw 的鉴权机制、如何集成自定义用户体系以及 Session 隔离机制。

## 1. 鉴权流程 (Authentication Flow)

OpenClaw Gateway 支持多种鉴权模式，核心逻辑位于 `src/gateway/auth.ts`。

### 核心鉴权模式

1.  **Token (默认)**: 使用预共享密钥 (PSK) 进行鉴权。客户端在连接时需提供 `token`，Gateway 会将其与配置的 `gateway.auth.token` 进行比对。
2.  **Password**: 类似于 Token，但使用 `password` 字段。
3.  **None**: 不进行鉴权（仅限开发环境）。
4.  **Trusted Proxy (生产推荐)**: 信任上游代理（如 Nginx, Cloudflare Access, Tailscale）传递的身份信息。

### Trusted Proxy 模式详解

在企业级部署中，通常会将 Gateway 部署在零信任网关（如 Cloudflare Access 或 Tailscale）之后。此时，Gateway 本身不处理登录逻辑，而是信任上游代理通过 HTTP Header 传递的用户身份。

配置示例 (`openclaw.json`):

```json
{
  "gateway": {
    "auth": {
      "mode": "trusted-proxy",
      "trustedProxy": {
        "userHeader": "X-Forwarded-User",
        "allowUsers": ["alice@example.com", "bob@example.com"]
      }
    }
  }
}
```

当请求到达 Gateway 时，`authorizeGatewayConnect` 函数会：
1.  检查请求来源 IP 是否在受信任的代理列表中。
2.  读取 `userHeader` 指定的 Header 值（如 `X-Forwarded-User`）。
3.  如果配置了 `allowUsers`，则校验用户是否在白名单中。
4.  如果校验通过，Gateway 将认为该连接属于该用户，并为其创建相应的 Session。

## 2. 集成自定义鉴权 (Integrating Custom Auth)

如果你需要对接企业内部的鉴权系统（如 LDAP, OAuth2），可以通过修改 `src/gateway/auth.ts` 中的 `authorizeGatewayConnect` 函数来实现。

### 修改步骤

1.  打开 `src/gateway/auth.ts`。
2.  找到 `authorizeGatewayConnect` 函数。
3.  在函数开头添加自定义逻辑，例如调用外部 API 验证 Token。

```typescript
// 示例：调用外部 API 验证 Token
async function validateExternalToken(token: string): Promise<string | null> {
  // 实现你的 API 调用逻辑
  // 返回 userId 或 null
}

export async function authorizeGatewayConnect(params: AuthorizeGatewayConnectParams): Promise<GatewayAuthResult> {
  // ... 现有逻辑 ...

  // 添加自定义 Token 验证
  if (params.connectAuth?.token) {
     const userId = await validateExternalToken(params.connectAuth.token);
     if (userId) {
       return { ok: true, method: "token", user: userId };
     }
  }

  // ... 现有逻辑 ...
}
```

**注意**: 修改核心代码可能会导致升级困难。建议优先使用 `trusted-proxy` 模式，将鉴权逻辑剥离到网关层（如 Nginx + Lua 或专门的 Auth Proxy）。

## 3. Session 隔离 (Session Isolation)

OpenClaw 是多用户、多会话的系统。为了保证数据安全，系统通过 `sessionKey` 严格隔离不同用户的上下文。

### SessionKey 的构成

`sessionKey` 是一个字符串，用于唯一标识一个会话。通常格式为：

`agent:<agentId>:<channel>:<channelId>:<threadId>`

例如：`agent:main:telegram:123456789:thread:1`

*   **Agent ID**: 处理该消息的 Agent。
*   **Channel**: 消息来源渠道。
*   **Channel ID**: 渠道内的唯一标识（如 Telegram Chat ID）。
*   **Thread ID**: (可选) 话题或线程 ID。

### 隔离机制

1.  **消息路由**: Gateway 根据 `sessionKey` 将消息路由到对应的 Agent 实例。
2.  **记忆存储**: Agent 的短期记忆（Conversation History）和长期记忆（Vector DB）都与 `sessionKey` 绑定。Agent A 处理 User A 的消息时，无法访问 User B 的 `sessionKey` 下的数据。
3.  **Skill 执行**: 当 Agent 执行 Skill 时，`sessionKey` 会被传递给 Skill。Skill 可以利用这个 Key 来进行用户级别的权限控制或数据隔离（例如，为每个用户创建独立的临时工作目录）。

### 最佳实践

*   **不要硬编码 SessionKey**: 在开发 Skill 或 Channel 时，始终从上下文（Context）中获取 `sessionKey`。
*   **跨 Session 通信**: 如果需要跨 Session 通信（例如管理员广播），需要显式调用 Gateway 的管理接口，并做好权限控制。
