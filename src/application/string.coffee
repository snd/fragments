# camelToSnake('camelCase') -> 'camel_case'
module.exports.fragments_camelToSnake = ->
  (string) ->
    string.replace /([a-z][A-Z])/g, (m) -> m[0] + '_' + m[1].toLowerCase()

# snakeToCamel('snake_case') -> 'snakeCase'
module.exports.fragments_snakeToCamel = ->
  (string) ->
    string.replace /_([a-z])/g, (m) -> m[1].toUpperCase()

# camelToHyphen('camelCase') -> 'camel-case
module.exports.fragments_camelToHyphen = ->
  (string) ->
    string.replace /([a-z][A-Z])/g, (m) -> m[0] + '-' + m[1].toLowerCase()

# hyphenToCamel('hyphen-delimited') -> 'hyphenDelimited'
module.exports.fragments_hyphenToCamel = ->
  (string) ->
    string.replace /-([a-z])/g, (m) -> m[1].toUpperCase()

# colonToSnake('colon:delimited') -> 'colon_delimited'
module.exports.fragments_colonToSnake = ->
  (string) ->
    string.replace /:/g, '_'

# snakeToColon('snake_case') -> 'snake:case'
module.exports.fragments_snakeToColon = ->
  (string) ->
    string.replace /_/g, ':'

# hyphenColonToCamelSnake('hyphen:colon-to:camel-snake') -> 'hyphen_colonTo_camelSnake'
module.exports.fragments_hyphenColonToCamelSnake = (
  fragments_hyphenToCamel
  fragments_colonToSnake
) ->
  (string) ->
    fragments_hyphenToCamel(fragments_colonToSnake(string))

# camelSnakeToHyphenColon('camel_snakeTo_hyphenColon') -> 'camel:snake-to:hyphen-colon'
module.exports.fragments_camelSnakeToHyphenColon = (
  fragments_camelToHyphen
  fragments_snakeToColon
) ->
  (string) ->
    fragments_camelToHyphen(fragments_snakeToColon(string))
