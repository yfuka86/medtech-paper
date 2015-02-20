#
# @fileoverview Backbone.Collection with measure of memory leak
#

alpha.export 'alpha.mvc.Collection'


# @constructor
# @extends {Backbone.Collection}
class alpha.mvc.Collection extends Backbone.Collection

  # @type {string}
  indexURL: null

  # @type {number}
  offset: null

  # @type {number}
  limit: null

  # @type {number}
  total: null

  # Whether called "dispose".
  #
  # @type {boolean}
  # @private
  _disposed: false

  # @override
  initialize: (models, options = {}) ->
    @total  = 0
    @offset = options.offset ? 0
    @limit  = options.limit ? 20

  # @return {Object}
  primitiveObject: ->
    _.map @models, (model) ->
      model.primitiveObject()

  # @override
  clone: (opts) ->
    new @constructor(_.map @models, (model) -> model.clone(opts))

  # @return {string} .
  url: ->
    params = @params or {}
    params.offset = @offset if @offset?
    params.limit = @limit if @limit?

    return if $.isEmptyObject(params)
      @indexURL
    else
      @indexURL + '?' + $.param(params)

  # @param {Object} opts .
  fetch: (opts) ->
    opts or= {}

    if opts.reset
      @offset = 0

    opts.parse ?= true

    @params = null if opts.reset
    @params = opts.params if opts.params

    defer = alpha.async.ajax
      type: 'GET'
      url: @url()
      context: @
      data: @params

    defer.done (data, status, xhr) =>
      @trigger 'sync', @, data, opts
      method = if opts.reset then 'reset' else 'set'
      @[method](data, opts)

    defer.fail (xhr, status, err) =>
      @trigger 'error', @, data, opts
      # resp = $.parseJSON(xhr.responseText)

    return defer

  # @param {Object} opts .
  loadMore: (opts) ->
    opts or= {}
    opts.reset = false
    if opts and _.isNumber opts.offset
      @offset = opts.offset
    if opts and _.isNumber opts.limit
      @limit = opts.limit
    @fetch opts

  # @override
  parse: (resp) ->
    if resp.info and resp.models
      @total = resp.info.total if resp.info
      return resp.models
    else
      return resp

  # @protected
  disposeInternal: ->

  # Prevent memory leaks.
  dispose: ->
    return if @_disposed
    @_disposed = true

    # fire an event to notify associated collections and views.
    @trigger 'dispose', @

    # unbind all referenced handlers.
    @stopListening()
    # remove all event handlers on this module.
    @off()

    delete @_events

    if @models and @models.length > 0
      for model in @models
        model.dispose()

    properties = [
      'model',
      'models',
      'comparator',
      'params',
      '_byId',
      '_byCid'
    ]
    delete @[prop] for prop in properties

    # custom disposing.
    @disposeInternal()
