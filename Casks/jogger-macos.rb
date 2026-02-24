cask "jogger-macos" do
  version "0.3.5"

  arch arm: "aarch64", intel: "x86_64"

  sha256 arm: "ce35327b4b5a9311331c64606af1535c505706e072eece84ea36a19fc3febc9c", intel: "05fb329bd256ab709d898ca5ae96a625995fa0f83305a1804834282fa72cab88"

  url "https://github.com/BeesBoxler/jogger/releases/download/v#{version}/jogger-macos-#{arch}-apple-darwin.zip"
  name "Jogger"
  desc "Simple Jira time logger"
  homepage "https://github.com/BeesBoxler/jogger"

  app "Jogger.app"

  postflight do
    plist_path = "#{Dir.home}/Library/LaunchAgents/com.jogger.macos.plist"
    plist_contents = <<~PLIST
      <?xml version="1.0" encoding="UTF-8"?>
      <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
      <plist version="1.0">
      <dict>
          <key>Label</key>
          <string>com.jogger.macos</string>
          <key>ProgramArguments</key>
          <array>
              <string>/usr/bin/open</string>
              <string>#{appdir}/Jogger.app</string>
          </array>
          <key>RunAtLoad</key>
          <true/>
          <key>KeepAlive</key>
          <false/>
      </dict>
      </plist>
    PLIST

    system_command "/bin/mkdir",
      args: ["-p", "#{Dir.home}/Library/LaunchAgents"],
      sudo: false,
      must_succeed: false
    File.write(plist_path, plist_contents)

    system_command "/bin/launchctl",
      args: ["bootout", "gui/#{Process.uid}", plist_path],
      sudo: false,
      print_stderr: false,
      must_succeed: false
    system_command "/bin/launchctl",
      args: ["bootstrap", "gui/#{Process.uid}", plist_path],
      sudo: false,
      must_succeed: false

    system_command "/usr/bin/xattr",
      args: ["-dr", "com.apple.quarantine", "#{appdir}/Jogger.app"],
      sudo: false,
      must_succeed: false
  end
end
