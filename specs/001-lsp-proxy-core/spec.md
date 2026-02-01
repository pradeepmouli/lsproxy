# Feature Specification: LSP Proxy Core with Plugin System

**Feature Branch**: `001-lsp-proxy-core`  
**Created**: 2026-01-31  
**Status**: Draft  
**Input**: User description: "build a LSP proxy client/server with plugin/extensibility support for use cases like multi-language document (embedding of text in one language into another), scaffolding additional capabilities onto a lsp server (e.g. syntax highlighting for an LSP server that doesn't support it)"

## Clarifications

### Session 2026-01-31

- Q: Plugin state management - should plugins be able to persist state across messages? → A: In-memory only (Option A) - plugins maintain state in-memory per proxy instance with no persistence between restarts

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Basic LSP Proxy Pass-through (Priority: P1)

A developer wants to route LSP messages between their editor (LSP client) and a language server without modification, while logging all traffic for debugging purposes.

**Why this priority**: This is the foundation - a working proxy with message routing is the MVP. Without this, no other features are possible. Demonstrates core proxy capability and validates the architecture.

**Independent Test**: Can be fully tested by starting the proxy, connecting a real editor and language server, performing basic operations (open file, get completions, save), and verifying all LSP requests/responses flow correctly with no message corruption.

**Acceptance Scenarios**:

1. **Given** a running LSP proxy, **When** an editor sends `initialize` request to the proxy, **Then** the proxy forwards it to the language server and returns the server's `initialize` response to the editor
2. **Given** a connected editor and language server, **When** the editor sends `textDocument/completion` request, **Then** the proxy forwards the request, receives completion items from the server, and returns them unmodified to the editor
3. **Given** active proxy connections, **When** any LSP message passes through the proxy, **Then** the proxy logs the message with timestamp, direction (client→server or server→client), message type, and message ID
4. **Given** an editor closes a document, **When** the editor sends `textDocument/didClose` notification, **Then** the proxy forwards it to the server without requiring a response
5. **Given** a language server crashes, **When** the connection is lost, **Then** the proxy detects the disconnection and notifies the client with an error message

---

### User Story 2 - Multi-Language Document Support (Priority: P2)

A developer is editing a file that embeds multiple languages (e.g., HTML with embedded JavaScript and CSS, Markdown with code blocks, React JSX with TypeScript). They want intelligent language features (completions, diagnostics, hover) for each embedded language region.

**Why this priority**: This is a key differentiator for the proxy - addressing a common pain point where existing LSP servers only handle single languages. Enables advanced editing scenarios not possible with standard LSP servers.

**Independent Test**: Can be tested independently by configuring the proxy with multiple language server connections (e.g., HTML + TypeScript + CSS servers), opening a multi-language file, requesting completions in each language region, and verifying the proxy routes requests to the correct language server based on cursor position and language boundaries.

**Acceptance Scenarios**:

1. **Given** a proxy configured with HTML, JavaScript, and CSS language servers, **When** a user opens an HTML file with embedded `<script>` and `<style>` tags, **Then** the proxy detects language regions and registers each region with its respective language server
2. **Given** cursor is inside a JavaScript `<script>` block, **When** user requests completions (`textDocument/completion`), **Then** the proxy routes the request to the JavaScript language server with adjusted position coordinates relative to the script block
3. **Given** cursor is in CSS within a `<style>` tag, **When** user requests hover information, **Then** the proxy forwards the request to the CSS language server and returns CSS-specific documentation
4. **Given** the HTML language server reports a syntax error, **When** the proxy receives diagnostics, **Then** it merges diagnostics from all language servers and returns a combined diagnostic list to the editor
5. **Given** user edits content in a JavaScript region, **When** the proxy receives `textDocument/didChange` notification, **Then** it extracts the JavaScript portion, updates the virtual JavaScript-only document sent to the JavaScript server, and maintains position mappings

---

### User Story 3 - Plugin-Based Capability Extension (Priority: P2)

A developer uses a language server that lacks syntax highlighting support. They want to install a proxy plugin that adds semantic token highlighting by intercepting `textDocument/semanticTokens` requests and generating tokens based on the document's AST.

**Why this priority**: Demonstrates the plugin system's power - users can extend any LSP server with missing capabilities without modifying the server itself. Enables community-driven ecosystem of enhancements.

**Independent Test**: Can be tested by installing a semantic highlighting plugin, connecting to a language server without semantic token support, requesting semantic tokens from the editor, and verifying the plugin intercepts the request, generates tokens, and returns them to the client (while the original server never sees the request).

**Acceptance Scenarios**:

1. **Given** the proxy has a plugin system loaded, **When** a user installs a plugin via configuration file (JSON or environment variable), **Then** the proxy loads the plugin module, validates its interface, and registers it with the message routing pipeline
2. **Given** a semantic highlighting plugin is installed, **When** the editor sends `textDocument/semanticTokens/full` request for a file, **Then** the plugin intercepts the request before it reaches the language server
3. **Given** the plugin intercepts a request, **When** the plugin processes the request, **Then** it can read the document content, generate semantic tokens (array of line/column/length/type/modifiers), and return a synthetic response to the client without forwarding to the server
4. **Given** a plugin throws an error during processing, **When** the plugin execution fails, **Then** the proxy logs the error, disables the failing plugin, and falls back to forwarding the request to the language server normally
5. **Given** multiple plugins are installed, **When** a message matches multiple plugin criteria, **Then** plugins execute in priority order (configurable), and each plugin can modify the message, block it, or pass it through to the next plugin

---

### User Story 4 - Plugin Message Transformation (Priority: P3)

A developer wants to customize LSP responses using a plugin. For example, filtering completion items to only show items matching a specific pattern, or enriching hover documentation with additional context from external sources.

**Why this priority**: Extends plugin capabilities beyond interception to transformation - enables fine-grained control over LSP behavior without modifying servers or clients. Lower priority because interception (US3) is more critical.

**Independent Test**: Can be tested by writing a simple filter plugin (e.g., "only show completions starting with 'get'"), installing it, requesting completions, and verifying the response contains only filtered items.

**Acceptance Scenarios**:

1. **Given** a completion filter plugin is installed, **When** the language server returns 100 completion items, **Then** the plugin intercepts the response, filters items based on custom criteria, and forwards the filtered list to the client
2. **Given** a hover enhancement plugin is configured with an external API URL, **When** the editor requests hover information, **Then** the plugin allows the request to reach the server, receives the server's response, appends additional documentation fetched from the external API, and returns the enriched hover to the client
3. **Given** a plugin modifies a response message, **When** the modification changes message structure, **Then** the proxy validates the modified message against LSP protocol schema before sending to the client, and logs an error if the plugin produces an invalid message

---

### User Story 5 - Zero-Config Proxy Start (Priority: P3)

A developer wants to quickly test the proxy without writing configuration files. They want to run a single command that starts the proxy in stdio mode, automatically detecting and forwarding to a language server.

**Why this priority**: Improves developer experience and reduces friction for first-time users. Lower priority because explicit configuration (via JSON or env vars) is sufficient for the MVP.

**Independent Test**: Can be tested by running `lsproxy --stdio --server "typescript-language-server --stdio"`, connecting an editor via stdio, and verifying the proxy automatically sets up bidirectional message flow without requiring a config file.

**Acceptance Scenarios**:

1. **Given** no configuration file exists, **When** user runs `lsproxy --stdio --server "rust-analyzer"`, **Then** the proxy starts in stdio mode, spawns the rust-analyzer process, and establishes bidirectional message forwarding
2. **Given** the proxy is running with default settings, **When** no plugins are configured, **Then** the proxy operates in pass-through mode with logging enabled but no message modification
3. **Given** the user provides `--log-level debug` flag, **When** the proxy starts, **Then** it enables verbose logging of all LSP message payloads to stderr

---

### Edge Cases

- What happens when a plugin takes too long to process a message? (Timeout handling)
- How does the proxy handle malformed LSP messages from a buggy server or client?
- What happens if two plugins both try to respond to the same request? (First responder wins, or priority-based?)
- How are language region boundaries determined in multi-language documents? (Parser-based detection or configuration-based rules?)
- What happens when a language server for an embedded language is unavailable? (Graceful degradation - ignore that language region)
- How does the proxy handle LSP protocol version mismatches between client and server?
- What happens if a plugin crashes during message processing? (Isolation - disable that plugin, continue with others)
- How are position mappings maintained when embedded language regions are edited? (Incremental updates or full re-parse?)

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST use lspeasy (TypeScript SDK for LSP clients/servers) as the foundation for all LSP message handling, serialization, and protocol compliance
- **FR-002**: System MUST accept LSP client connections via stdio, TCP socket, or WebSocket transport
- **FR-003**: System MUST forward LSP requests and responses between client and server while preserving message IDs for correlation
- **FR-004**: System MUST maintain bidirectional message flow (client→server and server→client) with support for requests, responses, and notifications
- **FR-005**: System MUST log all LSP messages with timestamp, direction, message type, and content (configurable verbosity levels: error, warn, info, debug)
- **FR-006**: System MUST detect and handle connection failures (server crash, network timeout) and notify the client appropriately
- **FR-007**: System MUST support configuration via JSON file, environment variables (dotenvx), or CLI arguments
- **FR-008**: System MUST validate configuration schema at startup using Zod and fail fast with clear error messages for invalid configs
- **FR-009**: System MUST support loading plugins from configured paths (e.g., `~/.lsproxy/plugins` or `./plugins` directory)
- **FR-010**: Each plugin MUST expose a standard interface including: `name`, `version`, `priority`, `canHandle(message)`, `process(message, context)`
- **FR-011**: Plugins MUST maintain state in-memory per proxy instance with no persistence to disk between proxy restarts; state is isolated to each connection and request (stateless design)
- **FR-012**: Plugins MUST be able to intercept messages (handle without forwarding), transform messages (modify before forwarding), or pass through (no modification)
- **FR-013**: System MUST isolate plugin execution - plugin errors must not crash the proxy (try/catch with logging)
- **FR-014**: System MUST detect multi-language document regions based on configurable rules (e.g., file extension mapping, embedded language markers like `<script>`, code fence languages in Markdown)
- **FR-015**: For multi-language documents, system MUST maintain virtual documents for each language (e.g., extract all JavaScript blocks from HTML and send to JavaScript language server)
- **FR-016**: System MUST translate position coordinates (line, character) between the original multi-language document and virtual single-language documents
- **FR-017**: System MUST merge diagnostics from multiple language servers and return a unified diagnostic list to the client
- **FR-018**: System MUST support plugin installation via package managers (npm) and local file paths
- **FR-019**: System MUST validate plugin compatibility (e.g., check LSP protocol version support) before loading
- **FR-020**: System MUST expose a plugin API with helper functions for common tasks: `getDocumentContent(uri)`, `getLanguageAtPosition(uri, position)`, `parseDocument(uri)`, `logMessage(level, message)`
- **FR-021**: System MUST enforce plugin timeouts - if a plugin takes longer than a configurable threshold (default 5 seconds), the proxy logs a warning and skips the plugin for that message

### Key Entities *(include if feature involves data)*

- **Proxy Connection**: Represents a bidirectional LSP connection between a client (editor) and server. Attributes: transport type (stdio/TCP/WebSocket), client ID, server process ID, connection state (connecting, connected, disconnected), message queue
- **Message**: Represents an LSP protocol message. Attributes: message ID (for requests), method name (e.g., "textDocument/completion"), direction (inbound from client, outbound to server), payload (JSON-RPC content), timestamp
- **Plugin**: Represents a loaded plugin module. Attributes: name, version, priority, file path, enabled/disabled state, supported message types (array of method names), hook functions (canHandle, process)
- **Virtual Document**: Represents an extracted single-language view of a multi-language document. Attributes: original URI, language ID, extracted content, position mapping table (original line/col → virtual line/col)
- **Language Region**: Represents a contiguous section of a multi-language document. Attributes: language ID, start position, end position, nesting level (for recursive embeddings)
- **Configuration**: Represents proxy settings. Attributes: transport settings (stdio/TCP/WebSocket config), logging level, plugin directories, language server mappings (file extension → language server command), timeout values

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Developers can start the proxy in under 30 seconds with zero configuration (single CLI command)
- **SC-002**: Proxy forwards LSP messages with less than 10ms added latency for pass-through mode (no plugins)
- **SC-003**: Proxy successfully handles 1000 concurrent LSP requests without message loss or corruption
- **SC-004**: Multi-language document support enables completions in embedded languages with 95% accuracy (correct language server targeted based on cursor position)
- **SC-005**: Plugins can intercept, transform, or generate synthetic responses for any LSP message type with 100% coverage of the LSP 3.x specification
- **SC-006**: Proxy remains stable when plugins crash - no proxy downtime caused by plugin failures (100% isolation)
- **SC-007**: Developers can install and configure a plugin in under 5 minutes using npm and a config file
- **SC-008**: Logging captures 100% of LSP message traffic with configurable verbosity, enabling full debugging of protocol issues
- **SC-009**: Position mapping between original and virtual documents maintains accuracy across document edits (incremental updates preserve line/column correspondence)
- **SC-010**: Plugin API documentation enables third-party developers to write a basic plugin in under 1 hour

## Assumptions

1. **LSP Foundation Library**: The proxy will use `lspeasy` (TypeScript SDK for LSP clients/servers) as the core foundation for all LSP message handling, ensuring protocol compliance, type safety, and best practices out of the box.
2. **LSP Protocol Version**: The proxy will target LSP 3.x (current stable). Older protocol versions (2.x) are out of scope.
3. **Transport Layer**: Initial implementation supports stdio (most common for CLI tools). TCP and WebSocket transports are deferred to future iterations unless explicitly required.
4. **Language Detection**: Multi-language region detection uses simple heuristics initially (file extension + embedded tag parsing). Advanced AST-based detection can be added later via plugins.
5. **Plugin Distribution**: Plugins are distributed as npm packages or local JavaScript files. Native binary plugins are out of scope.
6. **Performance**: Target latency overhead is <10ms for pass-through mode. More complex operations (multi-language routing, plugin transformations) may incur higher latency (acceptable up to 100ms).
7. **Concurrency**: Single proxy instance handles multiple client connections sequentially (Node.js event loop). Parallel request processing across connections is acceptable; within-connection message ordering must be preserved.
8. **Security**: Plugins run in the same process as the proxy (no sandboxing initially). Users are responsible for vetting plugin code before installation.
9. **Configuration**: Default configuration locations: `./lsproxy.json`, `~/.config/lsproxy/config.json`, or environment variables prefixed with `LSPROXY_`.

## Out of Scope

1. **Language Server Implementation**: The proxy does not implement any language-specific analysis. It only routes messages to existing language servers.
2. **Editor Integration**: The proxy provides LSP endpoints; editor-specific plugins/extensions are the responsibility of editor maintainers.
3. **Authentication/Authorization**: No built-in auth for proxy connections. Assume trusted local environment.
4. **Distributed Proxy Cluster**: Single proxy instance only; no load balancing or clustering support.
5. **Binary Protocol Support**: Only JSON-RPC over LSP is supported. Custom binary protocols are out of scope.
6. **LSP Protocol Extensions**: The proxy does not define new LSP methods beyond the official specification.
7. **GUI/Web Interface**: Proxy is CLI-only. Web-based monitoring/configuration interfaces are out of scope.
