cask "yadorilink" do
  version "0.1.0"
  # PLACEHOLDER: yadorilink has not cut its first tagged release yet (no
  # `v*` tag/release exists in juntaki/yadorilink as of this Cask's initial
  # commit). This sha256 cannot be real until that release exists. It is
  # intentionally an obviously-fake all-zero value rather than a real
  # digest of some other file, so a `brew install` attempt fails loudly on
  # a checksum mismatch instead of silently installing the wrong thing.
  # `.github/workflows/bump-tap.yml` (in this repo) overwrites both
  # `version` and `sha256` automatically the first time
  # `juntaki/yadorilink`'s release workflow publishes a real
  # `yadorilink-macos.pkg` asset -- see that workflow and
  # juntaki/yadorilink's `oss-public/.github/workflows/release.yml`
  # "Notify the Homebrew tap of a new release" step. No manual edit should
  # be needed after the first real release.
  sha256 "0000000000000000000000000000000000000000000000000000000000000000000000000000"

  url "https://github.com/juntaki/yadorilink/releases/download/v#{version}/yadorilink-macos.pkg"
  name "YadoriLink"
  desc "Local-first peer-to-peer folder sync (CLI, daemon, Finder integration)"
  homepage "https://github.com/juntaki/yadorilink"

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
  # juntaki/yadorilink, "Package-manager-owned installs never
  # self-update"): the daemon's built-in updater has no path- or
  # receipt-based way to tell a `brew install --cask` apart from a manual
  # `.pkg` double-click -- both run the identical signed installer into
  # the identical location. This marker is the only signal
  # `install_macos::detect_install_source` has, so the built-in updater
  # defers to `brew upgrade --cask yadorilink` instead of racing it.
  postflight do
    system_command "/bin/mkdir",
                    args: ["-p", "/etc/yadorilink"],
                    sudo:  true
    system_command "/usr/bin/env",
                    args: ["sh", "-c", "printf 'homebrew\\n' > /etc/yadorilink/install_source"],
                    sudo:  true
  end

  uninstall pkgutil: "com.yadorilink.installer.component",
            delete:  [
              "/Applications/YadoriLinkFinderSyncHost.app",
              "/usr/local/bin/yadorilink",
              "/usr/local/bin/yadorilink-daemon",
              "/usr/local/bin/yadorilink-status-app",
            ]

  zap trash: [
    "~/Library/Application Support/yadorilink",
    "~/Library/Preferences/com.yadorilink.*.plist",
    "/etc/yadorilink",
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
