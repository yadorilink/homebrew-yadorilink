cask "yadorilink" do
  # PLACEHOLDER CASK -- DO NOT ADVERTISE. The official macOS app is built
  # in a separate private repository, not in
  # https://github.com/yadorilink/yadorilink (which holds the engine only).
  # Where its signed `.pkg` will be distributed (likely that public
  # repository's Releases) has not been decided, so the `url` below is a
  # guess that resolves to nothing. Nothing is released yet.
  version "0.1.0"
  # The sha256 is an intentionally obviously-fake all-zero value rather
  # than a real digest of some other file, so an install attempt fails
  # loudly on a checksum mismatch instead of silently installing the wrong
  # thing. It stays zero until a real pkg location and release exist.
  sha256 "0000000000000000000000000000000000000000000000000000000000000000"

  url "https://github.com/yadorilink/yadorilink/releases/download/v#{version}/yadorilink-macos.pkg"
  name "YadoriLink"
  desc "Local-first peer-to-peer folder sync (CLI, daemon, Finder integration)"
  homepage "https://github.com/yadorilink/yadorilink"

  # shell-ext/macos/YadoriLinkFinderSync/project.yml: the File Provider
  # extension target's own MACOSX_DEPLOYMENT_TARGET (12.0) is the binding
  # constraint -- higher than the host app/FinderSync extension's 11.0 --
  # since this Cask installs all three from one pkg.
  depends_on macos: :monterey

  # This is the pkg the signed pipeline produces
  # (installer/macos/build-pkg.sh, macos-signed-artifacts job): CLI +
  # daemon + the menu-bar status app + the FinderSync/File Provider
  # extensions, all under one Developer ID Installer signature, notarized
  # and stapled. `pkgutil`'s own signature/notarization check (`pkgutil
  # --check-signature`) already gates this asset's publication in CI --
  # this Cask does not re-verify it, matching every other pkg-based Cask
  # in homebrew/cask, which rely on `sha256` + Gatekeeper rather than
  # invoking `pkgutil`/`spctl` themselves.
  pkg "yadorilink-macos.pkg"

  # Package-manager-ownership marker (docs/AUTOMATIC_UPDATES.md in
  # yadorilink/yadorilink, "Package-manager-owned installs never
  # self-update"): the daemon's built-in updater has no path- or
  # receipt-based way to tell a `brew install --cask` apart from a manual
  # `.pkg` double-click -- both run the identical signed installer into
  # the identical location. This marker is the only signal
  # `install_macos::detect_install_source` has, so the built-in updater
  # defers to `brew upgrade --cask yadorilink` instead of racing it.
  postflight do
    system_command "/bin/mkdir",
                   args: ["-p", "/etc/yadorilink"],
                   sudo: true
    system_command "/usr/bin/env",
                   args: ["sh", "-c", "printf 'homebrew\\n' > /etc/yadorilink/install_source"],
                   sudo: true
  end

  uninstall pkgutil: "com.yadorilink.installer.component",
            delete:  [
              "/Applications/YadoriLinkFinderSyncHost.app",
              "/usr/local/bin/yadorilink",
              "/usr/local/bin/yadorilink-daemon",
              "/usr/local/bin/yadorilink-status-app",
              # Must be removed on every uninstall, not only `--zap` (see
              # `zap trash:` below, which only fires on that explicit
              # flag): left behind, this marker keeps
              # `install_macos::detect_install_source` reporting
              # "homebrew" forever, even after `brew uninstall --cask` and
              # a later manual `.pkg` install replace it -- the built-in
              # updater would then keep deferring to `brew upgrade
              # --cask`, which fails since the cask is no longer
              # installed, and the user silently stops getting updates.
              "/etc/yadorilink/install_source",
            ]

  zap trash: [
    "/etc/yadorilink",
    "~/Library/Application Support/yadorilink",
    "~/Library/Preferences/com.yadorilink.*.plist",
  ]

  caveats do
    <<~EOS
      YadoriLink installed the CLI, the sync daemon, the menu-bar status app,
      and the Finder integration (icon overlays, right-click sharing).

      Start the daemon and finish device setup with:
        yadorilink daemon start
        yadorilink onboard

      This install is now managed by Homebrew: `yadorilink update install`
      defers to `brew upgrade --cask yadorilink` rather than replacing
      itself -- run that (or `brew upgrade`) to update.
    EOS
  end
end
