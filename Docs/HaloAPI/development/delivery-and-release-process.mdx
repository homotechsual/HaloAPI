# Delivery And Release Process

This page records the normal HaloAPI development, CI, documentation, and release flow.

## Branch Model

* `develop` is the active integration branch for day-to-day work.
* `main` is the stable release branch.
* Normal pull requests should target `develop`.
* Stable tags such as `v1.23.0` must point to commits reachable from `main`.
* Preview tags such as `v1.24.0-beta1` may point to `develop`.

## Local Change Flow

1. Bootstrap the development environment.
2. Make the code or documentation changes.
3. Run the repo validation entrypoints locally.
4. Update development docs or generated docs if public behavior changed.
5. Open or update the pull request targeting `develop`.

```powershell
pwsh -File .\Bootstrap.ps1
pwsh -File .\DevOps\Quality\run-pssa.ps1
pwsh -File .\DevOps\Quality\test.ps1 -Suite Meta -Verbosity Detailed
```

## CI Flow On `develop`

The `CI` workflow runs on pushes and pull requests targeting `develop`.

It currently executes in this order:

1. Lint with PSScriptAnalyzer.
2. Run cross-platform metadata smoke tests on Linux and macOS.
3. Run the Windows metadata test job with coverage and JUnit output.
4. Sync development documentation after successful push runs on `develop`.

## Development Docs Sync

After a successful `push` run on `develop`, `sync-development-docs.yml` publishes `Docs/HaloAPI/development` to `homotechsualdocs` at `docs/haloapi/development`.

## Stable Release Flow

1. Update `CHANGELOG.md` and `HaloAPI.psd1` together.
2. Make sure the release-prep commit is green in CI.
3. Merge the release-prep pull request from `develop` into `main`.
4. Create the stable release tag from the merged `main` commit.
5. Let the tag workflows validate, build, publish, create the GitHub release, and publish docs.

Example stable tag flow:

```powershell
git checkout main
git pull origin main
git tag v1.23.0
git push origin v1.23.0
```

## What The Tag Workflows Do

### `tag-validate.yml`

Validates that the tag came from the correct branch:

* stable tags must be reachable from `main`
* prerelease tags must be reachable from `develop`

### `release.yml`

Builds and publishes the module package and uploads the release artifacts, including the docs artifact used by downstream publishing.

### `create-release.yml`

Creates or updates the GitHub release using the matching version section from `CHANGELOG.md` when available.

### `publish-docs.yml`

Publishes the tagged documentation artifact to `homotechsualdocs` at:

* `docs/haloapi/commandlets`
* `docs/haloapi/index.mdx`
* `docs/haloapi/img`

## Preview Release Flow

Preview releases follow the same pattern, but use prerelease tags such as:

* `v1.24.0-alpha1`
* `v1.24.0-beta1`
* `v1.24.0-rc1`

These tags should be cut from commits reachable from `develop`.
