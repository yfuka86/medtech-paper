alpha.export 'views.home.Main'

# @constructor
# @extends {alpha.mvc.View}
class views.home.Main extends alpha.mvc.View

  # @type {string}
  className: 'home-views-wrapper'

  # @override
  getTemplateFunction: ->
    ''

  # @override
  enterDocument: ->
    super()
