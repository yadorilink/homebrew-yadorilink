class Yadorilink < Formula
  desc "Local-first peer-to-peer folder sync (CLI + daemon, no desktop integration)"
  homepage "https://github.com/juntaki/yadorilink"
  # PLACEHOLDER: yadorilink has not cut its first tagged release yet (no
  # `v*` tag/release exists in juntaki/yadorilink as of this Formula's
  # initial commit) -- `url`/`sha256` point at nothing real yet.
  # `.github/workflows/bump-tap.yml` (in this repo) overwrites both the
  # first time a real `v*` tag's source tarball exists; see
  # juntaki/yadorilink's `oss-public/.github/workflows/release.yml`
  # "Notify the Homebrew tap of a new release" step.
  url "https://github.com/juntaki/yadorilink/archive/refs/tags/v0.1.0.tar.gz"
  sha256 "0000000000000000000000000000000000000000000000000000000000000000"
  license any_of: ["MIT", "Apache-2.0"]
  head "https://github.com/juntaki/yadorilink.git", branch: "main"

  depends_on "protobuf" => :build
  depends_on "rust" => :build

  # For the signed FinderSync/File Provider desktop experience (menu-bar
  # status app, Finder icon overlays/right-click sharing), install the
  # `yadorilink` Cask (`brew install --cask juntaki/yadorilink/yadorilink`)
  # instead -- see that Cask's own comment for why the two can't be merged
  # into one package. This Formula is the CLI + daemon only, built from
  # source, for a headless/server/Linux install with no GUI integration.
  def install
    system "cargo", "install", *std_cargo_args(path: "crates/yadorilink-cli")
    system "cargo", "install", *std_cargo_args(path: "crates/yadorilink-daemon")
  end

  service do
    run [opt_bin/"yadorilink-daemon"]
    keep_alive true
    log_path var/"log/yadorilink-daemon.log"
    error_log_path var/"log/yadorilink-daemon.log"
    environment_variables YADORILINK_CONFIG_DIR: var/"yadorilink"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/yadorilink --version")
    assert_match version.to_s, shell_output("#{bin}/yadorilink-daemon --version")
  end
  # NOTE: yadorilink-daemon's own `--version` handling was added alongside
  # this tap (see crates/yadorilink-daemon/src/main.rs's
  # print_version_and_exit_if_requested) specifically so this `test do`
  # block above is safe to run in `brew test`'s sandbox: yadorilink-daemon
  # otherwise takes no arguments at all and would start the real sync
  # daemon (binding sockets, opening a database) for any other input.
end
