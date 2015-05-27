var fragments = require('fragments');
var hinoki = require('hinoki');

var factories = {
  server: function(
    commonMiddlewarePrelude,
    sequenz
    actionHelloWorld
  ) {
    return sequenz([
      commonMiddlewarePrelude
      actionHelloWorld
    ]);
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

var app = fragments([factories, fragments.source]);

app.runCommand();
