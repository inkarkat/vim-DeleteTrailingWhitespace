" DeleteTrailingWhitespace.vim: Delete unwanted whitespace at the end of lines.
"
" DEPENDENCIES:
"
" Copyright: (C) 2012-2020 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>

" Avoid installing twice or when in unsupported Vim version.
if exists('g:loaded_DeleteTrailingWhitespace') || (v:version < 700)
    finish
endif
let g:loaded_DeleteTrailingWhitespace = 1

"- configuration ---------------------------------------------------------------

if ! exists('g:DeleteTrailingWhitespace')
    let g:DeleteTrailingWhitespace = 'highlighted'
endif
if ! exists('g:DeleteTrailingWhitespace_Action')
    let g:DeleteTrailingWhitespace_Action = 'ask'
endif
if ! exists('g:DeleteTrailingWhitespace_ChoiceAffectsHighlighting')
    " Note: "Never ever" (and "Never ever recalled") are excluded here (so it
    " will keep the highlighting) because turning off both highlighting and
    " persisting the choice can be done via "Never ever highlight" (though this
    " only persists on ShowTrailingWhitespace.vim's side, and not also for
    " DeleteTrailingWhitespace, but as we observe the former's highlighting
    " state by default, this should be enough.
    let g:DeleteTrailingWhitespace_ChoiceAffectsHighlighting = ['No', 'Never', 'Never ever highlight', 'Nowhere']
endif



"- autocmds --------------------------------------------------------------------

augroup DeleteTrailingWhitespace
    autocmd!
    autocmd BufWritePre * try | call DeleteTrailingWhitespace#InterceptWrite() | catch /^DeleteTrailingWhitespace:/ | echoerr substitute(v:exception, '^\CDeleteTrailingWhitespace:\s*', '', '') | endtry
augroup END


"- commands --------------------------------------------------------------------

function! s:Before()
    let s:isModified = &l:modified
endfunction
    function! s:After()
	if ! s:isModified
	    setlocal nomodified
	endif
	unlet s:isModified
    endfunction
command! -bar -range=% DeleteTrailingWhitespace call <SID>Before()<Bar>call setline(<line1>, getline(<line1>))<Bar>call <SID>After()<Bar>call DeleteTrailingWhitespace#Delete(<line1>, <line2>)

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
