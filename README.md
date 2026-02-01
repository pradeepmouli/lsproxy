# lsproxy

Pluggable/configurable LSP Client/Server proxy

## Getting Started

### Prerequisites

- Node.js >= 20.0.0
- pnpm >= 10.0.0

### Installation

```bash
git clone https://github.com/pradeepmouli/lsproxy.git
cd lsproxy
pnpm install
```

### Development

```bash
# Start development
pnpm run dev

# Run tests
pnpm run test

# Lint and format
pnpm run lint
pnpm run format
```

## Project Structure

This project uses pnpm workspaces for managing multiple packages:

```
lsproxy/
├── packages/
│   └── [your packages here]
├── docs/
├── .github/workflows/
├── package.json
└── README.md
```

## Creating Your First Package

See [docs/WORKSPACE.md](docs/WORKSPACE.md) for detailed instructions on adding packages.

## Documentation

- [Workspace Guide](docs/WORKSPACE.md) - Managing packages
- [Development Workflow](docs/DEVELOPMENT.md) - Development process
- [Testing Guide](docs/TESTING.md) - Testing setup
- [Examples](docs/EXAMPLES.md) - Usage examples

## Contributing

Please see [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

## License

MIT - See [LICENSE](LICENSE) for details

---

**Author**: Pradeep Mouli
**Created**: January 31, 2026
