const path = require('path');
const parse = require('./opts');
const moment = require('moment');
const cmd = require('./cmd');

const opts = parse(process.argv.slice(2));
const HOME = process.platform ? process.env.HOME : process.env.USERPROFILE;

const defs = require('../t.json');

if (opts.json) return console.log(path.join(__dirname, '../t.json'));

let filepath = opts.file.replace('~', HOME)
if (!filepath) return;

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
let definitions = Object.assign({}, defs, {
  hostname: 'hostname',
  mail:     'git config --global user.email'
});

Object.keys(definitions).forEach((name) => {
  cmd(name, definitions[name]);
});

cmd.init().then((data) => {
  let defaults = {
    day,
    year,
    month,
    date,
    datetime,
    ext,
    basename,
    filename,
    filepath
  };

  let context = Object.assign({}, data, defaults);
  console.log(context);
});
