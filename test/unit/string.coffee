fragments = require '../../src/fragments'

module.exports =

  'camelToSnake': (test) ->
    test.equal 'camel_case', fragments.camelToSnake('camelCase')
    test.done()

  'snakeToCamel': (test) ->
    test.equal 'snakeCase', fragments.snakeToCamel('snake_case')
    test.done()

  'camelToHyphen': (test) ->
    test.equal 'camel-case', fragments.camelToHyphen('camelCase')
    test.done()

  'hyphenToCamel': (test) ->
    test.equal 'hyphenDelimited', fragments.hyphenToCamel('hyphen-delimited')
    test.done()

  'colonToSnake': (test) ->
    test.equal 'colon_delimited', fragments.colonToSnake('colon:delimited')
    test.done()

  'snakeToColon': (test) ->
    test.equal 'snake:case', fragments.snakeToColon('snake_case')
    test.done()

  'hyphenColonToCamelSnake': (test) ->
    test.equal 'hyphen_colonTo_camelSnake', fragments.hyphenColonToCamelSnake('hyphen:colon-to:camel-snake')
    test.done()

  'camelSnakeToHyphenColon': (test) ->
    test.equal 'camel:snake-to:hyphen-colon', fragments.camelSnakeToHyphenColon('camel_snakeTo_hyphenColon')
    test.done()
