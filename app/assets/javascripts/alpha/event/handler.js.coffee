alpha.export 'alpha.event.Handler'

# @extends {Backbone.Event}
class alpha.event.Handler

  # @type {Object}
  # @private
  _context: null

  # @type {Object}
  # @private
  _listenersMap: null

  #
  constructor: (opt_context) ->
    _.extend @, Backbone.Events

    @_context = opt_context or @
    @_listenersMap = {}

  # @param {*} src .
  # @param {string} type .
  # @param {Function} listener .
  # @param {Object=} opt_context .
  listen: (src, type, listener, opt_context) ->
    if !src or !type or !listener
      throw Error('InvalidArgumentsError')

    uid = alpha.getUid(src) + type + alpha.getUid(listener)
    context = opt_context or (@_context or listener)
    listenerObj = @_createListener(src, type, listener, context)

    match = _.find @_listenersMap, (value, key) ->
      return key is uid
    , @
    return if match

    @_listenersMap[uid] = listenerObj
    $(src).on type, listenerObj.proxy

  # @param {*} src .
  # @param {string} type .
  # @param {Function} listener .
  # @param {Object=} opt_context .
  listenOnce: (src, type, listener, opt_context) ->
    if !src or !type or !listener
      throw Error('InvalidArgumentsError')

    context = opt_context or @_context or listener
    $(src).one type, _.bind(listener, context)

  # @param {*} src .
  # @param {string} type .
  # @param {Function} listener .
  # @param {Object=} opt_context .
  unlisten: (src, type, listener, opt_context) ->
    if !src or !type or !listener
      throw Error('InvalidArgumentsError')

    uid = alpha.getUid(src) + type + alpha.getUid(listener)
    context = opt_context or (@_context or listener)
    listenerObj = _.find @_listenersMap, (value, key) ->
      return key is uid
    , @
    return unless listenerObj

    $(src).off type, listenerObj.proxy
    delete @_listenersMap[uid]

  #
  unlistenAll: ->
    for uid, listenerObj of @_listenersMap
      $(listenerObj.src).off listenerObj.event, listenerObj.proxy
      delete @_listenersMap[uid]
    @_listenersMap = {}

  # @param {Element|jQuery} src
  # @param {string} event .
  # @param {Function} listener .
  # @param {Object} context .
  # @private
  _createListener: (src, event, listener, context) ->
    proxy = if context
      _.bind listener, context
    else
      listener

    return {
      src: src
      event: event
      listener: listener
      context: context
      proxy: proxy
    }

  #
  dispose: ->
    @unlistenAll()
