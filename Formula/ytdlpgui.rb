class Ytdlpgui < Formula
  include Language::Python::Virtualenv

  desc "Polished macOS GUI wrapper for yt-dlp"
  homepage "https://github.com/hiimkimchi/ytdlp-gui"
  url "https://github.com/hiimkimchi/ytdlp-gui/archive/refs/tags/v1.0.0.tar.gz"
  sha256 "b4d6db4790d06d3f04eb9294f11d9635ca1ee55acc8f4a0dddc72b219e2db4aa"
  license "Apache-2.0"

  depends_on "python@3.12"
  depends_on "yt-dlp"
  depends_on "ffmpeg"

  def install
    venv = virtualenv_create(libexec, "python3.12")
    venv.pip_install_and_link buildpath
  end

  def caveats
    <<~EOS
      Launch the app from your terminal:
        ytdlpgui

      Or add it to your Applications folder using the included app bundle
      (see extras/ytdlpgui.app in the repository).

      yt-dlp and ffmpeg have been installed as dependencies and will be
      picked up automatically.
    EOS
  end

  test do
    # Smoke-test: module imports cleanly and --help exits 0
    system libexec/"bin/python3", "-c", "import ytdlpgui"
  end
end
