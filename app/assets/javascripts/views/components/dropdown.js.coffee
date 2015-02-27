alpha.export 'views.components.DropdownAttacher'

class views.components.DropdownAttacher

  elements: null
  clicked: false
  mouseover: true
  hideFlag: false

  constructor: (options)->
    if options?.mouseover is false
      @mouseover = false

  attach: ($elm)->
    @elements = $elm
    $elm.find('.alpha-dropdown-toggle').on 'click', @handleToggleClick

    if @mouseover
      $elm.find('.alpha-dropdown-toggle').on 'mouseover', @handleMouseover
    @elements.on 'mouseenter', @handleMouseenter
    @elements.on 'mouseleave', @handleMouseleave
    $(document.body).on 'click', @handleOthersClick

    @hideAll()

  hideAll:()->
    @elements.find('.alpha-dropdown-menu').hide(200)

  handleToggleClick: (e)=>
    e.preventDefault()
    elm = $(e.delegateTarget).parents('.alpha-dropdown')

    if not @mouseover && elm.find('.alpha-dropdown-menu').is(':visible')
      @hideAll()
    else
      @toggle(elm)

  handleMouseover: (e)=>
    @toggle($(e.delegateTarget).parents('.alpha-dropdown'))

  handleMouseenter: (e)=>
    @hideFlag = false

  handleMouseleave: (e)=>
    return unless @mouseover
    @hideFlag = true
    setTimeout((=>
      @hideAll() if @hideFlag
      @hideFlag = false
    ), 500)

  handleOthersClick: (e)=>
    if @elements.find(e.target).length is 0
      @hideAll()

  toggle: (elm)->
    @hideAll()
    elm.find('.alpha-dropdown-menu').show(200)
    @adjustPosition(elm)

  adjustPosition: (elm)->
    menu = elm.find('.alpha-dropdown-menu')
    if elm.hasClass('right-justified')
      toggle = elm.find('.alpha-dropdown-toggle')
      menu.css
        left: toggle.outerWidth() - menu.outerWidth()

      offset = menu.offset()
      overflow = $(window).scrollLeft() - offset.left
      if overflow > 0
        current = parseInt menu.css('left'), 10
        menu.css 'left', current + overflow
    else
      menu.css
        left:  'auto'
        right: 'auto'
      offset = menu.offset()
      menuWidth = menu.outerWidth()
      windowWidth = $(window).outerWidth() + $(window).scrollLeft()
      rightPosition = offset.left + menuWidth

      if rightPosition > windowWidth
        menu.css 'left', windowWidth - rightPosition
      else
        menu.css 'left', '-20px'


class views.components.Dropdown extends alpha.mvc.VueView

  # @type {string}
  tagName: 'ul'

  # @type {string}
  className: 'alpha-dropdown-menu'

  # @type {Object}
  list: {}

  # @type {Object}
  functions: {}

  # @type {views.components.DropdownAttacher}
  dropdown: null

  # @override
  initialize: ->
    @list = @options.list
    _.each @list, (link, itemname) =>
      if _.isFunction link
        key = _.uniqueId()
        @functions[key] = link
        @list[itemname] = key
      else if !_.isString(link)
        delete @list[itemname]


  # @override
  getTemplateFunction: ->
    JST['components/dropdown']

  # @override
  elementBinding: ->
    return '.alpha-dropdown-menu'

  # @override
  dataBinding: ->
    return {
      list: @list
    }

  # @override
  methodsBinding: ->
    return {
      onClick: (e) =>
        uid = parseInt(e, 10)
        if _.isNumber(uid) and !_.isNaN(uid)
          @functions[uid]()
        else
          location.href = e
    }

  # @override
  enterDocument: ->
    super =>
      @dropdown = new views.components.DropdownAttacher(@options)
      @dropdown.attach(@$el.parent()) # this element must have alpha-dropdown class
      @$el.hide()

  # @override
  disposeInternal: ->
    @dropdown?.dispose()
    @dropdown = null

# argument $elm must have alpha-dropdown-toggle class
views.components.makeDropdown = ($elm, list, mouseover=false) ->
  dropdownView = new views.components.Dropdown({list: list, mouseover: mouseover})
  dropdownView.render $elm.parent()
  dropdownView
