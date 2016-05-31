
if exists("g:loaded_t") || v:version < 700 || &cp
  finish
endif
let g:loaded_t = 1

function! s:LoadFilename(filename)
  let ext = fnamemodify(a:filename,':e')
  if ext == ''
    let ext = (fnamemodify(a:filename,':t'))
  endif
  call s:ReadTemplate(ext,a:filename)
endfunction

function! s:ReadTemplate(type, filename)
  let template = s:TemplateFind(fnamemodify(a:filename, ':t'))
  if empty(template)
    return
  endif
  call s:LoadTemplate(template)
endfunction

function! s:TemplateFind(filename)
  let ext = fnamemodify(a:filename, ":e")
  if filereadable(expand("~/.vim/template/".a:filename))
    return "~/.vim/template/".a:filename
  elseif filereadable(expand("~/.vim/templates/".a:filename))
    return "~/.vim/templates/".a:filename
  elseif filereadable(expand("~/.vim/templates/skel.".ext))
    return "~/.vim/templates/skel.".ext
  else
    return ""
  endif
endfunction


function! s:LoadTemplate(template)
  silent exe "0r ".a:template
  " Highlight {{ var }} placeholders with the Error colour group
  " TO MAKE IT SUPER OBVIOUS!
  syn match Error "{{\s*\l\+\s*}}" containedIn=ALL
endfunction

autocmd BufNewFile * call s:LoadFilename(expand("<amatch>"))

" Jump between {{ var }} placeholders in Normal mode with <Ctrl-p>
nnoremap <c-p> /{{\s*\l.\{-1,}\s*}}<cr>c/{{\s*\l*\s*}}/e<cr>

"Jump between {{ var }} placeholders in Insert mode with <Ctrl-p>
inoremap <c-p> <ESC>/{{\s*\l.\{-1,}\s*}}<cr>c/{{\s*\l*\s*}}/e<cr>
