" DeleteTrailingWhitespace.vim: Delete unwanted whitespace at the end of lines.
"
" DEPENDENCIES:
"   - ingo-library.vim plugin
"   - ShowTrailingWhitespace.vim plugin (optional)
"
" Copyright: (C) 2012-2020 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
let s:save_cpo = &cpo
set cpo&vim

function! DeleteTrailingWhitespace#Pattern()
    let l:pattern = '\s\+$'

    " The ShowTrailingWhitespace plugin can define exceptions where whitespace
    " should be kept; use that knowledge if it is available.
    silent! let l:pattern = ShowTrailingWhitespace#Pattern(0)

    return l:pattern
endfunction

function! DeleteTrailingWhitespace#Delete( startLnum, endLnum )
    let l:save_cursor = getpos('.')
    execute  a:startLnum . ',' . a:endLnum . 'substitute/' . escape(DeleteTrailingWhitespace#Pattern(), '/') . '//e'
    call histdel('search', -1) " @/ isn't changed by a function, cp. |function-search-undo|
    call setpos('.', l:save_cursor)
endfunction

function! DeleteTrailingWhitespace#HasTrailingWhitespace()
    " Note: In contrast to matchadd(), search() does consider the 'magic',
    " 'ignorecase' and 'smartcase' settings. However, I don't think this is
    " relevant for the whitespace pattern, and local exception regular
    " expressions can / should force this via \c / \C.
    return search(DeleteTrailingWhitespace#Pattern(), 'cnw')
endfunction

function! DeleteTrailingWhitespace#IsSet()
    let l:isSet = 0
    let l:value = ingo#plugin#setting#GetBufferLocal('DeleteTrailingWhitespace')

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

function! s:GetFilespec()
    return ingo#fs#path#Canonicalize(expand('%:p'))
endfunction
function! s:GetAction()
    return ingo#plugin#setting#GetBufferLocal('DeleteTrailingWhitespace_Action')
endfunction
function! s:RecallResponse()
    " For the response, the global settings takes precedence over the local one.
    if exists('g:DeleteTrailingWhitespace_Response')
	return (g:DeleteTrailingWhitespace_Response ? 'Anywhere' : 'Nowhere')
    elseif exists('b:DeleteTrailingWhitespace_Response')
	return (b:DeleteTrailingWhitespace_Response ? 'Always' : 'Never')
    elseif exists('g:DELETETRAILINGWHITESPACE_RESPONSES')
	let l:persistedResponses = ingo#plugin#persistence#Load('DELETETRAILINGWHITESPACE_RESPONSES', {})
	let l:filespec = s:GetFilespec()
	if has_key(l:persistedResponses, l:filespec)
	    return (l:persistedResponses[l:filespec] ? 'Forever recalled' : 'Never ever recalled')
	endif
    endif

    return ''
endfunction
function! s:IsChoiceAffectsHighlighting( response )
    " Compatibility: The empty check ensures we handle the previous
    " configuration value of 0 as well as the new List of responses.
    return ! (empty(g:DeleteTrailingWhitespace_ChoiceAffectsHighlighting) ||
    \   (index(g:DeleteTrailingWhitespace_ChoiceAffectsHighlighting, a:response) == -1))
endfunction
function! s:NeverDelete( response )
    let b:DeleteTrailingWhitespace_Response = 0

    if s:IsChoiceAffectsHighlighting(a:response)
	silent! call ShowTrailingWhitespace#Set(0, 0)
    endif

    return 0
endfunction
function! s:PersistChoice( isDelete )
    if ! ingo#plugin#persistence#Add('DELETETRAILINGWHITESPACE_RESPONSES', s:GetFilespec(), a:isDelete)
	call ingo#msg#WarningMsg("Failed to persist response; the choice will only affect the current Vim session")
    endif
endfunction
function! DeleteTrailingWhitespace#IsAction()
    let l:action = s:GetAction()
    if l:action ==# 'delete'
	return 1
    elseif l:action ==# 'abort'
	if ! v:cmdbang && DeleteTrailingWhitespace#HasTrailingWhitespace()
	    " Note: Defining a no-op BufWriteCmd only comes into effect on the
	    " next write, but does not affect the current one. Since we don't
	    " want to install such an autocmd across the board, the best we can
	    " do is throwing an exception to abort the write.
	    throw 'DeleteTrailingWhitespace: Trailing whitespace found, aborting write (add ! to override, or :DeleteTrailingWhitespace to eradicate)'
	endif
    elseif l:action ==# 'ask'
	if v:cmdbang || ! DeleteTrailingWhitespace#HasTrailingWhitespace()
	    return 0
	endif

	let l:response = s:RecallResponse()
	if empty(l:response)
	    let l:choices = ['&No', '&Yes', 'Ne&ver', '&Always', 'Nowhere', 'Anywhere']
	    if ingo#plugin#persistence#CanPersist() && ! empty(bufname(''))
		let l:choices += ['&Forever', 'Never &ever']
	    endif
	    if exists('g:ShowTrailingWhitespace') && g:ShowTrailingWhitespace && ingo#plugin#persistence#CanPersist()
		let l:choices += ['Never ever &highlight']
	    endif
	    call add(l:choices, '&Cancel write')

	    let l:response = ingo#query#ConfirmAsText('Trailing whitespace found, delete it?', l:choices, 1, 'Question')
	endif
	if     l:response ==# 'No'
	    return 0
	elseif l:response ==# 'Yes'
	    return 1
	elseif l:response ==# 'Never'
	    return s:NeverDelete(l:response)
	elseif l:response ==# 'Never ever'
	    call s:PersistChoice(0)
	    return s:NeverDelete(l:response)
	elseif l:response ==# 'Never ever recalled'
	    return s:NeverDelete(l:response)
	elseif l:response ==# 'Never ever highlight'
	    let b:DeleteTrailingWhitespace_Response = 0

	    silent! call ShowTrailingWhitespace#Filter#BlacklistFile(1)

	    if ! s:IsChoiceAffectsHighlighting(l:response)
		" Above command also disables highlighting; we need to
		" explicitly undo this if the user doesn't want it.
		silent! call ShowTrailingWhitespace#Set(1, 0)
	    endif

	    return 0
	elseif l:response ==# 'Always'
	    let b:DeleteTrailingWhitespace_Response = 1
	    return 1
	elseif l:response ==# 'Forever'
	    call s:PersistChoice(1)
	    let b:DeleteTrailingWhitespace_Response = 1
	    return 1
	elseif l:response ==# 'Forever recalled'
	    let b:DeleteTrailingWhitespace_Response = 1
	    return 1
	elseif l:response ==# 'Nowhere'
	    let g:DeleteTrailingWhitespace_Response = 0

	    if s:IsChoiceAffectsHighlighting(l:response)
		silent! call ShowTrailingWhitespace#Set(0, 1)
	    endif

	    return 0
	elseif l:response ==# 'Anywhere'
	    let g:DeleteTrailingWhitespace_Response = 1
	    return 1
	else
	    throw 'DeleteTrailingWhitespace: Trailing whitespace found, aborting write (use ! to override, or :DeleteTrailingWhitespace to eradicate)'
	endif
    else
	throw 'ASSERT: Invalid value for DeleteTrailingWhitespace_Action: ' . string(l:action)
    endif
endfunction

function! DeleteTrailingWhitespace#InterceptWrite()
    if DeleteTrailingWhitespace#IsSet() && DeleteTrailingWhitespace#IsAction()
	if ! &l:modifiable && s:GetAction() ==# 'delete'
	    call ingo#msg#WarningMsg('Cannot automatically delete trailing whitespace, buffer is not modifiable')
	    sleep 1 " Need a delay as the message is overwritten by :write.
	    return
	endif

	call DeleteTrailingWhitespace#Delete(1, line('$'))
    endif
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
