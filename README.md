# fragments

*fragments has beta status.
it's been in production use for over a year.
things are quite settled now.
i aim for release in fall/winter 2015.
expect some breakage until then but not much.
i won't support any but the newest version.*

*the documentation in this readme is work in progress and currently unfinished !*

[![BETA](http://img.shields.io/badge/Stability-BETA-orange.svg?style=flat)]()
[![NPM Package](https://img.shields.io/npm/v/fragments.svg?style=flat)](https://www.npmjs.org/package/fragments)
[![Build Status](https://travis-ci.org/snd/fragments.svg?branch=master)](https://travis-ci.org/snd/fragments/branches)
[![Dependencies](https://david-dm.org/snd/fragments.svg)](https://david-dm.org/snd/fragments)

<!--
start with a motivating text which sells fragments and
makes readers read on.
this text should not be longer than one page.
-->

**fragments structures web applications with (request time) dependency injection**

<!--

fragments is hackable
small codebase.

fragments was born out of the

keeping complex request handling logic testable.

functional

passing information around.

programming is fun.

fun

fragments core strength is dependency injection on every request.

above all f
fragments is a library to structure web applications in a way
that echews boilerplate is testable,
beautiful functional code.
understandable
extendable.

fragments is unique in that it has dependency injection that happens
on each request.

encourages good design

lets

simple, testable

promises

first of all fragments is a way to structure 
**fragments**
each fragment may depend on other fragments and is in turn depended on
by other fragments.

just enough structure


fragments is not a framework.

there's a minimal example and a walkthrough.

there's also a bigger example app with integration tests.
-->

<!--
xyz.com is a real world app
... is the repository
-->

<!--
functional style.

your parts and the parts fragments brings are treated equaly.
you can overwrite any granular part you like.

core selling points:
- dependency injection
- request time dependency injection
- angular style dependency injection on the server side
- use angularjs style dependency injection to structure your applications
- method missing
- functional
- flat name space (long self-documenting, descriptive, unique-per-application function names)

we'll look at a very short fragments app
-->

<!--
it allows you to write code like this:
-->

<!--
with fragments you'll write highly expressive code like this:
-->

<!--
show some code
motivating code example
-->

[hello-world.js](hello-world.js) is a minimal fragments app contained
in a single file with only around 50 lines of code.
when called with `./hello-world.js serve` it starts a http server
on the port that is set in the environment variable `PORT`.
that server responds to http `GET` requests 
to path `/hello-world` with `ContentType` `text/plain` and body `Hello world`.
it responds with status code `404 Not Found` to all other requests.

``` javascript
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
  endHelloWorld: function(
    end200Text
  ) {
    end200Text('Hello world');
  },
  actionHelloWorld: function(
    GET
  ) {
    return GET('/hello-world', function(
      endHelloWorld
    ) {
      endHelloWorld();
    })
  }
};

// thats it for the application code !
// below is just configuration boilerplate.
// it's needed only once per app.

var fragments = require('fragments');
var hinoki = require('hinoki');

var source = hinoki.source([
  factories,
  fragments.source,
  fragments.umgebung
]);

var source = hinoki.decorateSourceToAlsoLookupWithPrefix(source, 'fragments_');

var app = fragments(source);

app.runCommand();
```

<!--
explain the code and the concepts used in it
-->

expect a detailed walkthrough soon.

<!--

there's a lot going on. let's break it down:

-->

<!--

### commands
-->

<!--
there's much more code in the example app.
you should be able to understand it now.
-->

see the [example app](example) as well.  
entry point is [example/app](./example/app).  
there are [integration tests](test) for the example app.

fragments builds on top of [hinoki](https://github.com/snd/hinoki):
*effective yet simple dependency injection and more for Node.js and browsers*

<!--
other nice things
-->

<!--
like postgres ? there's [fragments-postgres]()
it integrates seemlessly with fragments and has all sorts
of good stuff (like rubys method missing in node).

like users ? there's [fragments-user]()
rest user api in minutes that you can still maintain after months.

here is why its worth your time.

new potential for preconfigured stuff
**documentation below is in progress. for now take a look at the [example app](/example),
[tests](/test) and [source](/src).**
-->

<!--

more about sources

i've built it for friends and myself to make building complex server side web applications in nodejs faster and more fun.

fun and easy

why should i bother ?

here’s why reading on is worth your time (implied)

testable, maintainable, sustainable
fun and fast
faster and more fun

minimal app
let’s walk through this



be really concrete

desirable properties

views can directly depend on data

shutdown system with ordering


why not sails

why not koa

why not express

-->

## [license: MIT](LICENSE)
