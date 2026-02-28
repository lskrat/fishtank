## 1. Setup & Overview

- [x] 1.1 Create `docs/zh-CN` directory structure
- [x] 1.2 Write **Architecture Overview**: High-level diagram of Gateway, Agent, Node, Channel interaction

## 2. User System & Auth (Secondary Dev Focus)

- [x] 2.1 Document **Authentication Flow**: Explain `src/gateway/auth.ts` and `trusted-proxy` mode
- [x] 2.2 Guide: **Integrating Custom Auth**: How to modify `authorizeGatewayConnect` to check external user DB
- [x] 2.3 Guide: **Session Isolation**: How `sessionKey` works and ensures multi-user data safety

## 3. Node & Routing (Secondary Dev Focus)

- [x] 3.1 Document **Node Registry**: Explain `src/gateway/node-registry.ts` and WebSocket handshake
- [x] 3.2 Guide: **Multi-Node Routing**: How to route tasks to specific Nodes (e.g., specific user's desktop)

## 4. Skill Development (Secondary Dev Focus)

- [x] 4.1 Document **Skill Anatomy**: Structure of a Skill package
- [x] 4.2 Tutorial: **Create a Custom Skill**: Step-by-step example (e.g., "Internal CRM Search")
- [x] 4.3 Guide: **Skill Configuration**: How to enable Skills for specific Agents/Users

## 5. Configuration & Deployment

- [x] 5.1 Write **Configuration Reference**: `openclaw.json` deep dive
- [x] 5.2 Write **Deployment Guide**: Docker/PM2 setup for production
