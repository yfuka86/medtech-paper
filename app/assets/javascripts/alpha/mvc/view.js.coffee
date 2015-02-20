#
# @fileoverview View class with memory management like Backbone.View.
#
alpha.export 'alpha.mvc.View'

# ビューのライフサイクル
# - initialize
#     ビューの生成
# - render
#     ビューの描画、再描画
# - decorate
#     既存のHTMLへのアタッチ
# - enterDocument
#     DOMツリーに追加された
# - exitDocument
#     DOMツリーから外れた
# - dispose
#     ビューの破棄
#
# @extends {Backbone.View}
class alpha.mvc.View

  # @type {string}
  cid: null

  # @type {alpha.events.EventHandler}
  # @private
  _eventHandler: null

  # Parent view.
  #
  # @type {alpha.mvc.View}
  # @private
  _parent: null

  # Child views.
  #
  # @type {Array.<alpha.mvc.View>}
  # @private
  _subviews: null

  # Whether rendered once.
  #
  # @type {boolean}
  # @private
  _rendered: false

  # Whether decorated once.
  #
  # @type {boolean}
  # @private
  _decorated: false

  # Whether added in DOM tree.
  #
  # @type {boolean}
  # @private
  _inDocument: false

  # Whether keep model and collection at dispose.
  #
  # @type {boolean}
  # @private
  _keepModelAndCollection: false


  # @param {Object=} opt_options .
  constructor: (opt_options) ->
    _.extend @, Backbone.Events

    @cid = _.uniqueId('view')
    @_configure opt_options or {}

    @_subviewMap = {}
    @_subviews = []
    @initialize.apply @, arguments


  # @return {alpha.events.EventHandler} .
  getHandler: ->
    return @_eventHandler or (@_eventHandler = new alpha.event.Handler(@))


  # @param {string=} opt_selector .
  # @return {Element} .
  getContentElement: (opt_selector) ->
    return if opt_selector
      @$(opt_selector).get(0)
    else
      @el


  # @protected
  initialize: ->
    # Please override me


  # Event proxy method
  listen: (src, type, listener, opt_context) ->
    if _.isElement(src) or (src.jquery and src.length > 0)
      @getHandler().listen(src, type, listener, opt_context)
    else
      if opt_context
        listener = _.bind(listener, opt_context)
      @listenTo(src, type, listener)


  # Event proxy method
  unlisten: (src, type, listener, opt_context) ->
    if _.isElement(src) or (src.jquery and src.length > 0)
      @getHandler().unlisten(src, type, listener, opt_context)
    else
      if opt_context
        listener = _.bind(listener, opt_context)
      @stopListening(src, type, listener)


  # ビューを新規DOMとして指定要素に描画する
  #
  # @param {Element|string=} opt_parentElement .
  render: (opt_parentElement) ->
    opt_parentElement = @_convertElementForRender(opt_parentElement)
    @_render opt_parentElement


  # ビューを新規DOMとして指定要素の前に描画する
  #
  # @param {Element|string} sibling .
  renderBefore: (sibling) ->
    sibling = @_convertElementForRender(sibling)
    @_render sibling.parentNode, sibling


  # ビューを新規DOMとして指定要素の後ろに描画する
  #
  # @param {Element|string} sibling .
  renderAfter: (sibling) ->
    sibling = @_convertElementForRender(sibling)
    @_render sibling.parentNode, null, sibling


  _convertElementForRender: (el) ->
    if _.isString el
      $(el).get(0)
    else if el?.jquery
      el.get(0)
    else
      el


  # @param {Element=} opt_parentElement .
  # @param {Element=} opt_beforeElement .
  # @private
  _render: (opt_parentElement, opt_beforeElement, opt_afterElement) ->
    # re-render
    if @_inDocument
      @exitDocument()
      @removeSubviews()
      @$el.empty()

    # At first rendering, create and set root element
    unless @_rendered
      @_ensureElement()
      @renderOnce()
      @_rendered = true

    # If set template as function
    template = @getTemplateFunction()
    if template and _.isFunction(template)
      html = template.call(
        template,
        @getTemplateData()
      )

      @$el.append $(html)

    @renderEvery()

    if opt_parentElement
      unless _.isElement(opt_parentElement)
        throw Error('NoElementError', 'Element can not be found')
      if opt_afterElement
        opt_parentElement.insertBefore @el, opt_afterElement.nextSibling
      else
        opt_parentElement.insertBefore @el, opt_beforeElement or null
    else if !@_rendered
      document.body.appendChild @el

    if !@_parent or @_parent.isInDocument()
      @enterDocument()


  # 初回render時のみ行う処理
  #
  # @protected
  renderOnce: ->
    # Please override me


  # render時に毎回行う処理
  #
  # @protected
  renderEvery: ->
    # Please override me


  # @param {?Object} data .
  # @return {?Function} .
  # @protected
  getTemplateFunction: (data) ->
    return null


  # @return {Object} .
  # @protected
  getTemplateData: ->
    {}


  # 既存のDOMにビューをアタッチする
  #
  # @param {Element|string} element .
  decorate: (element) ->
    if @_inDocument
      @exitDocument()
      @removeSubviews()

    # At first decoration, set as root element
    unless @_decorated
      unless element
        throw Error('InvalidArgumentsError', 'element must be required')
      if _.isString(element)
        element = $(element).get(0)
      @decorateInternal(element)
      @decorateOnce()

    @decorateEvery()

    if !@_parent or @_parent.isInDocument()
      @enterDocument()

    @_decorated = true unless @_decorated


  # @param {Element} element .
  # @protected
  decorateInternal: (element) ->
    @el = element
    @$el = $(element)


  # 初回decorate時のみ行う処理
  #
  # @protected
  decorateOnce: ->
    # Please override me


  # decorate時に毎回行う処理
  #
  # @protected
  decorateEvery: ->
    # Please override me


  # DOMツリーに追加後に行う処理
  #
  # @protected
  enterDocument: ->
    @_inDocument = true

    @forEachSubviews (view, index) ->
      view.enterDocument() unless view.isInDocument()


  # DOMツリーから外した後に行う処理
  #
  # @protected
  exitDocument: ->
    @forEachSubviews (view, index) ->
      view.exitDocument() if view.isInDocument()

    # unbind all referenced handlers.
    @stopListening()
    # unbind all DOM events.
    @_eventHandler.unlistenAll() if @_eventHandler

    @_inDocument = false


  # @return {boolean} .
  isInDocument: ->
    return @_inDocument


  # @param {alpha.mvc.View} view .
  # @param {string=} opt_selector .
  addSubview: (view, opt_selector) ->
    @addSubviewAt view, @getSubviewCount(), opt_selector


  # @param {alpha.mvc.View} view .
  # @param {number} index .
  # @param {string=} opt_selector .
  addSubviewAt: (view, index, opt_selector) ->
    view.setParent @

    @_subviewMap[view.cid] = view
    Array.prototype.splice.apply @_subviews, [index, 0, view]

    if view.isInDocument() and @isInDocument()
      contentElement = @getContentElement(opt_selector)
      contentElement.insertBefore view.el, (contentElement.children[index] or null)
    else
      # Create and set root element
      unless @_rendered
        @_rendered = true
        @_ensureElement()
        @renderOnce()
      sibling = @getSubviewAt(index + 1)
      view._render @getContentElement(opt_selector), (sibling?.el or null)


  # @return {number} .
  getSubviewCount: ->
    return if @_subviews then @_subviews.length else 0


  # @return {Array.<alpha.mvc.View>} .
  getSubviews: ->
    return @_subviews or []


  # @param {string} cid .
  # @return {?alpha.mvc.View} .
  getSubview: (cid) ->
    return @_subviewMap[cid] or null


  # @param {number} index .
  # @return {?alpha.mvc.View} .
  getSubviewAt: (index) ->
    return if @_subviews then @_subviews[index] or null else null


  # @param {string} cid .
  # @return {number} .
  getSubviewIndex: (cid) ->
    res = -1
    for idx, view of @_subviews
      if view.cid is cid
        res = idx
        break
    return parseInt(res, 10)


  # @param {alpha.mvc.View} view .
  removeSubview: (view) ->
    index = _.indexOf(@_subviews, view)
    @removeSubviewAt index


  # @param {number} index .
  removeSubviewAt: (index) ->
    view = @getSubviewAt(index)

    if view
      delete @_subviewMap[view.cid]
      @_subviews.splice(index, 1)

      # 親からlistenToしたイベントは消さないと残る
      @stopListening view

      view.remove()
    else
      throw Error('SubviewNotFoundError')


  # Remove all subviews.
  removeSubviews: ->
    while @hasSubviews()
      @removeSubviewAt 0
    @_subviews = []


  # @return {boolean} .
  hasSubviews: ->
    return if @_subviews then @_subviews.length > 0 else false


  #
  forEachSubviews: (fn, opt_context) ->
    unless @hasSubviews()
      return

    _.each @_subviews, (view, index) ->
      fn.apply @, [view, index]
    , opt_context or @


  # @param {alpha.mvc.View} parent .
  setParent: (parent) ->
    @_parent = parent


  # Remove root element and dispose.
  remove: ->
    @dispose()


  # dispose時にmodelとcollectionをdisposeするか
  #
  # @param {boolean} keep .
  keepModelAndCollection: (keep = true) ->
    @_keepModelAndCollection = keep


  # @protected
  disposeInternal: ->
    return


  # Prevent memory leaks.
  # Calls {@code exitDocument}, which is expected to
  # remove event handlers and clean up the component.
  dispose: ->
    @exitDocument() if @_inDocument

    # remove all event handlers on this module.
    @off()

    # dispose of the subviews, if any.
    @forEachSubviews (view, index) ->
      view.keepModelAndCollection @_keepModelAndCollection
      view.dispose()

    # custom disposing.
    @disposeInternal()

    # detach the rendered element from the DOM.
    if @_rendered and @el?
      @$el.remove()

    #
    unless @_keepModelAndCollection
      @model?.dispose()
      @collection?.dispose()

    # delete properties.
    for prop in @viewOptions
      delete @[prop] if @[prop]

    delete @$el if @$el
    delete @options if @options
    delete @_subviews
    delete @_parent


  #########################################################
  #
  # Backbone.View properties and methods
  #
  #########################################################

  #
  tagName: 'div'

  #
  delegateEventSplitter: /^(\S+)\s*(.*)$/

  #
  viewOptions: [
    'model', 'collection', 'el', 'id', 'attributes', 'className', 'tagName', 'events'
  ]

  $: (selector) ->
    return @$el.find(selector)

  #
  setElement: (element, delegate) ->
    @undelegateEvents() if @$el
    @el = if element instanceof Backbone.$ then element.get(0) else element
    @$el = if element instanceof Backbone.$ then element else Backbone.$(element)
    if delegate isnt false
      @delegateEvents()
    return @

  #
  delegateEvents: (events) ->
    unless (events or (events = _.result(@, 'events')))
      return

    @undelegateEvents()

    for key, method of events
      method = @[events[key]] unless _.isFunction(method)
      unless method
        throw new Error('Method "' + events[key] + '" does not exist')

      match = key.match(@delegateEventSplitter)
      eventName = match[1]
      selector = match[2]
      method = _.bind(method, @)
      eventName += '.delegateEvents' + @cid
      if selector is ''
        @$el.on eventName, method
      else
        @$el.on eventName, selector, method

  #
  undelegateEvents: ->
    @$el.off '.delegateEvents' + @cid

  #
  _configure: (options) ->
    if @options
      options = _.extend({}, _.result(@, 'options'), options)
    _.extend @, _.pick(options, @viewOptions)
    @options = options

  #
  _ensureElement: ->
    unless @el
      attrs = _.extend({}, _.result(@, 'attributes'))
      attrs['id'] = _.result(@, 'id') if @id
      attrs['class'] = _.result(@, 'className') if @className
      $el = Backbone.$('<' + _.result(@, 'tagName') + '>').attr(attrs)
      @setElement $el, false
    else
      @setElement (if Backbone.$.isFunction(@el) then @el.call(@) else @el), false

