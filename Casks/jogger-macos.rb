cask "jogger-macos" do
  version "0.3.4"

  arch arm: "aarch64", intel: "x86_64"

  sha256 arm: "b330c68d92d3cbc714ca11ae9a9dc6f5a75b7448a4e8331ab9559ec7643ad858"
  sha256 intel: "39f76e4d64b9a0441730970355779966c22140e5b31a19b1e143fdf2c47989e0"

  url "https://github.com/BeesBoxler/jogger/releases/download/v#{version}/jogger-macos-#{arch}-apple-darwin.zip"
  name "Jogger"
  desc "Simple Jira time logger"
  homepage "https://github.com/BeesBoxler/jogger"

  app "Jogger.app"

  postflight do
    system_command "/usr/bin/xattr",
      args: ["-dr", "com.apple.quarantine", "#{appdir}/Jogger.app"],
      sudo: false
  end
end
