DELETE TRAILING WHITESPACE
===============================================================================
_by Ingo Karkat_

DESCRIPTION
------------------------------------------------------------------------------

This plugin deletes whitespace at the end of each line, on demand via the
:DeleteTrailingWhitespace command, or automatically when the buffer is
written.

### SEE ALSO

This plugin leverages the superior detection and customization facilities of
the companion ShowTrailingWhitespace.vim plugin ([vimscript #3966](http://www.vim.org/scripts/script.php?script_id=3966)), though it
can also be used without it if you're not interested in highlighting and
customizing.

To quickly locate the occurrences of trailing whitespace, you can use the
companion JumpToTrailingWhitespace.vim plugin ([vimscript #3968](http://www.vim.org/scripts/script.php?script_id=3968)).

### RELATED WORKS

The basic substitution commands as well as more elaborate scriptlets, as the
idea of automating this can be found in this VimTip:
    http://vim.wikia.com/wiki/Remove_unwanted_spaces
There are already a number of plugins that define such a command; most bundle
this functionality together with the highlighting of trailing whitespace.
However, most of them cannot consider whitespace exceptions and are not as
flexible.
- trailing-whitespace ([vimscript #3201](http://www.vim.org/scripts/script.php?script_id=3201)) defines :FixWhitespace.
- bad-whitespace ([vimscript #3735](http://www.vim.org/scripts/script.php?script_id=3735)) defines :EraseBadWhitespace.
- Trailer Trash ([vimscript #3938](http://www.vim.org/scripts/script.php?script_id=3938)) defines :Trim.
- StripWhiteSpaces ([vimscript #4016](http://www.vim.org/scripts/script.php?script_id=4016)) defines :StripWhiteSpaces and strips
  automatically, too, but is way more simple than this plugin.
- WhiteWash ([vimscript #3920](http://www.vim.org/scripts/script.php?script_id=3920)) provides functions that also can strip visible
  ^M and sequential whitespacw between words.
- strip\_trailing\_whitespace.vim ([vimscript #5695](http://www.vim.org/scripts/script.php?script_id=5695)) is another alternative which
  offers a command and configurable mappings.

USAGE
------------------------------------------------------------------------------

    :[range]DeleteTrailingWhitespace
                            Delete all trailing whitespace in the current buffer
                            or [range].

INSTALLATION
------------------------------------------------------------------------------

The code is hosted in a Git repo at
    https://github.com/inkarkat/vim-DeleteTrailingWhitespace
You can use your favorite plugin manager, or "git clone" into a directory used
for Vim packages. Releases are on the "stable" branch, the latest unstable
development snapshot on "master".

This script is also packaged as a vimball. If you have the "gunzip"
decompressor in your PATH, simply edit the \*.vmb.gz package in Vim; otherwise,
decompress the archive first, e.g. using WinZip. Inside Vim, install by
sourcing the vimball or via the :UseVimball command.

    vim DeleteTrailingWhitespace*.vmb.gz
    :so %

To uninstall, use the :RmVimball command.

### DEPENDENCIES

- Requires Vim 7.0 or higher.
- Requires the ingo-library.vim plugin ([vimscript #4433](http://www.vim.org/scripts/script.php?script_id=4433)), version 1.036 or
  higher.
- The ShowTrailingWhitespace.vim plugin ([vimscript #3966](http://www.vim.org/scripts/script.php?script_id=3966)) complements this
  script, but is not required. With it, this plugin considers the whitespace
  exceptions for certain filetypes.

CONFIGURATION
------------------------------------------------------------------------------

For a permanent configuration, put the following commands into your vimrc:

This plugin doesn't come with predefined mappings, but if you want some, you
can trivially define them yourself:

    nnoremap <Leader>d$ :<C-u>%DeleteTrailingWhitespace<CR>
    vnoremap <Leader>d$ :DeleteTrailingWhitespace<CR>

By default, trailing whitespace is processed before writing the buffer when it
has been detected and is currently being highlighted by the
ShowTrailingWhitespace.vim plugin.
To turn off the automatic deletion of trailing whitespace, use:

    let g:DeleteTrailingWhitespace = 0

If you want to eradicate all trailing whitespace all the time, use:

    let g:DeleteTrailingWhitespace = 1

Also see the following configuration option to turn off the confirmation
queries in case you want unconditional, fully automatic removal.

For processing, the default ask whether to remove or keep the whitespace
(either for the current buffer, or all buffers in the entire Vim session, or
for the current buffer across time and Vim sessions).
Alternatively, the plugin can just abort the write, unless ! is given:

    let g:DeleteTrailingWhitespace_Action = 'abort'

To automatically eradicate the trailing whitespace, use:

    let g:DeleteTrailingWhitespace_Action = 'delete'

When the plugin is configured to ask the user, and she gives a negative
answer, the ShowTrailingWhitespace.vim highlighting is turned off
automatically; when you ignore it, there's typically no sense in still
highlighting it. If you don't want that, keep the highlighting via:

    let g:DeleteTrailingWhitespace_ChoiceAffectsHighlighting = []

or selectively keep the highlighting by removing responses from:

    let g:DeleteTrailingWhitespace_ChoiceAffectsHighlighting =
    \ ['No', 'Never', 'Never ever', 'Never ever recalled', 'Never ever highlight', 'Nowhere']

The global detection and processing behavior can be changed for individual
buffers by setting the corresponding buffer-local variables.

CONTRIBUTING
------------------------------------------------------------------------------

Report any bugs, send patches, or suggest features via the issue tracker at
https://github.com/inkarkat/vim-DeleteTrailingWhitespace/issues or email
(address below).

HISTORY
------------------------------------------------------------------------------

##### 1.10    RELEASEME
- ENH: Add "Forever" and "Never ever" choices that persist the response for
  the current file across Vim session.
- ENH: If ShowTrailingWhitespace.vim (version 1.10 or higher) is installed,
  offer a "Never ever highlight" choice that turns off highlighting for the
  current file persistently across Vim sessions.
- CHG: Make asking for action (instead of aborting) the default action, now
  that we offer many more choices, and the whole persistent recall of
  responses only works there. It's also more friendly and transparent towards
  first-time users of the plugin. To restore the original behavior:
 <!-- -->

  let g:DeleteTrailingWhitespace\_Action = 'abort'

- CHG: g:DeleteTrailingWhitespace\_ChoiceAffectsHighlighting now is a List of
  possible responses that if missing will keep the highlighting for that
  particular response.
- Add dependency to ingo-library ([vimscript #4433](http://www.vim.org/scripts/script.php?script_id=4433)).

__You need to separately install ingo-library ([vimscript #4433](http://www.vim.org/scripts/script.php?script_id=4433)) version
  1.036 (or higher)!__

##### 1.06    24-Feb-2015
- FIX: Warning for nomodifiable buffer does not consider buffer-local
  b:DeleteTrailingWhitespace\_Action (after version 1.05).

##### 1.05    12-Dec-2014
- Corner case: Avoid "E21: Cannot make changes, 'modifiable' is off" on a
  nomodifiable buffer when g:DeleteTrailingWhitespace\_Action = 'delete', and
  instead just show a warning. Thanks to Enno Nagel for raising this issue.

##### 1.04    14-Dec-2013
- Minor: Make substitute() robust against 'ignorecase'.
- Minor: Correct lnum for no-modifiable buffer check.
- Handle local exception regular expressions that contain a "/" character.
  This must be escaped for the :substitute/ command.

##### 1.03    19-Apr-2012
- Handle readonly and nomodifiable buffers by printing just the warning / error,
without the multi-line function error.

##### 1.02    14-Apr-2012
- FIX: Avoid polluting search history.

##### 1.01    04-Apr-2012
- Define command with -bar so that it can be chained.

##### 1.00    16-Mar-2012
- First published version.

##### 0.01    05-Mar-2012
- Started development.

------------------------------------------------------------------------------
Copyright: (C) 2012-2019 Ingo Karkat -
The [VIM LICENSE](http://vimdoc.sourceforge.net/htmldoc/uganda.html#license) applies to this plugin.

Maintainer:     Ingo Karkat <ingo@karkat.de>
