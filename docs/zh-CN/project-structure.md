# OpenClaw 项目结构与架构指南

本文档旨在帮助中文开发者快速理解 OpenClaw 的项目结构、核心架构以及如何进行二次开发。

## 1. 架构概览 (Architecture Overview)

OpenClaw 是一个多渠道 AI 网关，其核心架构由以下几个关键组件组成：

*   **Gateway (网关)**: 系统的核心枢纽，负责接收来自不同 Channel 的消息，进行路由分发，并管理 Agent 和 Node 的连接。
*   **Agent (智能体)**: 执行具体任务的 AI 实体。Agent 接收 Gateway 分发的消息，调用 LLM 进行处理，并可以调用 Skill 来完成特定操作。
*   **Channel (渠道)**: 消息的来源和去向，如 Telegram, Discord, Slack, WeChat 等。Channel 负责将外部平台的消息转换为 OpenClaw 的标准格式。
*   **Node (节点)**: 运行在用户本地环境（如个人电脑、服务器）上的执行单元。Node 通过 WebSocket 连接到 Gateway，允许 Agent 在用户的本地环境中执行操作（如文件操作、浏览器控制）。
*   **Skill (技能)**: Agent 可以调用的具体功能模块，如搜索、代码执行、API 调用等。

### 交互流程

1.  **消息接收**: 用户在 Channel (如 Telegram) 发送消息。
2.  **路由**: Channel 将消息发送给 Gateway。Gateway 根据配置将消息路由给指定的 Agent。
3.  **处理**: Agent 接收消息，调用 LLM 进行推理。
4.  **执行**: 如果 LLM 决定调用工具，Agent 会请求 Gateway 执行 Skill。
5.  **分发**: Gateway 将 Skill 执行请求分发给合适的 Node (如果是本地操作) 或直接在 Gateway 执行 (如果是云端操作)。
6.  **响应**: 执行结果返回给 Agent，Agent 生成最终回复，通过 Gateway 发送回 Channel。

```mermaid
graph TD
    User[用户] --> Channel[Channel (Telegram/Slack/etc.)]
    Channel --> Gateway[Gateway (核心网关)]
    Gateway --> Agent[Agent (智能体)]
    Agent --> LLM[LLM (大模型)]
    Agent --> Gateway
    Gateway --> Node[Node (本地节点)]
    Gateway --> CloudSkill[Cloud Skill (云端技能)]
    Node --> LocalSkill[Local Skill (本地技能)]
```

## 2. 目录结构 (Directory Structure)

OpenClaw 的项目结构如下：

*   `src/`: 源代码目录
    *   `gateway/`: Gateway 核心逻辑
    *   `agent/`: Agent 相关逻辑
    *   `channels/`: 各种 Channel 的实现
    *   `skills/`: 内置 Skill
    *   `infra/`: 基础设施代码 (数据库, 缓存等)
*   `extensions/`: 插件目录，包含各种扩展 Channel 和 Skill
*   `docs/`: 文档目录
*   `apps/`: 客户端应用 (如 Mac App)
*   `scripts/`: 构建和工具脚本

---
