" DeleteTrailingWhitespace.vim: Delete unwanted whitespace at the end of lines.
"
" DEPENDENCIES:
"
" Copyright: (C) 2012 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"	001	05-Mar-2012	file creation

function! DeleteTrailingWhitespace#Pattern()
    let l:pattern = '\s\+$'

    " The ShowTrailingWhitespace plugin can define exceptions where whitespace
    " should be kept; use that knowledge if it is available.
    silent! let l:pattern = ShowTrailingWhitespace#Pattern(0)

    return l:pattern
endfunction

function! DeleteTrailingWhitespace#Delete( startLnum, endLnum )
    let l:save_cursor = getpos('.')
    execute  a:startLnum . ',' . a:endLnum . 'substitute/' . DeleteTrailingWhitespace#Pattern() . '//e'
    call setpos('.', l:save_cursor)
endfunction

function! DeleteTrailingWhitespace#HasTrailingWhitespace()
    return search(DeleteTrailingWhitespace#Pattern(), 'cnw')
endfunction

function! DeleteTrailingWhitespace#Get()
    return (exists('b:DeleteTrailingWhitespace') ? b:DeleteTrailingWhitespace : g:DeleteTrailingWhitespace)
endfunction
function! DeleteTrailingWhitespace#IsSet()
    let l:isSet = 0
    let l:value = DeleteTrailingWhitespace#Get()

    if empty(l:value) || l:value ==# '0'
	" Nothing to do.
    elseif l:value ==# 'highlighted'
	" Ask the ShowTrailingWhitespace plugin whether trailing whitespace is
	" highlighted here.
	silent! let l:isSet = ShowTrailingWhitespace#IsSet()
    elseif l:value ==# 'always' || l:value ==# '1'
	let l:isSet = 1
    else
	throw 'ASSERT: Invalid value for ShowTrailingWhitespace: ' . string(l:value)
    endif

    return l:isSet
endfunction

function! DeleteTrailingWhitespace#GetAction()
    return (exists('b:DeleteTrailingWhitespace_Action') ? b:DeleteTrailingWhitespace_Action : g:DeleteTrailingWhitespace_Action)
endfunction
function! DeleteTrailingWhitespace#IsAction()
    let l:action = DeleteTrailingWhitespace#GetAction()
    if l:action ==# 'delete'
	return 1
    elseif l:action ==# 'abort'
	if ! v:cmdbang && DeleteTrailingWhitespace#HasTrailingWhitespace()
	    " XXX: Defining a no-op BufWriteCmd only comes into effect on the
	    " next write, but does not affect the current one. Since we don't
	    " want to install such an autocmd across the board, the best we can
	    " do is throwing an exception to abort the write.
	    " throw 'DeleteTrailingWhitespace: Trailing whitespace found, aborting write (use ! to override)'
	    augroup DeleteTrailingWhitespaceAbortWrite
		autocmd! BufWriteCmd <buffer> echomsg 'Trailing whitespace found, aborting write (use ! to override)' | autocmd! DeleteTrailingWhitespaceAbortWrite * <buffer>
	    augroup END
	endif
    elseif l:action ==# 'ask'
	" ...
    else
	throw 'ASSERT: Invalid value for ShowTrailingWhitespace_Action: ' . string(l:action)
    endif
endfunction

function! DeleteTrailingWhitespace#InterceptWrite()
    if DeleteTrailingWhitespace#IsSet() && DeleteTrailingWhitespace#IsAction()
	call DeleteTrailingWhitespace#Delete(1, line('$'))
    endif
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
