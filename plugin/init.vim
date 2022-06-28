if exists("g:loaded_pylint_to_quickfix") | finish | endif

let s:save_cpo = &cpo " save user coptions
set cpo&vim " reset them to defaults

command! -nargs=* PylintToQf lua require("pylint_to_quickfix").pylint(<f-args>)

let &cpo = s:save_cpo " and restore after
unlet s:save_cpo

let g:loaded_pylint_to_quickfix = 1
