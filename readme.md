# t - Tiny template plugin for vim

>  A minimalist template / scaffolding engine for text editors.
> [![Build Status](https://travis-ci.org/vimlab/t.vim.svg?branch=master)](https://travis-ci.org/vimlab/t.vim)

## Description

This is a simple plug-in allowing to have template files per file type, which
will be used as starting point when creating new buffers.

Template files may contain variables (`{{ title }}`), which are expanded at the
time of buffer creation.  The main purpose of the templates is to add
boilerplate code to new files.

### cli

Provides a basic CLI `tvim (1)` to parse and evaluate templates using
Handlebars, and write the result to STDOUT.

It was designed to work along the included Vim / Neovim plugin, but
integrations to other text editors should be possible
([#atom](https://github.com/vimlab/t.vim/issues/1))

### vim

The vim plugin is heavily based on tpope former ztemplate plugin, that was
found in:

> https://github.com/tpope/tpope/blob/master/.vim/plugin/ztemplate.vim.

Unfortunately, ztemplate is no more and I cannot find it anymore. This plugin
is based on the git history of my vimfiles repo where I once checked in a copy
of ztemplate.vim

## Installation

**cli**

```
$ npm install tvim -g
```

**vim**

Using [vim-plug](https://github.com/junegunn/vim-plug)

```vim
Plug 'vimlab/t.vim', { do: 'npm install --prod --cache-min Infinity -g' }
" npm: --prod to skip devDependencies
" npm: --cache-min Infinity to speed up install process
" npm: -g to make tvim available in $PATH
```

For other package managers, make sure to run `npm install -g` within the bundle
directory.

**atom**

> wip

## CLI

### Description

`tvim` command is used to parse templates and evaluate them with Handlebars.

It builds template variables based on the provided filename,
[conf/defs.json](./conf/defs.json) configuration file and local project
`package.json` properties, if it exists.

**Options**

- `--file`      - Must be set to the created file (in Vim this is the new Buffer filepath)
- `--template`  - Full path value leading the Handlebars template

### Configuration

`tvim` behavior and default variables can be configured with
[`conf/*.json`](./conf) files.

- [Definitions](#definitions) A simple `{ name: command }` mapping to globally
  define template variables.

- [Globs](#globs) Configure minimatch based templates. Great to setup a common
  boilerplate for Models when creating `app/models/*.js` files.

## Templates

**Vim** When editing a new file (not created yet, eg. BufNewFile is triggered),
the plugin will try to load a template from `~/vim/templates` directory.

Templates are loaded using the following search order:

1. First try loading by filename
2. Then by filetype `default.filetype` (or extension)

For instance, `vim foo.js` will try to load `~/.vim/templates/foo.js`, then
`~/.vim/templates/default.js`.

See my vim
[templates](https://github.com/mklabs/vimfiles/tree/master/templates) folder
for a list of basic templates for web / nodejs / vim development.

## Variables

Template variables are Mustache like template placeholder: eg. `{{ title }}`

The following variables are available for expansion in templates:

- `{{ day }}`, `{{ year }}`, `{{ month }}`

Current day of the month, year, and month of the year,
as numeric values.

- `{{ date }}`

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

- `{{ hostname }}`

Current host name.

Additionnaly, any variable definitions you defined in `defs.json` will be used
instead of the defaults. If the `filename` is within a project with a
package.json (find up), its fields are used to expand corresponding variables
in templates.

<a name="definitions" />
## Overriding / Defining Variables

You can change the default value of any predefined variables, or add new ones
using `:TemplateConfig` to edit [conf/defs.json](./conf/defs.json) configuration file.

For instance, to change the default value of the `{ name }` variables in
templates, use `{ name: command }` key / value pair:

- `name` Variable name
- `command` System command to execute and evaluate STDOUT result

```json
{
  "user": "git config --global user.name"
}
```

Here is the default values for all predefined template variables.

```
// File
let ext = path.extname(filepath);
let basename = path.basename(filepath);
let filename = basename.replace(ext, '');

// Date
let day = moment().format('d');
let year = moment().format('YYYY');
let month = moment().format('M');
let date = moment().format('YYYY-M-d')
let datetime = moment().format('YYYY-M-d HH:mm')

// Misc
let user = process.env.USER;
let definitions = {
  hostname: 'hostname',
  mail:     'git config --global user.email',
  name:     'git config --global user.name'
};
```

If the buffer is within a project with a package.json, every field is defined
as a template variable as well.

## Globs

The [conf/globs.json](./conf/globs.json) file manages a list of [glob
patterns](https://github.com/isaacs/node-glob#glob-primer) to register with a
template file

Ex. `"bin/*": "bin/cli.js"` would expand every file matching the `bin/*`
pattern with `templates/bin/cli.js`.

```json
{
  "bin/*": "bin/cli.js",
  "app/models/*.js": "rails/js/model.js",
  "server.js": "node/http/server.js"
}
```

## Commands

### Template

`:Template` can be used to expand the template content in the current buffer.

### TemplateEdit

`:TemplateEdit` is an helper to `:edit ~/.vim/templates/${filetype}.template` and
quickly add or edit a template for the current filetype.

### TemplateConfig

`:TemplateConfig` is an helper to `:edit t.json` file used to define template
variables. You can simply add, edit or remove definitions by editing the JSON
content and saving the file.

<!--
## Package.json variables

If the buffer is within a project with a package.json, every field is defined
as a template variable.

Arrays and Objects are stringified using `JSON.stringify()`

## Prompts

Every template variable without a default value is going to generate a prompt.

## Template engines

Lodash is used by default to compile templates, to use another supported
template engine:

```vim
" Handlebars
Plug 'vimlab/t.vim', { do: 'npm install; npm install handlebars' }

" Liquid
Plug 'vimlab/t.vim', { do: 'npm install; npm install liquid-node' }
```
-->
