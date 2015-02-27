alpha.export 'views.components.NotificationBalloon'

class views.components.NotificationBalloon extends alpha.mvc.View
  @instances: {}

  # @override
  initialize: (options)->
    @$target = @options.target
    @message = @options.message
    return if !@$target or !@message
    # mode ['error']
    # position ['top', 'right', 'left', 'buttom']
    @className = "#{@options.mode}-#{@options.position}-balloon"
    @isFixed = @options.isFixed

    unless @$target.data(@className)?
      unless @isFixed
        @listen @$target, 'mouseover', _.bind(@show, @)
        @listen @$target, 'mouseleave', _.bind(@hide, @)
        @listen @$target, 'focus', _.bind(@show, @)
        @listen @$target, 'blur', _.bind(@hide, @)
        $(window).on 'resize', _.bind(@adjustPosition, @)

      key = _.uniqueId('balloon')
      @$target.data('balloon', key)
      views.components.NotificationBalloon.instances[key] = @

  # @override
  getTemplateFunction: ->
    JST['components/notification_balloon']

  # @override
  getTemplateData:->
    return message: @message

  # @override
  enterDocument: ->
    super()
    @show() if @isFixed

  #
  show: ->
    @adjustPosition()
    @$el.show()

  #
  hide: ->
    @$el?.hide() unless @$target.is(":focus")

  #
  adjustPosition: ->
    switch @options.position
      when 'top'
        left = @$target.position().left
        top = @$target.position().top - @$el.height() - 20
      when 'right'
        left = @$target.position().left + @$target.outerWidth() + 8
        top = @$target.position().top + (@$target.outerHeight() - @$el.outerHeight())/2
      when 'bottom'
        left = @$target.position().left
        top = @$target.position().top + @$target.outerHeight() + 8
      when 'left'
        left = @$target.position().left - @$el.outerWidth() - 8
        top = @$target.position().top + (@$target.outerHeight() - @$el.outerHeight())/2

    if @$target.is(':visible')
      @$el.show()
    else
      @$el.hide()

    @$el.css(
      left: left + "px"
      top: top + "px"
    )

  #
  remove: ->
    obj = views.components.NotificationBalloon.instances
    _.each obj, (v, k) =>
      if v is @
        delete obj[k]
        @dispose()

views.components.addErrorBalloon = ($elm, msg, opts={}) ->
  balloonView = new views.components.NotificationBalloon(
    message: msg
    target: $elm
    mode: 'error'
    position: opts.position or 'top'
    isFixed: opts.isFixed or false
  )
  balloonView.render $elm.parent()
  return balloonView

views.components.removeBalloon = ($elm) ->
  key = $elm.data('balloon')
  if key?
    views.components.NotificationBalloon.instances[key]?.dispose()
    delete views.components.NotificationBalloon.instances[key]

views.components.adjustAllBalloons = ->
  _.each views.components.NotificationBalloon.instances, (instance, key) ->
    instance.adjustPosition()

views.components.removeAllBalloons = ->
  _.each views.components.NotificationBalloon.instances, (instance, key) ->
    instance.dispose()
  views.components.NotificationBalloon.instances = {}


