const cli = require('gentle-cli');
const path = require('path');
const SEPARATOR = process.platform === 'win32' ? '\\' : '/'

describe('tvim (1)', () => {
  let filepath = path.join(__dirname, '../bin/tvim');

  it('hbsify templates', (done) => {
    cli()
      .use(`node ${filepath}`)
      .expect(0, done);
  });

  it('hbsify templates', (done) => {
    cli()
      .use(`node ${filepath} --file foo.js --template test/templates/javascript.template.js`)
      .expect('MIT')
      .expect('tvim')
      .expect('vim template plugin thing')
      .expect(0, done);
  });

  it('prints defs config file on --defs', (done) => {
    cli()
      .use(`node ${filepath} --defs`)
      .expect(`conf${SEPARATOR}defs.json`)
      .expect(0, done);
  });

  it('prints globs config file on --glob', (done) => {
    cli()
      .use(`node ${filepath} --globs`)
      .expect(`conf${SEPARATOR}globs.json`)
      .expect(0, done);
  });

  it('prints config directory on --config', (done) => {
    cli()
      .use(`node ${filepath} --config`)
      .expect(path.join(__dirname, '../conf').replace(/\//g, SEPARATOR))
      .expect(0, done);
  });
});
