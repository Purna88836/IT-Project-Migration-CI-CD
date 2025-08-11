# Release Strategy

## Branching Model

### Trunk-Based Development
- **Pros**: Simplifies merging, faster release cycles, suitable for small teams.
- **Cons**: Requires discipline to avoid breaking changes, less isolation for features.

### GitFlow
- **Pros**: Clear separation of development stages, suitable for larger teams.
- **Cons**: Can be complex, slower release cycles.

## Versioning

- Use semantic versioning: `vMAJOR.MINOR.PATCH`
- Tags are created for each release: `v1.0.0`

## Changelog Automation

- Use tools like `github-changelog-generator` to automate changelog creation.