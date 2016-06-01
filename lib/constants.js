const path = require('path');

// Platform specific constants
let consts = module.exports;

consts.WIN32 = process.platform === 'win32';
consts.HOME = consts.WIN32 ? process.env.USERPROFILE : process.env.HOME;
consts.VIMDIR = consts.WIN32 ? 'vimfiles' : '.vim';
consts.DIR = path.join(consts.HOME, consts.VIMDIR, 'templates');
consts.SEPARATOR = consts.WIN32 ? '\\' : '/';
