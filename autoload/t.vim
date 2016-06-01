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

  call t#read(ext, a:filename)
endfunction

function! t#read(type, filename)
  call t#log('Read template ', a:type, a:filename)

  let template = t#find(fnamemodify(a:filename, ':t'))
  if empty(template)
    return
  endif

  call t#load(template, a:filename)
endfunction

function! t#find(filename)
  call t#log('Template find ', a:filename)

  let ext = fnamemodify(a:filename, ":e")
  let templates = join(['~', s:vimdir, 'templates'], s:sep)
  let filetype = join([templates, ext . '.' . ext], s:sep)
  let file = join([templates, a:filename], s:sep)
  let skel = join([templates, 't.' . ext], s:sep)

  " first try loading by filename
  " then by file extension
  " then by a more general skeleton one
  return t#check(expand(file)) ? file :
    \ t#check(expand(filetype)) ? filetype :
    \ t#check(expand(skel)) ? skel :
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

function! t#config()
  let file = system('tvim --json')
  exe "edit " . file
endfunction

function! t#edit(filename)
  call t#log('Edit template ', a:filename)
  let ext = fnamemodify(a:filename, ":e")
  let templates = join(['~', s:vimdir, 'templates'], s:sep)
  let file = expand(join([templates, ext . '.' . ext], s:sep))

  let dirname = fnamemodify(file, ':h')
  call t#log('Create dir ', dirname)
  call mkdir(dirname, 'p')
  exe "keepalt edit " . file
endfunction
