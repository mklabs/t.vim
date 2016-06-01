const fs     = require('fs');
const path   = require('path');
const hbs    = require('handlebars');
const moment = require('moment');
const parse  = require('./opts');
const cmd    = require('./cmd');
const debug  = require('debug')('tvim');
const { readFileSync: read } = fs;
const { existsSync: exists } = fs;

const HOME = process.platform ? process.env.HOME : process.env.USERPROFILE;
const json = {
  defs: require('../conf/defs.json'),
  globs: require('../conf/globs.json')
};

module.exports = (argv = process.argv.slice(2), options = {}) => {
  let opts = Object.assign({}, parse(argv), options);

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

  if (!opts.file) return;
  debug('opts.file', opts.file);
  let filepath = path.resolve(opts.file.replace('~', HOME));

  debug('Filepath', filepath);

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

  // Minimatch patterns
  // console.log(globs);

  cmd.init().catch((e) => console.log(e)).then((data) => {
    let defaults = {
      day,
      year,
      month,
      date,
      datetime,
      ext,
      basename,
      filename,
      filepath,
      user
    };

    let context = Object.assign({}, data, defaults);
    if (!opts.template) return;

    let template = path.resolve(opts.template.replace('~', HOME));
    if (!exists(template)) return debug('ERR: template %s not found', template);

    if (opts.debug || opts.d) debug('Context', context);
    debug('Template', template);
    template = read(template, 'utf8');
    template = hbs.compile(template);
    stream.write(template(context));
  });
};
