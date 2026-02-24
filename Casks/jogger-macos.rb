cask "jogger-macos" do
  version "0.3.5,1"

  arch arm: "aarch64", intel: "x86_64"

  sha256 arm: "74e95381fb5e6d1d79cad5c0dcd7dc5df078be160a53c99ac252dac388418155", intel: "cec352ea39b72da750f2cca93b9ba1db6c1f9be66a553d0cc7df8eca69991a51"

  url "https://github.com/BeesBoxler/jogger/releases/download/v#{version.before_comma}/jogger-macos-#{arch}-apple-darwin.zip"
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
