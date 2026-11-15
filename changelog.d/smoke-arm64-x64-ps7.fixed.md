- **CHECK-DRIVE works when started from PowerShell 7; CI tests Linux arm64 and Intel Macs.**
  Started from a PowerShell 7 window, CHECK-DRIVE.bat reported every file as unreadable, because
  Windows PowerShell picked up PowerShell 7's modules. CHECK-DRIVE, `install.bat`, the browser
  translator, the desktop map viewers and the picker's installer now clear that setting before
  they start Windows PowerShell. The per-OS smoke test now also runs on Linux arm64 and macOS
  Intel, so a wrong AI engine pick there fails CI. Resolves part of #117.
  _[@imsurya26](https://github.com/imsurya26) - PR #0._
