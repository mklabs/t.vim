if exists("g:loaded_t") || v:version < 700 || &cp
  finish
endif

let g:loaded_t = 1

let s:sep = has('win32') ? '\' : '/'
let s:vimdir = has('win32') ? 'vimfiles' : '.vim'
let s:debug = exists('g:t_debug')

let s:logs = []
function! t#debug(...)
  let msg = join(a:000, ' ')

  if s:debug
    echohl String | echomsg msg | echohl None
  else
    call add(s:logs, msg)
  end
endfunction

function! t#logs()
  return s:logs
endfunction

function! t#join(...)
  let list = a:000
  let value = join(list, '/')

  " clean up windows \ separator
  let value = substitute(value, '\', '/', 'g')

  " cleanup any consecutive slash
  let value = substitute(value, '/\+', '/', 'g')

  " lastly, return the correct platform specific path
  return substitute(value, '/', has('win32') ? '\' : '/', 'g')
endfunction

function! t#messages()
  for log in t#logs()
    echohl Commment | echomsg log | echohl None
  endfor
endfunction

function! t#log(...)
  let args = a:000
  let msg = join(args, ' ')
  call t#debug('t>> ', msg)
endfunction

function! t#filename(filename)
  call t#log('Loading ', a:filename)

  let ext = fnamemodify(a:filename, ':e')
  if ext == ''
    let ext = (fnamemodify(a:filename, ':t'))
  endif

  call t#read(ext, t#join(a:filename))
endfunction

function! t#read(type, filename)
  call t#log('Read template ', a:type, a:filename)

  let template = t#find(fnamemodify(a:filename, ':t'))
  if empty(template)
    return
  endif

  call t#load(t#join(template), a:filename)
endfunction

function! t#find(filename)
  call t#log('Template find ', a:filename)

  let ext = fnamemodify(a:filename, ":e")
  let ft = &filetype
  let templates = join(['~', s:vimdir, 'templates'], s:sep)
  let filetype = join([templates, ft . '.template'], s:sep)
  let file = join([templates, a:filename], s:sep)
  let skel = join([templates, 't.' . ft], s:sep)

  " first try loading by filename
  " then by file extension
  " then by a more general skeleton one
  return t#check(expand(file)) ? file :
    \ t#check(expand(filetype)) ? filetype :
    \ t#check(expand(skel)) ? filetype :
    \ ''
endfunction

function! t#check(file)
  call t#log('Check ', a:file)
  return filereadable(a:file)
endfunction

function! t#load(template, filename)
  call t#log('Load template ', a:template)
  silent exe 'keepalt r!tvim --file ' . a:filename . ' --template ' . a:template
endfunction

function! t#config(...)
  let type = a:0 > 0 ? a:1 : 'config'

  let file = system('tvim --' . type)
  exe "keepalt edit " . file
endfunction

function! t#edit(filename)
  call t#log('Edit template ', a:filename)
  let ft = &filetype
  let templates = join(['~', s:vimdir, 'templates'], s:sep)
  let file = join([templates, ft . '.template'], s:sep)

  let dirname = fnamemodify(file, ':h')
  if !isdirectory(dirname)
    call t#log('Create dir ', dirname)
    call mkdir(dirname, 'p')
  endif

  exe "keepalt edit " . file
endfunction
