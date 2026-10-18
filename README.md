# homebrew-yadorilink

Homebrew tap for [YadoriLink](https://github.com/yadorilink/yadorilink), a
local-first peer-to-peer folder-sync tool.

This is a self-owned tap, not `homebrew/core` — YadoriLink is pre-1.0 and
does not yet meet core's acceptance bar (see
[Homebrew's own guidance on third-party taps](https://docs.brew.sh/Taps)).

## Status: nothing is released yet

YadoriLink has no tagged release, and the source repository
[yadorilink/yadorilink](https://github.com/yadorilink/yadorilink) is not
published yet. Both `Formula/yadorilink.rb` and `Casks/yadorilink.rb` carry
placeholder `url`/`sha256` values (all-zero sha256, clearly marked in each
file), so installing from this tap will fail by design until a real
release exists. Please do not rely on or advertise this tap yet.

## Install (once a release exists)

```sh
brew tap yadorilink/yadorilink
```

**Formula** — the open-source engine only (the `yadorilink` command line and
the `yadorilink-daemon` sync daemon), built from source; works headless, on
servers and on Linux:

```sh
brew install yadorilink/yadorilink/yadorilink
```

**Cask** — a placeholder for the official macOS app. That app is built in
a separate private repository, and where its `.pkg` will be distributed
(likely the public repository's Releases) has not been decided. The Cask
cannot work and must not be advertised yet:

```sh
brew install --cask yadorilink/yadorilink/yadorilink
```

Install only one of the two at a time; both put `yadorilink` and
`yadorilink-daemon` on `PATH`, which is unsupported.

## Updating

```sh
brew upgrade --cask yadorilink   # Cask
brew upgrade yadorilink          # Formula
```

Once installed via either path, YadoriLink's own built-in updater
(`yadorilink update install`) defers to Homebrew rather than replacing
itself — see
[`docs/AUTOMATIC_UPDATES.md`](https://github.com/yadorilink/yadorilink/blob/main/docs/AUTOMATIC_UPDATES.md)'s
"Package-manager-owned installs never self-update" in the main repo.

## How this tap stays current

`Casks/yadorilink.rb` and `Formula/yadorilink.rb` are updated automatically
by [`.github/workflows/bump-tap.yml`](.github/workflows/bump-tap.yml),
designed to be triggered from the release workflow of
`yadorilink/yadorilink` (that workflow does not have this step yet). The
cross-repo call needs a token with `actions: write` scoped to this repo only,
stored in `yadorilink/yadorilink` as the secret `HOMEBREW_TAP_DISPATCH_TOKEN`;
the workflow itself pushes with this repo's own `GITHUB_TOKEN`. Until that is
wired up, run it by hand as described below.

### Recovering a missed bump

If a release's automated dispatch to this repo fails or is skipped, run
this repo's **Bump tap on release** workflow by hand (Actions tab → select
the workflow → Run workflow) with:

- `version`: the released version, e.g. `0.2.0`
- `macos_pkg_sha256`: `shasum -a 256` of that release's
  `yadorilink-macos.pkg` asset
- `source_sha256`: `shasum -a 256` of that release's
  `vVERSION` source tarball (`https://github.com/yadorilink/yadorilink/archive/refs/tags/vVERSION.tar.gz`)

All three values are also published in the release's own `SHA256SUMS`
sidecar files, so no separate download-and-hash step should be needed to
find them.
