
all: help

help:
	bake -h

babel:
	babel lib/ -d src/

test: eslint babel mocha

testc: test-cli test-cli-glob
testcg: test-cli-glob test-cli-glob-none

test-cli:
	node bin/tvim --file foo.js --template test/templates/javascript.template.js -d

test-cli-glob:
	node bin/tvim --file bin/foo.js -d

test-cli-glob-none:
	node bin/tvim --file pazejzepja/foo.js -d

mocha:
	mocha -R spec

eslint:
	eslint .

fix:
	eslint . --fix

watch:
	watchd lib/**.js test/**.js package.json -c 'bake babel'

release: version push publish

version:
	standard-version -m '%s'

push:
	git push origin master --tags

publish: test
	npm publish
