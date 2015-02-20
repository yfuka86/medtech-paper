alpha.export 'alpha.lib.Modal'

class alpha.lib.Modal
  backgroundCSS =
    position:        'fixed'
    top:             0
    left:            0
    width:           '100%'
    height:          '100%'
    backgroundColor: '#000'
    opacity:         0.3


  windowCSS =
    padding:   '0'
    width:     'auto'
    height:    'auto'
    maxWidth:  'none'
    maxHeight: 'none'

  defaults =
    zIndex: 9999
    backgroundCSS: backgroundCSS
    windowCSS: windowCSS
    hideOnEscape: true
    hideOnBackgroundClick: true
    showOnBuild: true

  getContentSize = (e)->
    elm = $(e)
    children = elm.children()
    maxWidth  = elm.outerWidth()
    maxHeight = elm.outerHeight()
    for child in children
      contentSize = getContentSize(child)
      maxWidth  = Math.max(maxWidth, contentSize.width)
      maxHeight = Math.max(maxHeight,contentSize.height)
    return {
      width:  maxWidth
      height: maxHeight
    }

  isString = (s)->
    return (typeof s is "string") or (s instanceof String)

  el: null
  window: null
  back: null
  config: null
  firstSentry: null
  lastSentry: null
  outer: null

  constructor: (element,options)->
    _.extend @, Backbone.Events
    @el = $(element)
    @initConfig options
    @build()

  build: ()->
    @createBackground()
    @createWindow()
    a = $('<a>').attr('href','#').css
      opacity: 0
      position: 'absolute'
    @firstSentry = a.clone().prependTo(@back).addClass('firstSentry')
    @lastSentry  = a.clone().appendTo(@back).addClass('lastSentry')
    @window.append @el
    @trigger 'build'
    if @config.showOnBuild
      @show()
    else
      @back.hide()


  createBackground: ->
    @back = $('<div>').appendTo($(window.document.body))
    dummy = $('<div>').addClass('.modally-background-dummy').css backgroundCSS
    @back.append(dummy)

    @back.css
      zIndex: @config.zIndex
      position: 'absolute'
      top: 0
      left: 0
      width: '100%'
    @back.addClass('modally-background')
    @back.on 'click', @handleBackgroundClick

  createWindow: ->
    @outer = $('<div>').appendTo(@back).addClass('modally-outer').css
      position: "absolute"
      left: "50%"
    @window = $('<div>').appendTo(@outer).addClass('modally-window')
    @window.css windowCSS
    @window.on 'click',(e)-> e.stopPropagation()


  adjust: (verticalPosition = false)->
    @window.css
      width: 'auto'
      height: 'auto'
      maxWidth: 'none'
      maxHeight: 'none'
    size = getContentSize(@el)
    win = $(window)
    ww = win.width()
    wh = win.height()
    ew = size.width
    eh = size.height
    h = Math.min(wh, eh)
    w = Math.min(ww, ew)

    @window.css
      marginLeft:   "#{-w / 2}px"
      width:        "#{w}px"
    if verticalPosition
      @window.css
        marginTop:    "#{-h / 2}px"
      @outer.css
        top: $(window).scrollTop() + $(window).outerHeight() / 2
    @back.css 'height', wh

  handleBackgroundClick: (e)=>
    if @config.hideOnBackgroundClick
      @hide()

  handleKeyup: (e)=>
    if @config.hideOnEscape and e.keyCode is 27 # Esc key
      @hide()

  initConfig: (c)->
    c = {} unless c
    @config = $.extend defaults,c

  handleResize: ()=>
    @adjust(true)

  handleScroll: ()=>
    @adjust()

  focusables: ()=>
    @el.find('input:enabled, select:enabled, textarea:enabled, button:enabled, object:enabled, a[href], *[tabindex]')

  handleFocus: (e)=>
    if @el.has(e.target).length is 0
      e.preventDefault()
      $(document).off 'focusin', @handleFocus
      elms = @focusables()
      if elms.length is 0
        @el.children().first().focus()
      else if $(e.target).is @lastSentry
        elms.first().focus()
      else
        elms.last().focus()
      $(document).on 'focusin', @handleFocus

  attachEvents: ()->
    $(window).on 'resize', @handleResize
    $(window).on 'scroll', @handleScroll
    $(window).on 'keyup', @handleKeyup
    $(document).on 'focusin', @handleFocus

  dettachEvents: ()->
    $(window).off 'resize', @handleResize
    $(window).off 'scroll', @handleScroll
    $(window).off 'keyup', @handleKeyup
    $(document).off 'focusin', @handleFocus

  hide: ()->
    @back.hide(300)
    @dettachEvents()
    @trigger 'hide'

  show: ()->
    @back.show(300)
    @adjust(true)
    elms = @focusables()
    if elms.length is 0
      @el.children().first().focus()
    else
      elms.first().focus()
    @attachEvents()
    @trigger 'show'

  remove: ()->
    @dettachEvents()
    @back.remove()
    @back = null
    @window = null
    @outer = null
    @firstSentry = null
    @lastSentry = null
    @el = null
