# fragments

> unique powerful approach to web application development

core selling points:
- dependency injection
- request time dependency injection
- angular style dependency injection on the server side
- use angularjs style dependency injection to structure your applications
- functional
- flat name space (long self-documenting, descriptive, unique-per-application function names)

[![NPM Package](https://img.shields.io/npm/v/fragments.svg?style=flat)](https://www.npmjs.org/package/fragments)
[![Build Status](https://travis-ci.org/snd/fragments.svg?branch=master)](https://travis-ci.org/snd/fragments/branches)
[![Dependencies](https://david-dm.org/snd/fragments.svg)](https://david-dm.org/snd/fragments)

**documentation below is in progress. for now take a look at the [example app](/example),
[tests](/test) and [source](/src).**

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

## whats this?

fragments is a library to structure applications.

with fragments you'll write highly expressive code like this:

```
module.exports.currentUser = (
  session
  firstUserWhereId
) ->
  firstUserWhereId session.userId

module.exports.

module.exports.canAccessResource = (
  currentUser
) ->
  currentUser.

module.exports.
  


module.exports.server = (
  action
) ->
  MIDDLEWARE
  
```

motivating code example

encourages good design

lets

simple, testable

promises

first of all fragments is a way to structure 
**fragments**
each fragment may depend on other fragments and is in turn depended on
by other fragments.

just enough structure



## versioning

fragments will break backwards compatibility often.
whenever it...

```
MAJOR.BREAKING.BACKWARDS-COMPATIBLE
```

increments in major `MAJOR` happen

increments in `BREAKING` break backwards compatiblity

increments in `BACKWARDS-COMPATIBLE` are backwards compatible

we don't use semver because we don't see its distinction between
`ADDING in a bakwards compatible manner` and `PATCH` as more
important than the distinction
and official new release.

the workflow is unstructured.

doesn't feel right to bump MAJOR on every breaking change.
we bump COMPATIBLE on ever backwards compatible change.
we do however bump BREAKING on every breaking change.
we bump BREAKING often.
we bump MAJOR rarely.
on noteworthy events when a significant change in direction is completed.
`1.0.0` will happen once the API has normalized

`2.0.0` will happen

we won't support any versions but the newest.

## [license: MIT](LICENSE)
