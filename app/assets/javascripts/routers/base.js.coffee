alpha.export 'routers.Base'

# @constructor
# @extends {freee.mvc.Router}
class routers.Base extends alpha.mvc.Router

  # @override
  initialize: () ->
    @_bindRouters()

  # @return {Array} .
  sharedRouters: ->
    # these routers should be in ./shared
    return [
      routers.shared.Main
      routers.shared.PaperList
    ]

  # @return {Object} .
  routers: ->
    # these routers are based on the controllers of Rails
    return {
      '(/)'                        : routers.Home
    }

  # routers: ->
  #   return {
  #     '/home*p': routers.Home
  #     ('url(Backbone.Router準拠の表記)': ルーターのクラス(coffeescript))
  #   }
  #
  # のように指定すると、routers.Baseの初期化時に、
  # urlがマッチする場合について指定したrouterをaddします（読み込みます）
  #
  # @param {String} route .
  # @param {freee.mvc.Router} subRouter .
  addRouter: (route, router) ->
    route = @_routeToRegExp route unless _.isRegExp route
    path = window.location.pathname
    if route.test(path)
      new router

  #
  _bindRouters: ->
    Backbone.history.allHandlers = []
    Backbone.history.route = (route, callback) ->
      @allHandlers.unshift({route: route, callback: callback})
    _.each @sharedRouters(), (router) =>
      @addRouter '/*p', router

    Backbone.history.route = (route, callback) ->
      @handlers.unshift({route: route, callback: callback})
    _.each @routers(), (router, route) =>
      @addRouter route, router
