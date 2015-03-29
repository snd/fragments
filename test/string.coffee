fragments = require '../fragments'

module.exports =

  'camelToSnake': (test) ->
    fragments (camelToSnake) ->
      test.equal 'camel_case', camelToSnake('camelCase')
      test.done()

  'snakeToCamel': (test) ->
    fragments (snakeToCamel) ->
      test.equal 'snakeCase', snakeToCamel('snake_case')
      test.done()

  'camelToHyphen': (test) ->
    fragments (camelToHyphen) ->
      test.equal 'camel-case', camelToHyphen('camelCase')
      test.done()

  'hyphenToCamel': (test) ->
    fragments (hyphenToCamel) ->
      test.equal 'hyphenDelimited', hyphenToCamel('hyphen-delimited')
      test.done()

  'colonToSnake': (test) ->
    fragments (colonToSnake) ->
      test.equal 'colon_delimited', colonToSnake('colon:delimited')
      test.done()

  'snakeToColon': (test) ->
    fragments (snakeToColon) ->
      test.equal 'snake:case', snakeToColon('snake_case')
      test.done()

  'hyphenColonToCamelSnake': (test) ->
    fragments (hyphenColonToCamelSnake) ->
      test.equal 'hyphen_colonTo_camelSnake', hyphenColonToCamelSnake('hyphen:colon-to:camel-snake')
      test.done()

  'camelSnakeToHyphenColon': (test) ->
    fragments (camelSnakeToHyphenColon) ->
      test.equal 'camel:snake-to:hyphen-colon', camelSnakeToHyphenColon('camel_snakeTo_hyphenColon')
      test.done()
