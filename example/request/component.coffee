module.exports.ComponentLayout = (react) ->
  react.createClass
    render: ->
      props = this.props
      react.kup (k) ->
        k.html ->
          k.head ->
            k.meta charSet: 'utf-8'
            k.meta name: "viewport", content: "user-scalable=no, initial-scale=1"
          k.body {
            dataSpy: "scroll"
            dataTarget: ".ComponentNavbar"
            dataOffset: "80"
          }, ->
            react.Children.forEach props.children, (child) ->
              k.build child

module.exports.ComponentLanding = (react) ->
  react.createClass
    render: ->
      props = this.props
      react.kup (k) ->
        k.div ->
          k.h1 "numbers"
          k.ul ->
            props.items.forEach (item) ->
              k.li item

