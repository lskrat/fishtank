## Context

OpenClaw 是一个功能强大的多渠道 AI 网关，包含 Gateway、Agents、Channels、Skills 等多个核心概念。项目结构较为复杂，涉及 TypeScript、Node.js、Docker 等多种技术栈。对于初次接触该项目的中文开发者来说，缺乏一个系统性的中文入门指南，导致上手难度较大。

**特别是针对二次开发场景**（如适配企业内部用户体系、接入多节点设备、开发自定义 Skill），开发者往往难以找到切入点。

## Goals / Non-Goals

**Goals:**
- 提供一个清晰的项目架构概览，解释核心组件（Gateway, Agent, Channel）的作用及相互关系。
- 详细解读项目目录结构，说明关键文件和目录的用途。
- **二次开发指南**：
    - **用户体系适配**：解释鉴权流程，指导如何对接自定义用户认证。
    - **多节点接入**：解析 Node 注册与通信机制，指导多设备场景下的路由策略。
    - **Skill 开发**：提供从零开发 Skill 的完整教程。
- 解析核心代码流程，帮助开发者理解请求是如何被处理的。
- 解释常用配置项，帮助用户快速定制自己的 AI 网关。

**Non-Goals:**
- 翻译所有现有的英文文档（本文档旨在作为补充和概览）。
- 深入讲解所有第三方依赖库的具体用法。
- 提供针对所有边缘情况的故障排除指南。

## Decisions

- **文档位置**：放置在 `docs/zh-CN/project-structure.md`，符合现有的国际化文档结构。
- **语言风格**：使用简体中文，技术术语保留英文（如 Gateway, Agent, Session）以保持准确性，但在首次出现时进行解释。
- **术语策略**：保留核心技术术语的英文原文，不进行强行翻译，以保持技术准确性。
    - **保留英文**：Gateway, Agent, Channel, Skill, Hook, Session, Sandbox, Model Provider, Node
    - **可翻译**：Configuration (配置), Documentation (文档), Directory (目录)
- **内容结构**：
    1.  **项目简介与架构**：Gateway/Agent/Node/Channel 关系图。
    2.  **目录结构详解**：`src` 核心模块解析。
    3.  **用户体系与鉴权（二次开发）**：`src/gateway/auth.ts` 解析与改造指南。
    4.  **多节点与路由（二次开发）**：`src/gateway/node-registry.ts` 解析。
    5.  **Skill 开发实战（二次开发）**：Skill 结构与开发步骤。
    6.  **配置与部署**：`openclaw.json` 详解与生产环境部署。

## Risks / Trade-offs

- **文档维护成本**：随着项目快速迭代，代码结构和配置项可能会发生变化，导致文档过时。
    - **Mitigation**：在文档开头注明适用的版本号或 Commit ID，并建议开发者在查阅时对比最新代码。
- **深度与广度的平衡**：如果内容过于详尽，可能导致文档过长，难以阅读；如果过于简略，又无法起到指导作用。
    - **Mitigation**：采用“由浅入深”的结构，先提供概览，再提供详细链接，利用 Markdown 的折叠功能隐藏非必要细节。
