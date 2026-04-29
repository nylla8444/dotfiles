#### base path (windows)
```
C:\Users\username\
```

---
#### To customize powershell profile name header
1. Go to: https://patorjk.com/software/taag/#p=display&h=3&v=1&f=Larry%203D&t=Type%20Something%20
2. Enter your text
3. Copy text
4. Go to [Microsoft.PowerShell_profile.ps1](Documents/PowerShell/Microsoft.PowerShell_profile.ps1) file
5. Paste your new text header

---
#### Terminal settings.json (Powershell focus)
Path is: (base path + this path)
```
AppData\Local\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json
```
- PSVersion: 7.6.1
- PSEdition: Core

Other shells are hidden except Powershell and Ubuntu
- For more info see [settings.json](AppData/Local/Packages/Microsoft.WindowsTerminal_8wekyb3d8bbwe/LocalState/settings.json)


---
####  Opencode CLI config
- Current config is mainly for the `notifier`
- More info about notifier : https://github.com/mohak34/opencode-notifier
- See my config: [opencode-notifier.json](.config/opencode/opencode-notifier.json)

---
#### Codex CLI config
- Current config is mainly for custom `notifier` (like what I did for Opencode)
- See:
    - [config.toml](.codex/config.toml): Defines the Codex hooks and points them to notify.ps1
    - [notify.ps1](.codex/notify.ps1) : The hook entrypoint. It reads/discards hook input, checks the custom sound path, then launches the sound player in the
  background so the hook exits quickly
    - [play-notify-sound.ps1](.codex/play-notify-sound.ps1) : The background helper that actually plays audio\pokeding.wav with SoundPlayer.PlaySync()

<br />

Q: Why not squeeze everything in `notify.ps1?` <br />
A: `play-notify-sound.ps1` keeps the Codex hook fast. `notify.ps1` exits almost immediately, so Codex does not sit on Running Stop
  hook while the sound plays, and it avoids timeout/failure issues

Q: Why create Codex CLI custom notifier if you can use Opencode with codex? <br />
A: Because I can


