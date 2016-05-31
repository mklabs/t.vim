if exists("g:loaded_t") || v:version < 700 || &cp
  " finish
endif
let g:loaded_t = 1

let s:sep = has('win32') ? '\' : '/'
let s:vimdir = has('win32') ? 'vimfiles' : '.vim'

function! t#log(...)
  let args = a:000
  let msg = join(args, ' ')
  call vmf#debug('String', 't>> ', msg)
endfunction

function! t#LoadFilename(filename)
  call t#log('Loading ', a:filename)

  let ext = fnamemodify(a:filename,':e')
  if ext == ''
    let ext = (fnamemodify(a:filename,':t'))
  endif
  call t#ReadTemplate(ext,a:filename)
endfunction

function! t#ReadTemplate(type, filename)
  call t#log('Read template ', a:type, a:filename)

  let template = t#TemplateFind(fnamemodify(a:filename, ':t'))
  if empty(template)
    return
  endif

  call t#LoadTemplate(template)
endfunction

function! t#Check(file)
  call t#log('Check ', a:file)
  return filereadable(a:file)
endfunction

function! t#TemplateFind(filename)
  call t#log('Template find ', a:filename)

  let ext = fnamemodify(a:filename, ":e")
  let templates = join(['~', s:vimdir, 'templates'], s:sep)
  let file = join([templates, a:filename], s:sep)
  let skel = join([templates, 't' . ext], s:sep)
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
