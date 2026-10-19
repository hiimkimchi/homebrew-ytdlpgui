class Ytdlpgui < Formula
  include Language::Python::Virtualenv

  desc "macOS GUI for yt-dlp downloads and demucs stem splitting"
  homepage "https://github.com/hiimkimchi/ytdlp-gui"
  url "https://github.com/hiimkimchi/ytdlp-gui/archive/refs/tags/v1.1.3.tar.gz"
  sha256 "9754ff6fd906fb45fb1cda232d62335528661cfb449dcd6782782491abc4006a"
  license "Apache-2.0"

  # python@3.14 shares openssl@4 with ffmpeg; mixing in python@3.12 (openssl@3)
  # trips Homebrew's lock when it relinks openssl during upgrades.
  depends_on "ffmpeg"
  depends_on "python-tk@3.14"
  depends_on "python@3.14"

  def install
    venv = virtualenv_create(libexec, "python3.14")

    # PyTorch (for demucs) and deno (yt-dlp's JS runtime) come from PyPI
    # wheels; building them from source needs Rust/LLVM and takes hours on
    # macOS versions without bottles. Installed before the app so only the
    # ytdlpgui entry point gets linked into bin.
    system formula_opt_bin("python@3.14")/"python3.14", "-m", "pip",
           "--python=#{libexec}/bin/python", "install", "--no-compile",
           "yt-dlp[default,deno]", "demucs>=4.1", "numpy"
    venv.pip_install_and_link buildpath

    # Assemble .app bundle directly (avoids build_app.sh's pip/network issues)
    app_contents = prefix/"Applications/ytdlp gui.app/Contents"
    (app_contents/"MacOS").mkpath
    (app_contents/"Resources").mkpath

    cp buildpath/"extras/Info.plist", app_contents/"Info.plist"

    # Launch script that uses the Homebrew-managed venv
    (app_contents/"MacOS/launch.sh").write <<~BASH
      #!/usr/bin/env bash
      exec "#{libexec}/bin/python3" -m ytdlpgui "$@"
    BASH
    chmod 0755, app_contents/"MacOS/launch.sh"
  end

  def caveats
    <<~EOS
      Launch from terminal:
        ytdlpgui

      To add to /Applications (for Finder & Spotlight):
        ln -sf "#{opt_prefix}/Applications/ytdlp gui.app" "/Applications/ytdlp gui.app"

      ffmpeg is installed as a dependency; yt-dlp and demucs live inside the app.
      The first stem split downloads the demucs model (~80 MB).
    EOS
  end

  test do
    system libexec/"bin/python3", "-c", "import tkinter, ytdlpgui, ytdlpgui.stems"
    system libexec/"bin/yt-dlp", "--version"
    system libexec/"bin/python3", "-m", "demucs.separate", "--help"
  end
end
