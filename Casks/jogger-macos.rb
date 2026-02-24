cask "jogger-macos" do
  version "0.3.4"

  arch arm: "aarch64", intel: "x86_64"

  sha256 arm: "0054ca331811602851eb305a43666b4e945104ee59ee6b46a8a9436da410d569"
  sha256 intel: "80c2dde0acf78f9b35da739375765d6b38b14a66c335630842b599f46efd0119"

  url "https://github.com/BeesBoxler/jogger/releases/download/v#{version}/jogger-macos-#{arch}-apple-darwin.zip"
  name "Jogger"
  desc "Simple Jira time logger"
  homepage "https://github.com/BeesBoxler/jogger"

  app "Jogger.app"
end
