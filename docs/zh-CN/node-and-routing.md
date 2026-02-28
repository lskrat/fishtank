# 节点与路由指南 (Node & Routing)

本文档介绍 OpenClaw 的节点注册机制以及多节点环境下的路由策略。

## 1. 节点注册机制 (Node Registry)

OpenClaw 支持多节点架构，允许 Gateway 连接多个执行节点 (Node)。Node 可以是用户的个人电脑、服务器或移动设备。

核心逻辑位于 `src/gateway/node-registry.ts`。

### 注册流程

1.  **连接**: Node 启动后，通过 WebSocket 连接到 Gateway 的 `/gateway` 端点。
2.  **握手**: Node 发送 `connect` 消息，包含自身的元数据（ID, 平台, 版本, 能力列表）。
3.  **注册**: Gateway 的 `NodeRegistry` 接收连接，验证通过后将其加入到 `nodesById` 和 `nodesByConn` 映射表中。
4.  **保活**: Node 和 Gateway 之间通过 WebSocket Ping/Pong 保持连接活性。

### Node Session 数据结构

`NodeSession` 对象存储了节点的关键信息：

```typescript
export type NodeSession = {
  nodeId: string;       // 唯一标识 (通常是机器指纹)
  connId: string;       // WebSocket 连接 ID
  displayName?: string; // 显示名称 (如 "MacBook Pro")
  platform?: string;    // 平台 (darwin, win32, linux)
  caps: string[];       // 能力列表 (如 "browser", "fs", "camera")
  commands: string[];   // 支持的命令列表
  // ... 其他元数据
};
```

## 2. 多节点路由 (Multi-Node Routing)

在多节点环境中，Gateway 需要决定将任务分发给哪个 Node 执行。OpenClaw 目前主要采用**显式路由**策略。

### 显式路由 (Explicit Routing)

Agent 在调用 Skill 时，可以通过参数显式指定目标 `nodeId`。

**场景**: 用户希望在特定的电脑上打开浏览器。

**流程**:
1.  **Tool Definition**: 在定义 Tool 时，包含 `nodeId` 参数。
    ```json
    {
      "name": "browser_open",
      "description": "Open a URL in the browser",
      "parameters": {
        "type": "object",
        "properties": {
          "url": { "type": "string" },
          "nodeId": { "type": "string", "description": "Target node ID" }
        }
      }
    }
    ```
2.  **Agent 推理**: Agent 根据用户的指令（"在我的 MacBook 上打开 Google"）和上下文，推断出正确的 `nodeId`。
3.  **调用**: Agent 发送 Tool Call，包含 `nodeId: "macbook-pro-123"`.
4.  **Gateway 转发**: Gateway 接收到请求，通过 `NodeRegistry.invoke({ nodeId, ... })` 将指令转发给对应的 Node。

### 默认路由 (Default Routing)

如果没有指定 `nodeId`，Gateway 可能会根据配置或上下文采用默认策略：
1.  **单节点**: 如果只有一个 Node 连接，直接路由给该 Node。
2.  **主节点**: 用户可以在配置中指定一个 "Primary Node"。
3.  **最近活跃**: 路由给最近活跃的 Node。

*(注意：具体的默认路由逻辑取决于具体的 Skill 实现和 Gateway 配置)*

### 二次开发指南：实现自定义路由

如果你需要更复杂的路由逻辑（例如根据负载均衡或地理位置路由），可以在 Gateway 层拦截 Tool Call 并动态注入 `nodeId`。

这通常涉及修改 `src/gateway/server-methods/` 下的相关处理函数，在调用 `nodeRegistry.invoke` 之前插入路由选择逻辑。
