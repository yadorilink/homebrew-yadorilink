# homebrew-yadorilink

Homebrew tap for [YadoriLink](https://github.com/yadorilink/yadorilink), a
local-first peer-to-peer folder-sync tool.

This is a self-owned tap, not `homebrew/core` — YadoriLink is pre-1.0 and
does not yet meet core's acceptance bar (see
[Homebrew's own guidance on third-party taps](https://docs.brew.sh/Taps)).

## Status: nothing is released yet

YadoriLink has no tagged release, and the source repository
[yadorilink/yadorilink](https://github.com/yadorilink/yadorilink) is not
published yet. `Formula/yadorilink.rb` carries placeholder `url`/`sha256` values (all-zero
sha256, clearly marked in the file), so installing from this tap will fail by design until a real
release exists. Please do not rely on or advertise this tap yet.

## Install (once a release exists)

```sh
brew tap yadorilink/yadorilink
```

The Formula installs the open-source engine only (the `yadorilink` command
line and the `yadorilink-daemon` sync daemon), built from source; it works
headless, on servers and on Linux:

```sh
brew install yadorilink/yadorilink/yadorilink
```

The macOS app is not distributed through Homebrew; it is available only from
[yadori.link](https://yadori.link).

## Updating

```sh
brew upgrade yadorilink
```

Once installed via Homebrew, YadoriLink's own built-in updater
(`yadorilink update install`) defers to Homebrew rather than replacing
itself — see
[`docs/AUTOMATIC_UPDATES.md`](https://github.com/yadorilink/yadorilink/blob/main/docs/AUTOMATIC_UPDATES.md)'s
"Package-manager-owned installs never self-update" in the main repo.

## How this tap stays current

Updates are manual. After a release, run
[`.github/workflows/bump-tap.yml`](.github/workflows/bump-tap.yml) by hand
(see below); nothing triggers it automatically.

### Bumping the tap

Run this repo's **Bump tap on release** workflow by hand (Actions tab → select
the workflow → Run workflow) with:

- `version`: the released version, e.g. `0.2.0`
  `yadorilink-macos.pkg` asset
- `source_sha256`: `shasum -a 256` of that release's
  `vVERSION` source tarball (`https://github.com/yadorilink/yadorilink/archive/refs/tags/vVERSION.tar.gz`)

Both values are also published in the release's own `SHA256SUMS`
sidecar files, so no separate download-and-hash step should be needed to
find them.
