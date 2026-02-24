cask "jogger-macos" do
  version "0.3.4"

  arch arm: "aarch64", intel: "x86_64"

  sha256 arm: "3c9274f380ba19f5b1010223960cfb8ce2b44dd73ed2eea5014ad8f9d8cc3bfe"
  sha256 intel: "1e19b94d99e2491e6037f48ff610133046382dfdcc03bdfedd0fa7969feccfea"

  url "https://github.com/BeesBoxler/jogger/releases/download/v#{version}/jogger-macos-#{arch}-apple-darwin.zip"
  name "Jogger"
  desc "Simple Jira time logger"
  homepage "https://github.com/BeesBoxler/jogger"

  app "Jogger.app"
end
