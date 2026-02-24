cask "jogger-macos" do
  version "0.3.5"

  arch arm: "aarch64", intel: "x86_64"

  sha256 arm: "fe86d8d0905122d9cfdfd3afc8366eb1527eaf30665b78f468f65b71c1067ae2"
  sha256 intel: "f2c11d8476833fc3502aaa388175674c170a49ffffb2dd83b772d38efd1e046e"

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
