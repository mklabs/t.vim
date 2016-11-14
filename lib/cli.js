const fs        = require('fs');
const path      = require('path');
const hbs       = require('handlebars');
const moment    = require('moment');
const debug     = require('debug');
const parse     = require('./opts');
const cmd       = require('./cmd');

const { readFileSync: read } = fs;
const { existsSync: exists } = fs;

const { HOME, SEPARATOR } = require('./constants');

const json = {
  defs: require('../conf/defs.json'),
  globs: require('../conf/globs.json')
};

module.exports = (argv = process.argv.slice(2), options = {}) => {
  let opts = Object.assign({}, parse(argv), options);
  opts.template = opts.template ? opts.template.replace('~', HOME) : null;

  if (opts.debug || opts.d) debug.enable('tvim*');

  let log = debug('tvim');
  log('Opts', opts);

  let stream = opts.stream;
  if (typeof stream === 'string') stream = fs.createWriteStream(path.resolve(stream));
  stream = stream || process.stdout;

  if (opts.defs) {
    // Print conf/dejs.json location on --defs
    console.log(path.join(__dirname, '../conf/defs.json'));
    process.exit(0);
  }

  if (opts.globs) {
    // Print conf/globs.json location on --globs
    console.log(path.join(__dirname, '../conf/globs.json'));
    process.exit(0);
  }

  if (opts.config) {
    // Print conf/ directory on --config
    console.log(path.join(__dirname, '../conf'));
    process.exit(0);
  }

  let defs = Object.assign({}, json.definitions, options.definitions);
  let globs = Object.assign({}, json.globs, options.globs);
  log('Globs', globs);

  if (!opts.file) return;
  let filepath = path.resolve(opts.file.replace('~', HOME));
  filepath = filepath.replace(path.resolve() + SEPARATOR, '');
  log('Filepath', filepath, path.resolve());

  // File
  let ext = path.extname(filepath);
  let basename = path.basename(filepath);
  let filename = basename.replace(ext, '');

  // Date
  let day = moment().format('d');
  let year = moment().format('YYYY');
  let month = moment().format('M');
  let date = moment().format('YYYY-M-d');
  let datetime = moment().format('YYYY-M-d HH:mm');

  // Definitions
  let definitions = Object.assign({}, defs, {
    hostname: 'hostname',
    mail: 'git config --global user.email'
  });

  let user = process.env.USER || process.env.USERNAME;

  Object.keys(definitions).forEach((name) => {
    cmd(name, definitions[name]);
  });

  let file = opts.file;
  cmd.init(file, { ft: opts.ft, globs, log }).catch((e) => console.error(e))
    .then((data) => {
      if (opts.silly) log('Data', data);

      let defaults = {
        day,
        year,
        month,
        date,
        datetime,
        ext,
        file,
        filename,
        filepath,
        basename,
        user
      };

      let context = Object.assign({}, data.context, defaults);
      let template = data.template || opts.template;

      if (!template) return log('No valid template');

      template = path.resolve(template);
      if (!exists(template)) return log('ERR: template %s not found', template);

      if (opts.silly) log('Context', context);

      log('Template', template);
      template = read(template, 'utf8');
      template = hbs.compile(template);

      stream.write(template(context));
    });
};
