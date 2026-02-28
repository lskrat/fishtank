## ADDED Requirements

### Requirement: Document Project Structure
The documentation SHALL provide a detailed tree view of the project's directory structure and explain the purpose of key directories, including `src`, `extensions`, `docs`, `apps`, and `scripts`.

#### Scenario: User views directory structure
- **WHEN** a user navigates to the "Directory Structure" section of the document
- **THEN** they see a tree diagram of the project
- **AND** they see descriptions for each major directory

### Requirement: Document Core Concepts
The documentation SHALL explain the core architectural concepts of OpenClaw, specifically "Gateway", "Agent", "Channel", and "Skill", and how they interact.

#### Scenario: User learns architecture
- **WHEN** a user reads the "Core Concepts" section
- **THEN** they understand the role of the Gateway as the central hub
- **AND** they understand how Agents process messages from Channels

### Requirement: Document Quick Start
The documentation SHALL provide a step-by-step guide for setting up the development environment, installing dependencies, and running the Gateway locally.

#### Scenario: User sets up environment
- **WHEN** a user follows the "Quick Start" guide
- **THEN** they can successfully install dependencies using `pnpm`
- **AND** they can start the Gateway service

### Requirement: Document Configuration
The documentation SHALL explain the structure of the `~/.openclaw/openclaw.json` configuration file and provide examples for common tasks like adding a channel or changing the model.

#### Scenario: User configures Gateway
- **WHEN** a user consults the "Configuration Guide"
- **THEN** they know where the configuration file is located
- **AND** they know how to modify it to enable a specific channel

### Requirement: Document Code Entry Points
The documentation SHALL identify and link to the key entry point files in the codebase (e.g., `openclaw.mjs`, `src/index.ts`) to help developers start reading the code.

#### Scenario: User explores code
- **WHEN** a user looks for "Key Code Entry Points"
- **THEN** they find links to the main executable files
- **AND** they find brief descriptions of what each entry point does
