/* eslint no-return-assign: 0 */
const fs        = require('fs');
const path      = require('path');
const pkgup     = require('read-pkg-up');
const minimatch = require('minimatch');
const { spawn } = require('child_process');
const { readFileSync: read, existsSync: exists } = fs;

const { DIR } = require('./constants');

let cmds = {};
let cmd = module.exports = (name, cmd) => {
  cmds[name] = cmd;
};

cmd.init = (file, opts = {}) => {
  opts.globs = opts.globs || {};
  opts.log = opts.log || require('debug')('tvim:cmd');

  if (!file) throw new Error('Missing file parameter');
  return Promise.all(cmd.execAll(cmds))
    .then(cmd.reduce)
    .then(cmd.pkgup)
    .then(cmd.template(file, opts))
    .catch(err => opts.log(err));
};

cmd.pkgup = (data) => {
  return pkgup().then((result) => {
    return Object.assign({}, data, result.pkg);
  });
};

cmd.reduce = (values) => {
  return values.reduce((a, b) => {
    a[b.name] = b.value.trim();
    return a;
  }, {});
};

cmd.execAll = (commands) => {
  return Object.keys(commands)
    .map((name) => cmd.exec(name, commands[name]));
};

cmd.exec = (name, cmd, opts = {}) => {
  return new Promise((r, errback) => {
    let sh = 'sh';
    let flags = '-c';

    if (process.platform === 'win32') {
      sh = process.env.comspec || 'cmd';
      flags = '/d /s /c';
      opts.windowsVerbatimArguments = true;
    }

    let args = [flags, cmd];
    let value = '';

    let proc = spawn(sh, args, opts);
    proc.stdout.on('data', (chunk) => value += chunk);

    proc.on('error', errback).on('close', (code) => {
      if (code === 0) return r({ name, value });
      opts.log('Recipe exited with code %d: \n%s', code, cmd);
    });
  });
};

cmd.template = (file, { globs, ft, log }) => {
  return (data) => {
    log('Minimatch file: %s pattern:', file, globs);
    let match = Object.keys(globs).find(glob => minimatch(file, glob));

    if (!match) {
      log('No minimatch file: %s', file, data);
      return cmd.findTemplate(file, { ft, log, data });
    }

    log('Minimatch file: %s pattern: %s', file, globs[match]);
    let template = path.resolve(DIR, globs[match]);
    return { context: data, template };
  };
};

cmd.filetype = (file) => {
  let ext = path.extname(file).replace(/^\./, '');
  if (ext) return ext;
  return '';
};

cmd.findTemplate = (file, opts = {}) => {
  let ft = opts.ft || cmd.filetype(file);
  let filepath = path.join(DIR, file);
  let ftfile = path.join(DIR, ft + '.template');
  let skelfile = path.join(DIR, 't.' + ft);

  opts.log('Filetype %s', ft, cmd.filetype(file));
  opts.log('Check %s template', filepath);
  opts.log('Check %s template', ftfile);
  opts.log('Check %s template', skelfile);

  // first try loading by filename
  // then by filetype
  // then by a more general skeleton one
  let context = opts.data || {};
  return exists(filepath) ? { context, template: filepath }
    : exists(ftfile) ? { context, template: ftfile }
    : exists(skelfile) ? { context, template: skelfile }
    : { context };
};
