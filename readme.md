# t - Tiny template plugin for vim

A minimalist vim template plugin thing. Heavily based on tpope former
ztemplate plugin, that was found in:

> https://github.com/tpope/tpope/blob/master/.vim/plugin/ztemplate.vim.

Unfortunately, ztemplate is no more and I cannot find it anymore. This plugin
is based on the git history of my vimfiles repo where I initially comitted a
copy.

## Description

This is a simple plug-in allowing to have template files per file type, which
will be used as starting point when creating new buffers.

Template files may contain variables (`{{ title }}`), which are expanded at the
time of buffer creation.  The main purpose of the templates is to add
boilerplate code to new files.

## Installation

Using [vim-plug](https://github.com/junegunn/vim-plug)

```vim
Plug 'vimlab/t.vim', { do: 'npm install' }
```

## Template engine

Lodash is used by default to compile templates, to use another supported
template engine:

```vim
" Handlebars
Plug 'vimlab/t.vim', { do: 'npm install; npm install handlebars' }

" Liquid
Plug 'vimlab/t.vim', { do: 'npm install; npm install liquid-node' }
```

## Templates

When editing a new file (not created yet, eg. BufNewFile is triggered), the
plugin will try to load a template from `~/vim/templates` with the exact same
name, or try to fallback to `skel.{ext}`

Put your skeleton files in `~/.vim/templates`

## Variables

Template variables are Mustache like template placeholder: eg. `{{ title }}`

The following variables are available for expansion in templates:

- `{{ day }}`, `{{ year }}`, `{{ month }}`

Current day of the month, year, and month of the year,
as numeric values.

- `{{ data }}`

Current date in `YYYY-mm-dd` format.

- `{{ time }}`

Current time in `HH:MM` format.

- `{{ datetime }}`

Current full date (date and time) in `YYYY-mm-dd HH:MM`
format.

- `{{ filename }}`

File name, without extension.

- `{{ ext }}`

File extension (component after the last period).

- `{{ basename }}`

File name, with extension.

- `{{ mail }}`

E-mail address of the current user. This is the value of
`git config --global user.email`

- `{{ user }}`

Current logged-in user name (`$USER`)

- `{{ license }}`

Expands to the string `MIT` by default or the value of package.json "license" property.

`{{ hostname }}`

Current host name.


## Overriding / Defining Variables

You can change the default value of any predefined variables, or add new ones
using `t#define(name, command)`

- `name` Variable name
- `command` System command to evaluate and use STDOUT result

For instance, to change the default value of the `{ name }` variables in templates

```vim
t#define('name', 'git config --global user.mail')
```

Here is the default definitions t defines by default:

```vim
" Dates
t#define('day',       'date "%d"')
t#define('year',      'date "%Y"')
t#define('month',     'date "%m"')
t#define('date',      'date "%Y-%m-%d"')
t#define('time',      'date "%k:%M"')
t#define('datetime',  'date "%Y-%m-%d %k:%M"')

" File
" $filename is expanded to buffer absolute filepath
t#define('filepath',  '$filepath')
t#define('ext',       'node -pe "path.extname(\'$filepath\')"')
t#define('basename',  'node -pe "path.basename(\'$filepath\')"')
t#define('filename',  'node -pe "path.basename(\'$filepath\').replace(\'$ext\', '')"')

" User
t#define('name', '$USER')
t#define('mail', 'git config --global user.email')

" Package.json
t#defineNode('name', 'require("read-pkg-up").name')
t#defineNode('version', 'require("read-pkg-up").version')
t#defineNode('description', 'require("read-pkg-up").description')
t#defineNode('license', 'require("read-pkg-up").license')
" etc ..
````

## Package.json variables

If the buffer is within a project with a package.json, every field is defined
as a template variable.

Arrays and Objects are stringified using `JSON.stringify()`

## Prompts

Every template variable without a default value is going to generate a prompt.

---

> Work in progress
