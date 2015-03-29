fragments = require '../src/fragments'
app = fragments()

module.exports =

  'camelToSnake': (test) ->
    app (camelToSnake) ->
      test.equal 'camel_case', camelToSnake('camelCase')
      test.done()

  'snakeToCamel': (test) ->
    app (snakeToCamel) ->
      test.equal 'snakeCase', snakeToCamel('snake_case')
      test.done()

  'camelToHyphen': (test) ->
    app (camelToHyphen) ->
      test.equal 'camel-case', camelToHyphen('camelCase')
      test.done()

  'hyphenToCamel': (test) ->
    app (hyphenToCamel) ->
      test.equal 'hyphenDelimited', hyphenToCamel('hyphen-delimited')
      test.done()

  'colonToSnake': (test) ->
    app (colonToSnake) ->
      test.equal 'colon_delimited', colonToSnake('colon:delimited')
      test.done()

  'snakeToColon': (test) ->
    app (snakeToColon) ->
      test.equal 'snake:case', snakeToColon('snake_case')
      test.done()

  'hyphenColonToCamelSnake': (test) ->
    app (hyphenColonToCamelSnake) ->
      test.equal 'hyphen_colonTo_camelSnake', hyphenColonToCamelSnake('hyphen:colon-to:camel-snake')
      test.done()

  'camelSnakeToHyphenColon': (test) ->
    app (camelSnakeToHyphenColon) ->
      test.equal 'camel:snake-to:hyphen-colon', camelSnakeToHyphenColon('camel_snakeTo_hyphenColon')
      test.done()
