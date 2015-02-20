#
# @fileoverview Backbone.Model with measure of memory leak
#

alpha.export 'alpha.mvc.Model'


# @constructor
# @extends {Backbone.Model}
class alpha.mvc.Model extends Backbone.Model

  # @type {string}
  indexURL: ''

  # Whether called "dispose".
  #
  # @type {boolean}
  # @private
  _disposed: false

  # Circular applying.
  #
  # @return {Object} .
  primitiveObject: ->
    attrs = _.clone(@attributes)
    for k, v of attrs
      if (v instanceof Backbone.Collection) or (v instanceof Backbone.Model)
        attrs[k] = v.primitiveObject()
    return attrs

  # Circular applying.
  # @param {Object} opts .
  # @return {Backbone.Model}
  clone: (opts) ->
    attrs = _.clone(@attributes)
    if opts?.keepId isnt true
      attrs.id ?= null
    for k, v of attrs
      if (v instanceof Backbone.Collection) or (v instanceof Backbone.Model)
        attrs[k] = v.clone(opts)

    new @constructor(attrs)

  # @param {Object} opts .
  fetch: (opts) ->
    opts or= {}

    opts.parse ?= true

    return if @isNew()

    defer = alpha.async.ajax
      type: 'GET'
      url: "#{@indexURL}/#{@get('id')}"
      context: @
      data: opts.params

    defer.done (data, status, xhr) =>
      @clear()
      @set data, opts
      @trigger 'sync', @, data, opts

    defer.fail (xhr, status, err) =>
      resp = $.parseJSON(xhr.responseText)
      @trigger 'error', @, data, opts

    return defer


  # @param {Object} opts .
  save: (opts) ->
    opts or= {}

    opts.parse ?= true

    params = opts.params or {}

    if @isNew()
      type = 'POST'
      url = @indexURL
    else
      type = 'PUT'
      url = "#{@indexURL}/#{@get('id')}"

    defer = alpha.async.ajax
      type: type
      url: url
      context: @
      data: _.extend {}, @toJSON(), params

    defer.done (data, status, xhr) =>
      @clear()
      @set data, opts
      @trigger 'sync', @, data, opts

    defer.fail (xhr, status, err) =>
      resp = $.parseJSON(xhr.responseText)
      @trigger 'error', @, data, opts

    return defer

  # @param {Object} opts .
  destroy: (opts) ->
    opts or= {}

    return if @isNew()

    defer = alpha.async.ajax
      type: 'DELETE'
      url: "#{@indexURL}/#{@get('id')}"
      context: @
    @trigger 'destroy', @, @collection, opts

    defer.done (data, status, xhr) =>
      @trigger 'sync', @, data, opts
      @dispose()

    defer.fail (xhr, status, err) =>
      resp = $.parseJSON(xhr.responseText)
      @trigger 'error', @, data, opts

    return defer

  # @return {number} .
  parseDate: (attr) ->
    dateStr = @get attr
    return if dateStr then Date.parse(dateStr.replace(/-/g, '/')) else NaN

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

    properties = [
      'cid',
      'collection',
      'attributes',
      'changed',
      '_escapedAttributes',
      '_previousAttributes',
      '_silent',
      '_pending',
      '_callbacks'
    ]
    delete @[prop] for prop in properties

    # custom disposing.
    @disposeInternal()
