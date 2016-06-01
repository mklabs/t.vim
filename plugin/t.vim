
autocmd BufNewFile * call t#filename(expand('<amatch>'))

command! TemplateDefs    call t#config('defs')
command! TemplateGlobs   call t#config('globs')
command! TemplateEdit    call t#edit(expand('%'))
command! Template        call t#filename(expand('%'))
