<!-- 
  SYNC IMPACT REPORT
  ==================
  Version Change: Initial → 1.0.0 (MINOR: Project constitution established)
  
  Principles Defined:
  - I. Modularity First
  - II. Type Safety (TypeScript)
  - III. Test-Driven Development (TDD)
  - IV. Protocol Compliance
  - V. Pluggability & Configuration
  - VI. Observability & Debugging
  - VII. Semantic Versioning
  
  Additional Sections:
  - Technology Stack
  - LSP Proxy Specifics
  - Development Workflow
  - Governance Process
  
  Templates Requiring Updates:
  - .specify/templates/plan-template.md: Add LSP-specific technical context ⚠ pending
  - .specify/templates/spec-template.md: Add LSP protocol requirements section ⚠ pending
  - .specify/templates/tasks-template.md: Add LSP-specific foundational tasks ⚠ pending
  
  Affected Documentation:
  - README.md: May reference constitution principles ✅ reviewed
  - CONTRIBUTING.md: Aligns with TDD + code quality ✅ reviewed
  - docs/DEVELOPMENT.md: Aligns with workflow section ✅ reviewed
-->

# lsproxy Constitution

## Core Principles

### I. Modularity First
Every feature is built as a self-contained, independently testable module within the pnpm
workspace. Modules MUST have clear ownership, documented purpose, and explicit contracts.
No "organizational glue" modules—every package must provide standalone value. Inter-module
communication happens through well-defined public APIs and schemas, never through internal
implementation details.

### II. Type Safety (TypeScript)
TypeScript strict mode is mandatory. Public APIs MUST have explicit return types.
Avoid `any` type; use generics and union types instead. Declaration files and type
exports are non-negotiable for public package boundaries. Types serve as executable
contracts—breaking type compatibility is a breaking change.

### III. Test-Driven Development (TDD)
Tests are written first. User stories and acceptance criteria are expressed as tests
before implementation begins. For public APIs: unit tests are mandatory (vitest). For
contract changes: integration tests verify inter-module compatibility. Coverage targets:
minimum 80% for public APIs; 100% for critical paths (LSP message routing, protocol
encoding/decoding). Failing tests → then implement → then refactor (Red-Green-Refactor).

### IV. Protocol Compliance
LSP (Language Server Protocol) compliance is non-negotiable. All proxy message routing
MUST preserve LSP message semantics and order. Protocol version support MUST be declared
in package.json and documented. Breaking changes to protocol handling require major
version bump and migration guide. Bidirectional message flow (client↔server↔proxy) must
maintain request-response correlation and notification ordering.

### V. Pluggability & Configuration
The proxy must be configurable via environment variables (dotenvx), JSON config files,
and CLI arguments. Custom middleware, message transforms, and protocol extensions are
enabled through plugin interfaces (if applicable). Default behavior MUST be zero-config.
Configuration schema MUST be validated at startup using Zod; invalid configs fail fast
with clear error messages. All plugins and middleware are independently testable.

### VI. Observability & Debugging
Structured logging via pino is mandatory. All LSP messages, errors, and state changes
MUST be logged with context (message ID, client ID, etc.). Log levels: `error` for
failures, `warn` for protocol violations, `info` for state transitions, `debug` for
detailed flow. Console output and file logging both supported. Performance metrics
(message latency, throughput) tracked for observability. All logs must be machine-
readable and greppable.

### VII. Semantic Versioning
MAJOR.MINOR.PATCH (semver). MAJOR bump for breaking changes to public APIs or LSP
protocol handling. MINOR for new features (backward-compatible). PATCH for bugfixes.
Pre-release versions use `@next` tag. Changesets CLI (already in use) enforces versioning
discipline. Release notes auto-generated and tagged in GitHub. NPM registry deployment
automated.

## Technology Stack

**Runtime**: Node.js ≥ 20.0.0  
**Language**: TypeScript 5.x (strict mode mandatory)  
**Package Manager**: pnpm ≥ 10.0.0 (workspaces enforced)  
**Linting**: oxlint with oxlintrc.json  
**Formatting**: oxfmt with .oxfmtrc.json (2-space indentation)  
**Testing**: vitest with coverage (target ≥80%)  
**Logging**: pino (structured JSON logs)  
**Configuration**: dotenvx + Zod validation  
**HTTP/WebSocket**: ws library for protocol transport  
**Build**: TypeScript compiler (tsgo/native transpile)  
**Versioning**: changesets + semantic versioning  
**CI/CD**: GitHub Actions with workflow automation  

**Deprecation Policy**: Runtime versions older than 2 releases behind are unsupported.
Dependency updates automatic for patch/minor; majors require explicit decision.

## LSP Proxy Specifics

**In Scope**:
- Bidirectional message routing (client ↔ proxy ↔ server)
- Message filtering, transformation, and logging
- Connection lifecycle management
- Error recovery and reconnection logic
- Multi-language server support (pluggable)
- Concurrent client connections
- Request/response correlation and timeout handling

**Out of Scope**:
- Language-specific LSP implementations (proxy is language-agnostic)
- Text editor integrations (upstream integrators' responsibility)
- Custom protocol extensions beyond LSP spec

**Protocol Version**: Support LSP 3.x (current stable). Document version-specific
behavior. Reject incompatible protocol versions with clear error messages.

**Message Semantics**: Every message type (request, response, notification) MUST be
routed with semantics preserved. Request correlation via message IDs. Notifications
delivered in order (no reordering). Response timeouts configurable per method.

## Development Workflow

1. **Planning Phase**: Write spec in `/specs/[###]/spec.md` with user stories and
   acceptance criteria. Each story is independently implementable and testable.

2. **Design Phase**: Create plan in `/specs/[###]/plan.md` covering architecture,
   dependencies, and technical approach. Constitution Check GATE: verify alignment
   with principles I–VII above.

3. **Implementation Phase**: Create tasks in `/specs/[###]/tasks.md` organized by
   user story. Each task is atomic and can be reviewed independently.

4. **Code Review**: Every PR verified against constitution (TDD, type safety, protocol
   compliance, test coverage, logging). Use `/speckit.review` for automated checks.

5. **Testing Gate**: All tests passing. Coverage reports attached to PR. Integration
   tests for cross-package changes.

6. **Release**: Changesets CLI creates version bump + changelog entry. GitHub Actions
   auto-tags and publishes to npm. Pre-release versions tagged `@next`.

**Branch Strategy**: Gitflow with feature branches (`feat/`, `fix/`, `chore/`).
Conventional commits required. Pre-commit hooks run oxlint and oxfmt.

## Governance

**Constitution Authority**: This constitution supersedes all other project guidance.
Conflicts between constitution and other docs are resolved in favor of constitution.

**Amendment Procedure**:
1. Proposer opens issue with rationale and impact analysis.
2. Review period: 1 week minimum for community input.
3. Approval: Repo maintainers vote (unanimous consent preferred).
4. Update: Constitution file updated with new date + version bump.
5. Propagation: Dependent templates and docs updated within 2 days (tracked in Sync
   Impact Report).

**Compliance Verification**:
- All PRs MUST reference constitution principle(s) affected.
- Code review checklist includes constitution alignment.
- Automated linting/testing gates enforce technical requirements.
- Version bumps MUST justify breaking changes against constitution principles.

**Review Cadence**: Constitution reviewed annually (January). Ad-hoc reviews triggered
by major version releases or significant principle violations.

**Runtime Guidance**: See [DEVELOPMENT.md](docs/DEVELOPMENT.md) for day-to-day workflow.
See [AGENTS.md](AGENTS.md) for multi-agent coordination guidelines.

---

**Version**: 1.0.0 | **Ratified**: 2026-01-31 | **Last Amended**: 2026-01-31
