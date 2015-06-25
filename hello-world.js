#!/usr/bin/env node

var factories = {
  server: function(
    commonMiddlewarePrelude,
    sequenz,
    actionHelloWorld,
    notFound
  ) {
    return sequenz([
      commonMiddlewarePrelude,
      actionHelloWorld,
      notFound
    ]);
  },
  notFound: function(
    MIDDLEWARE
  ) {
    return MIDDLEWARE(function(
      endNotFound
    ) {
      endNotFound();
    });
  },
  actionHelloWorld: function(
    GET
  ) {
    return GET('/hello-world', function(
      end200Text
    ) {
      end200Text('hello-world');
    })
  }
};

// below is just configuration boilerplate

var fragments = require('./lib/fragments');
var hinoki = require('hinoki');

var source = hinoki.source([
  factories,
  fragments.source,
  fragments.umgebung
]);

var source = hinoki.decorateSourceToAlsoLookupWithPrefix(source, 'fragments_');

var app = fragments(source);

app.runCommand();
