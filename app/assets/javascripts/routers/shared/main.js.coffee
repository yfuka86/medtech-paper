alpha.export 'routers.shared.Main'

# @constructor
# @extends {alpha.mvc.Router}
class routers.shared.Main extends alpha.mvc.Router

  routes:
    '/*p': 'shared'

  # @param {?string} query
  shared: (query) ->
    @flashNotificator()

  flashNotificator: (opts={})->
    renderMessage = (content, opts, mode)->
      return if content.length is 0

      try
        content = $.parseJSON content
      catch

      if _.isString content
        views.components.addNormalMessage content, opts, mode
      else if _.isArray content
        views.components.addNormalMessage content.join('\n'), opts, mode
      else if _.isObject content
        views.components.addNormalMessage content.message, opts, mode

    content = $.trim($('#success').html())
    renderMessage(content, _.extend({}, opts, {timeout: 2000, closeable: true}), 'success')

    content = $.trim($('#alert').html())
    renderMessage(content, opts, 'error')

    content = $.trim($('#notification').html())
    renderMessage(content, _.extend({}, opts, {timeout: 2000, closeable: true}))
