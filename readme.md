# t.vim

**Tiny template plugin for vim**

A minimalist vim template plugin. Uses Mustache like template placeholder: `{{ title }}`

When editing a new file, the plugin will try to load a template from:

- ./.templates
- ./templates
- ~/.templates
- ~/.config/t
- ~/.config/templates
- ~/.vim/templates

Local templates, relative to current directory  `templates/` or `.templates/` are used when
found over the more general one located in `$HOME`.

You can configure the list of loading directories with:

```vim
" order of precedence is in reverse order
let g:t_load_dirs = ['~/.vim/templates', '~/.templates', '~/.config/t/', '~/.config/templates', './.templates', './templates']
```

Templates are standard Handlebars/Mustache like templates named:

- `default.<language>` for a general template for the language

- `filename.<language>` for a more specific one to load when editing a buffer with same filename.

Ex.`:e package.json` would try to load `package.json` and `default.json` in order.

**Mappings**

When templates have some placeholder in them, `<C-t>`, `<C-h>`, `<C-j>`,
`<C-k>`, or `<C-l>` can be used to jump to the next one.
