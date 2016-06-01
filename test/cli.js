const cli = require('gentle-cli');
const path = require('path');

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
});
