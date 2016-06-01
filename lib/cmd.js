/* eslint no-return-assign: 0 */
const pkgup = require('read-pkg-up');
const { spawn } = require('child_process');

let cmds = {};
let cmd = module.exports = (name, cmd) => {
  cmds[name] = cmd;
};

cmd.init = () => {
  return Promise.all(cmd.execAll(cmds))
    .then(cmd.reduce)
    .then(cmd.pkgup)
    .catch(err => console.log(err));
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

      console.error('Recipe exited with code %d: \n%s', code, cmd);
    });
  });
};
