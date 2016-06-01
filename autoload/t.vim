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

  call t#load(a:filename)
endfunction

function! t#load(filename)
  call t#log('Load template for ', a:filename)
  silent exe 'keepalt r!tvim -d --file ' . a:filename
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

  let dirname = expand(fnamemodify(file, ':h'))
  if !isdirectory(dirname)
    call t#log('Create dir ', dirname)
    call mkdir(dirname, 'p')
  endif

  exe "keepalt edit " . file
endfunction
