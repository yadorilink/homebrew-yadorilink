# homebrew-yadorilink

Homebrew tap for [YadoriLink](https://github.com/juntaki/yadorilink), a
local-first peer-to-peer folder-sync tool.

This is a self-owned tap, not `homebrew/core` — YadoriLink is pre-1.0 and
does not yet meet core's acceptance bar (see
[Homebrew's own guidance on third-party taps](https://docs.brew.sh/Taps)).

## Install

**Cask** (recommended for most macOS users): the signed, notarized `.pkg`
— CLI, sync daemon, menu-bar status app, and Finder integration
(icon overlays, right-click sharing):

```sh
brew install --cask juntaki/yadorilink/yadorilink
```

**Formula** (CLI + daemon only, built from source, no Finder/menu-bar
integration — for a headless, server, or Linux install):

```sh
brew install juntaki/yadorilink/yadorilink
```

Only one of the two should be installed at a time; installing both puts
two copies of `yadorilink`/`yadorilink-daemon` on `PATH` (Formula under
`$(brew --prefix)/bin`, Cask under `/usr/local/bin` or `/opt/homebrew/bin`
depending on the Cask's own install location) and is unsupported.

## Updating

```sh
brew upgrade --cask yadorilink   # Cask
brew upgrade yadorilink          # Formula
```

Once installed via either path, YadoriLink's own built-in updater
(`yadorilink update install`) defers to Homebrew rather than replacing
itself — see
[`docs/AUTOMATIC_UPDATES.md`](https://github.com/juntaki/yadorilink/blob/main/docs/AUTOMATIC_UPDATES.md)'s
"Package-manager-owned installs never self-update" in the main repo.

## How this tap stays current

`Casks/yadorilink.rb` and `Formula/yadorilink.rb` are updated automatically
by [`.github/workflows/bump-tap.yml`](.github/workflows/bump-tap.yml),
triggered from `juntaki/yadorilink`'s own release workflow the moment a
new signed release is published. Nobody should need to hand-edit either
file for an ordinary release.

### Recovering a missed bump

If a release's automated dispatch to this repo fails or is skipped, run
this repo's **Bump tap on release** workflow by hand (Actions tab → select
the workflow → Run workflow) with:

- `version`: the released version, e.g. `0.2.0`
- `macos_pkg_sha256`: `shasum -a 256` of that release's
  `yadorilink-macos.pkg` asset
- `source_sha256`: `shasum -a 256` of that release's
  `vVERSION` source tarball (`https://github.com/juntaki/yadorilink/archive/refs/tags/vVERSION.tar.gz`)

All three values are also published in the release's own `SHA256SUMS`
sidecar files, so no separate download-and-hash step should be needed to
find them.

## Status

YadoriLink has not cut its first tagged public release yet. Both
`Casks/yadorilink.rb` and `Formula/yadorilink.rb` currently carry
placeholder `version`/`sha256`/`url` values (clearly marked in each file)
that `bump-tap.yml` will overwrite automatically the first time a real
release is published. Until then, `brew install` from this tap will fail
a checksum verification by design rather than silently installing the
wrong thing.
