module.exports.ComponentNavigation = (
  react
) ->
  react.createClass
    render: ->
      react.kup (k) ->
        k.div {id: 'navigation'}

module.exports.ComponentContent = (
  react
) ->
  react.createClass
    render: ->
      react.kup (k) ->
        k.div {id: 'content'}

module.exports.layout = (
  k
  ComponentNavigation
  $meta
) ->
  (content) ->
    k.html ->
      k.head ->
        $meta.forEach (meta) ->
          k.meta meta
      k.body ->
        k.div {id: 'container'}, ->
          k.div {id: 'navigation-wrapper'}, ->
            k.react ComponentNavigation
          k.div {id: 'content-wrapper'}, ->
            content?()
