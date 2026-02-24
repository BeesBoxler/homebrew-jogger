cask "jogger-macos" do
  version "0.3.4"

  arch arm: "aarch64", intel: "x86_64"

  sha256 arm: "3f5459d9b75d71201a726a135ed2a2245a2b35da0dba01da54aa592e2ea4af47"
  sha256 intel: "5dde385b23c814bfbcb977b0db0c45c77a6249a4848dddfa7f9f45ceeaae5bbf"

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
