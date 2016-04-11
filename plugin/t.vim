" t - Tiny template plugin for vim
"
" A minimalist vim template plugin
"
" Mustache like template placeholdr: eg. {{ title }}
"
" When editing a new file (not created yet, eg. BufNewFile is triggered), the
" plugin will try to load a template from ~/vim/templates with the exact same
" name, or try to fallback to `skel.{ext}`
"
" Each template has some placeholder in it. `<C-P>` (ctrl+p) or
" `<D-Space>` (cmd+space, mac only) may be used to jump to next `{{
" thing }}`.
"
" Put your skeleton files in `~/.vim/templates`

if exists("g:loaded_t") || v:version < 700 || &cp
  finish
endif
let g:loaded_t = 1

if !exists('g:t_load_dirs')
  let g:t_load_dirs = ['~/.vim/templates', '~/.templates', '~/.config/t/', '~/.config/templates', './.templates', './templates']
endif

function! s:LoadFilename(filename)
  let ext = fnamemodify(a:filename,':e')
  if ext == ''
    let ext = (fnamemodify(a:filename,':t'))
  endif
  call s:ReadTemplate(ext,a:filename)
endfunction

function! s:ReadTemplate(type, filename)
  let template = s:LookupTemplate(fnamemodify(a:filename, ':t'))

  if empty(template)
    return
  endif
  call s:LoadTemplate(template)
endfunction

function! s:LookupTemplate(filename)
  let result = ''

  for dir in g:t_load_dirs
    let tpl = s:TemplateFind(dir, a:filename)
    if !empty(tpl)
      let result = tpl
    endif
  endfor

  return result
endfunction

function! s:TemplateFind(dir, filename)
  let ext = fnamemodify(a:filename, ":e")
  if filereadable(expand(a:dir . '/' . a:filename))
    return a:dir . '/' . a:filename
  elseif filereadable(expand(a:dir . '/default.' . ext))
    return a:dir . '/default.' . ext
  else
    return ""
  endif
endfunction

function! s:LoadTemplate(template)
  silent exe "0r ".a:template

  " Jump between {{ var }} placeholders in Normal mode with <Leader>l
  nnoremap <buffer> <c-t> /{{\s*\l.\{-1,}\s*}}<cr>c/{{\s*\l*\s*}}/e<cr>
  inoremap <buffer> <c-t> /{{\s*\l.\{-1,}\s*}}<cr>c/{{\s*\l*\s*}}/e<cr>
  inoremap <buffer> <c-t> <ESC>/{{\s*\l.\{-1,}\s*}}<cr>c/{{\s*\l*\s*}}/e<cr>

  nnoremap <buffer> <c-h> /{{\s*\l.\{-1,}\s*}}<cr>c/{{\s*\l*\s*}}/e<cr>
  inoremap <buffer> <c-h> /{{\s*\l.\{-1,}\s*}}<cr>c/{{\s*\l*\s*}}/e<cr>
  inoremap <buffer> <c-h> <ESC>/{{\s*\l.\{-1,}\s*}}<cr>c/{{\s*\l*\s*}}/e<cr>

  nnoremap <buffer> <c-j> /{{\s*\l.\{-1,}\s*}}<cr>c/{{\s*\l*\s*}}/e<cr>
  inoremap <buffer> <c-j> /{{\s*\l.\{-1,}\s*}}<cr>c/{{\s*\l*\s*}}/e<cr>
  inoremap <buffer> <c-j> <ESC>/{{\s*\l.\{-1,}\s*}}<cr>c/{{\s*\l*\s*}}/e<cr>

  nnoremap <buffer> <c-k> /{{\s*\l.\{-1,}\s*}}<cr>c/{{\s*\l*\s*}}/e<cr>
  inoremap <buffer> <c-k> /{{\s*\l.\{-1,}\s*}}<cr>c/{{\s*\l*\s*}}/e<cr>
  inoremap <buffer> <c-k> <ESC>/{{\s*\l.\{-1,}\s*}}<cr>c/{{\s*\l*\s*}}/e<cr>

  nnoremap <buffer> <c-l> /{{\s*\l.\{-1,}\s*}}<cr>c/{{\s*\l*\s*}}/e<cr>
  inoremap <buffer> <c-l> /{{\s*\l.\{-1,}\s*}}<cr>c/{{\s*\l*\s*}}/e<cr>
  inoremap <buffer> <c-l> <ESC>/{{\s*\l.\{-1,}\s*}}<cr>c/{{\s*\l*\s*}}/e<cr>
endfunction

autocmd BufNewFile * call s:LoadFilename(expand("<amatch>"))
