class Yadorilink < Formula
  desc "Local-first peer-to-peer folder sync (engine: CLI + daemon)"
  homepage "https://github.com/yadorilink/yadorilink"
  # PLACEHOLDER: nothing is released yet. The source of record,
  # https://github.com/yadorilink/yadorilink, is not published and has no
  # `v*` tag, so `url`/`sha256` point at nothing real and the all-zero
  # sha256 makes any install attempt fail loudly. The bump workflow
  # (`.github/workflows/bump-tap.yml` in this repo) is meant to overwrite
  # both once a real `v*` tag's source tarball exists.
  url "https://github.com/yadorilink/yadorilink/archive/refs/tags/v0.1.0.tar.gz"
  sha256 "0000000000000000000000000000000000000000000000000000000000000000"
  license "AGPL-3.0-only"
  head "https://github.com/yadorilink/yadorilink.git", branch: "main"

  depends_on "protobuf" => :build
  depends_on "rust" => :build

  # This Formula builds the open-source engine only (the `yadorilink`
  # command line and the `yadorilink-daemon` sync daemon), from source,
  # for any platform Homebrew supports. The macOS and Windows desktop apps
  # are not part of the open repository and are not built here.
  def install
    # Same two packages as the upstream README's engine build:
    # `cargo build --release -p yadorilink-cli -p yadorilink-daemon`.
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
  # print_version_and_exit_if_requested; verify it still exists upstream) specifically so this `test do`
  # block above is safe to run in `brew test`'s sandbox: yadorilink-daemon
  # otherwise takes no arguments at all and would start the real sync
  # daemon (binding sockets, opening a database) for any other input.
end
