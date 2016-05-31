if exists("g:loaded_t") || v:version < 700 || &cp
  " finish
endif
let g:loaded_t = 1

let s:sep = has('win32') ? '\' : '/'
let s:vimdir = has('win32') ? 'vimfiles' : '.vim'

function! s:log(...)
  let args = a:000
  let msg = join(args, ' ')
  call vmf#debug('String', 't>> ', msg)
endfunction

function! s:LoadFilename(filename)
  call s:log('Loading ', a:filename)

  let ext = fnamemodify(a:filename,':e')
  if ext == ''
    let ext = (fnamemodify(a:filename,':t'))
  endif
  call s:ReadTemplate(ext,a:filename)
endfunction

function! s:ReadTemplate(type, filename)
  call s:log('Read template ', a:type, a:filename)

  let template = s:TemplateFind(fnamemodify(a:filename, ':t'))
  if empty(template)
    return
  endif

  call s:LoadTemplate(template)
endfunction

function! s:Check(file)
  call s:log('Check ', a:file)
  return filereadable(a:file)
endfunction

function! s:TemplateFind(filename)
  call s:log('Template find ', a:filename)

  let ext = fnamemodify(a:filename, ":e")
  let templates = join(['~', s:vimdir, 'templates'], s:sep)
  let file = join([templates, a:filename], s:sep)
  let skel = join([templates, 'skel' . ext], s:sep)
  let filetype = join([templates, ext . '.' . ext], s:sep)

  " first try loading by filename
  " then by file extension
  " then by a more general skeleton one
  return s:Check(expand(file)) ? file :
    \ s:Check(expand(filetype)) ? filetype :
    \ s:Check(expand(skel)) ? skel :
    \ ''
endfunction

function! s:LoadTemplate(template)
  call s:log('Load template ', a:template)
  silent exe "0r ".a:template
endfunction

autocmd BufNewFile * call s:LoadFilename(expand("<amatch>"))
