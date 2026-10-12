class Ytdlpgui < Formula
  include Language::Python::Virtualenv

  desc "macOS GUI for yt-dlp downloads and demucs stem splitting"
  homepage "https://github.com/hiimkimchi/ytdlp-gui"
  url "https://github.com/hiimkimchi/ytdlp-gui/archive/refs/tags/v1.1.0.tar.gz"
  sha256 "9c531bd5629f68b917c2abc8e9738c80d95dfbbb15243a4c23fdcfd7619b0598"
  license "Apache-2.0"

  depends_on "ffmpeg"
  depends_on "python-tk@3.12"
  depends_on "python@3.12"
  depends_on "yt-dlp"

  def install
    venv = virtualenv_create(libexec, "python3.12")

    # demucs depends on PyTorch, which can't be built from source here, so it
    # and its dependencies come from PyPI wheels. Installed before the app so
    # only the ytdlpgui entry point gets linked into bin.
    system formula_opt_bin("python@3.12")/"python3.12", "-m", "pip",
           "--python=#{libexec}/bin/python", "install", "--no-compile",
           "demucs>=4.1", "numpy"
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

      yt-dlp, ffmpeg, and demucs are installed as dependencies.
      The first stem split downloads the demucs model (~80 MB).
    EOS
  end

  test do
    system libexec/"bin/python3", "-c", "import ytdlpgui, ytdlpgui.stems"
    system libexec/"bin/python3", "-m", "demucs.separate", "--help"
  end
end
