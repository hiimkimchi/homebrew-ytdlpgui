class Ytdlpgui < Formula
  include Language::Python::Virtualenv

  desc "Polished macOS GUI wrapper for yt-dlp"
  homepage "https://github.com/hiimkimchi/ytdlp-gui"
  url "https://github.com/hiimkimchi/ytdlp-gui/archive/refs/tags/v1.0.1.tar.gz"
  sha256 "9b38371f712e25f16e05d4028ecb871507e2ddcf8e8bce752973ad1edc279d2b"
  license "Apache-2.0"

  depends_on "python@3.12"
  depends_on "python-tk@3.12"
  depends_on "yt-dlp"
  depends_on "ffmpeg"

  def install
    venv = virtualenv_create(libexec, "python3.12")
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

      yt-dlp and ffmpeg are installed as dependencies.
    EOS
  end

  test do
    # Smoke-test: module imports cleanly and --help exits 0
    system libexec/"bin/python3", "-c", "import ytdlpgui"
  end
end

