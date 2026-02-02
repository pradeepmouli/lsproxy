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
**Formatting**: oxfmt with .oxfmtrc.json (2-tab indentation)
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

### Core Workflow (Feature Development)

1. **Specification Phase**: Write spec in `/specs/[###]/spec.md` with user stories and
   acceptance criteria. Each story is independently implementable and testable.
   Use `/speckit.specify` to initiate.

2. **Clarification Phase** (as needed): Resolve ambiguities via `/speckit.clarify`.

3. **Design Phase**: Create plan in `/specs/[###]/plan.md` covering architecture,
   dependencies, and technical approach. Constitution Check GATE: verify alignment
   with principles I–VII above. Use `/speckit.plan`.

4. **Task Breakdown**: Create tasks in `/specs/[###]/tasks.md` organized by
   user story. Each task is atomic and can be reviewed independently. Use `/speckit.tasks`.

5. **Implementation Phase**: Execute tasks in order via `/speckit.implement`.

6. **Code Review**: Every PR verified against constitution (TDD, type safety, protocol
   compliance, test coverage, logging). Use `/speckit.review` for automated checks.

7. **Testing Gate**: All tests passing. Coverage reports attached to PR. Integration
   tests for cross-package changes.

8. **Release**: Changesets CLI creates version bump + changelog entry. GitHub Actions
   auto-tags and publishes to npm. Pre-release versions tagged `@next`.

### Extension Workflows

- **Baseline** (`/speckit.baseline`): Project context establishment—generates baseline-spec.md + current-state.md
- **Bugfix** (`/speckit.bugfix "<description>"`): Defect remediation—generates bug-report.md + tasks.md with regression test requirement
- **Enhancement** (`/speckit.enhance "<description>"`): Minor improvements—condensed single-document workflow with max 7-task plan
- **Modification** (`/speckit.modify <feature_num> "<description>"`): Feature changes—generates modification.md + impact analysis + tasks.md
- **Refactor** (`/speckit.refactor "<description>"`): Code quality improvements—generates refactor.md + baseline metrics + incremental tasks.md
- **Hotfix** (`/speckit.hotfix "<incident>"`): Emergency production issues—expedited tasks.md + post-mortem.md (within 48 hours)
- **Deprecation** (`/speckit.deprecate <feature_num> "<reason>"`): Feature sunset—generates deprecation.md + dependency scan + phased tasks.md
- **Review** (`/speckit.review <task_id>`): Implementation verification—checks against spec + updates tasks.md + generates report

### Workflow Selection

Development activities SHALL use the appropriate workflow type based on the nature of the work. Each workflow enforces specific quality gates and documentation requirements tailored to its purpose:

- **Baseline**: Project context establishment—requires comprehensive documentation of existing architecture and change tracking
- **Feature Development** (`/speckit.specify`): New functionality—requires full specification, planning, and TDD approach
- **Bug Fixes** (`/speckit.bugfix`): Defect remediation—requires regression test BEFORE applying fix
- **Enhancements** (`/speckit.enhance`): Minor improvements to existing features—streamlined single-document workflow with simple single-phase plan (max 7 tasks)
- **Modifications** (`/speckit.modify`): Changes to existing features—requires impact analysis and backward compatibility assessment
- **Refactoring** (`/speckit.refactor`): Code quality improvements—requires baseline metrics, behavior preservation guarantee, and incremental validation
- **Hotfixes** (`/speckit.hotfix`): Emergency production issues—expedited process with deferred testing and mandatory post-mortem
- **Deprecation** (`/speckit.deprecate`): Feature sunset—requires phased rollout (warnings → disabled → removed), migration guide, and stakeholder approvals

**Workflow Constraints**: The wrong workflow SHALL NOT be used. Features must not bypass specification; bugs must not skip regression tests; refactorings must not alter behavior; and enhancements requiring complex multi-phase plans must use full feature development workflow instead.

### Quality Gates by Workflow

**Baseline**:
- Comprehensive project analysis MUST be performed
- All major components MUST be documented in baseline-spec.md
- Current state MUST enumerate all changes by workflow type
- Architecture and technology stack MUST be accurately captured

**Feature Development**:
- Specification MUST be complete before planning
- Plan MUST pass constitution checks before task generation
- Tests MUST be written before implementation (TDD)
- Code review MUST verify constitution compliance

**Bugfix**:
- Bug reproduction MUST be documented with exact steps
- Regression test MUST be written before fix is applied
- Root cause MUST be identified and documented
- Prevention strategy MUST be defined

**Enhancement**:
- Enhancement MUST be scoped to a single-phase plan with no more than 7 tasks
- Changes MUST be clearly defined in the enhancement document
- Tests MUST be added for new behavior
- If complexity exceeds single-phase scope, full feature workflow MUST be used instead

**Modification**:
- Impact analysis MUST identify all affected files and contracts
- Original feature spec MUST be linked
- Backward compatibility MUST be assessed
- Migration path MUST be documented if breaking changes

**Refactor**:
- Baseline metrics MUST be captured before any changes unless explicitly exempted
- Tests MUST pass after EVERY incremental change
- Behavior preservation MUST be guaranteed (tests unchanged)
- Target metrics MUST show measurable improvement unless explicitly exempted

**Hotfix**:
- Severity MUST be assessed (P0/P1/P2)
- Rollback plan MUST be prepared before deployment
- Fix MUST be deployed and verified before writing tests (exception to TDD)
- Post-mortem MUST be completed within 48 hours of resolution

**Deprecation**:
- Dependency scan MUST be run to identify affected code
- Migration guide MUST be created before Phase 1
- All three phases MUST complete in sequence (no skipping)
- Stakeholder approvals MUST be obtained before starting

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
