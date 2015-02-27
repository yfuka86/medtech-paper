# Observing DOMContentLoaded event.
$(document).ready ->
  # Override
  Backbone.history.loadUrl = (fragmentOverride) ->
    fragment = @fragment = @getFragment(fragmentOverride)
    path = location.pathname + (if fragment then '#' + fragment else '')

    executer = (handler) ->
      if (handler.route.test(matchedPath = path) or
          handler.route.test(matchedPath = location.pathname))
        handler.callback matchedPath
        return true

    _.each @allHandlers, executer
    matched = _.any @handlers, executer
    return matched

  window['baseRouter'] = [new routers.Base]
  Backbone.history.start {hashChange: true}
