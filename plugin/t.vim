
autocmd BufNewFile * call t#filename(expand('<amatch>'))

command! TemplateConfig  call t#config()
command! TemplateEdit    call t#edit(expand('%'))
command! Template        call t#filename(expand('%'))
