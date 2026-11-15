- **A failed size check no longer stops a re-run on files already on the drive.** Both
  installers took the expected size of a PDF, model or `base-assets.tar.gz` from any answer to
  the size request, including an error page or a redirect with its own length, so one bad
  answer made the install stop on a correct copy. Only a successful answer's length counts now,
  and the changed-source check covers 503, 405 and redirect answers. Refs #289.
  _[@EnragedAntelope](https://github.com/EnragedAntelope) - PR #290._
