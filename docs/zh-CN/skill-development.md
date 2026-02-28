# Skill 开发指南 (Skill Development)

Skill 是 OpenClaw 的扩展机制，允许 Agent 调用外部工具或执行特定任务。

## 1. Skill 结构 (Skill Anatomy)

一个标准的 Skill 通常是一个包含 `SKILL.md` 的目录，或者是一个遵循 OpenClaw 插件规范的 npm 包。

### 基于 Markdown 的 Skill (推荐)

最简单的 Skill 只需要一个 `SKILL.md` 文件。

```markdown
---
name: my-weather-skill
description: Get weather information for a city
---

# Weather Skill

This skill allows the agent to check weather.

## Tools

### `weather_get`

Get current weather for a city.

- `city` (string): The city name (e.g. "Shanghai")

```javascript
// Implementation in JavaScript
export async function weather_get({ city }) {
  const res = await fetch(`https://api.weather.com/v1/current?city=${city}`);
  const data = await res.json();
  return `The weather in ${city} is ${data.temp} degrees.`;
}
```

### 基于插件的 Skill (高级)

对于复杂的 Skill，建议封装为插件（Extension）。参见 `extensions/llm-task` 示例。

结构：
*   `package.json`: 定义插件元数据
*   `openclaw.plugin.json`: 定义插件配置 Schema
*   `src/index.ts`: 插件入口，注册 Tool

## 2. 开发实战：创建一个 CRM 搜索 Skill (Create a Custom Skill)

假设我们需要让 Agent 能够查询公司内部 CRM 系统中的客户信息。

### 步骤 1: 创建目录

在 `skills/crm-search/` 下创建 `SKILL.md`。

### 步骤 2: 编写定义

```markdown
---
name: crm-search
description: Search customer information in internal CRM
secrets:
  - CRM_API_KEY
---

# CRM Search Skill

## Tools

### `crm_find_customer`

Search for a customer by name or email.

- `query` (string): Name or email to search for.

```javascript
export async function crm_find_customer({ query }) {
  // 获取环境变量中的 API Key
  const apiKey = process.env.CRM_API_KEY;
  
  if (!apiKey) {
    throw new Error("CRM_API_KEY is not set");
  }

  const response = await fetch(`https://crm.internal/api/customers?q=${encodeURIComponent(query)}`, {
    headers: {
      "Authorization": `Bearer ${apiKey}`
    }
  });

  if (!response.ok) {
    return `Error: ${response.statusText}`;
  }

  const data = await response.json();
  return JSON.stringify(data, null, 2);
}
```

### 步骤 3: 配置环境变量

在 `~/.openclaw/.env` 或 Gateway 启动环境中设置 `CRM_API_KEY`。

## 3. Skill 配置 (Skill Configuration)

### 启用 Skill

在 `openclaw.json` 中配置 Skill。

**全局启用**:

```json
{
  "skills": {
    "entries": {
      "crm-search": { "enabled": true }
    }
  }
}
```

**为特定 Agent 启用**:

```json
{
  "agents": {
    "list": [
      {
        "id": "sales-agent",
        "skills": ["crm-search", "email-sender"]
      }
    ]
  }
}
```

### 传递配置

如果 Skill 需要特定配置（非敏感信息），可以通过 `config` 字段传递：

```json
{
  "skills": {
    "entries": {
      "crm-search": {
        "enabled": true,
        "config": {
          "endpoint": "https://crm-prod.internal/api"
        }
      }
    }
  }
}
```
