- **Mac/Linux installer: no `unzip` no longer deletes the drive's Windows AI engine.** On a
  computer without `unzip`, a re-run used to empty the drive's Windows engine folders and
  still record the new build, so the Windows launchers stopped working. The installer now
  skips the Windows engine (no download, folder untouched), says so, and notes it on a
  second line of `BUILD.txt`; install `unzip` and run it again to update the Windows engine.
  _[@imsurya26](https://github.com/imsurya26) - PR #0._
