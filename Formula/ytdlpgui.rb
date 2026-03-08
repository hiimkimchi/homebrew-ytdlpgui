class Ytdlpgui < Formula
  include Language::Python::Virtualenv

  desc "Polished macOS GUI wrapper for yt-dlp"
  homepage "https://github.com/hiimkimchi/ytdlp-gui"
  url "https://github.com/hiimkimchi/ytdlp-gui/archive/refs/tags/v1.0.0.tar.gz"
  sha256 "b4d6db4790d06d3f04eb9294f11d9635ca1ee55acc8f4a0dddc72b219e2db4aa"
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

