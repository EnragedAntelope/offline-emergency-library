- **aria2 downloads no longer flood the screen or a log.** In a terminal, both installers passed
  `--summary-interval=1`, so aria2 printed a 5-line "Download Progress Summary" block every second
  and the screen scrolled about 5 lines a second; they now pass `--summary-interval=0` and keep the
  one-line live readout. With no terminal (piped, redirected, CI), aria2 still printed about a line
  a second plus a "Download Results" table, so the installers now also pass
  `--show-console-readout=false --download-result=hide`; a failed download still prints its error
  and stops the run as before. curl behaviour and Ctrl+C handling are unchanged. Offline checks
  record aria2's arguments in both installers. Found and measured by @boostedchaos on macOS,
  Linux and Windows. Resolves part of #34.
  _[@imsurya26](https://github.com/imsurya26) - PR #0._
