alpha.export 'views.components.NotificationMessage'

class views.components.NotificationMessage extends alpha.mvc.View

  className: 'notification-message'

  @instances: []

  # @override
  initialize: ->
    # ['error']
    @mode = @options.mode
    @innerClassName = "#{@options.mode or 'normal'}-notification-message"
    @message = @options.message
    unless @options.parse is false
      message = $('<div/>').text(@message).html()
      @message = message?.replace(/\\n/g, "<br>");
    @timeout = @options.timeout
    @closeable = if !@options.timeout then true else @options.closeable

  # @override
  getTemplateFunction: ->
    JST['components/notification_message']

  # @override
  getTemplateData:->
    return {
      innerClassName: @innerClassName
      message: @message
      closeable: @closeable
    }

  # @override
  render: ->
    # if overlapping of messages is allowed, we can comment these lines out.
    views.components.NotificationMessage.instances[0]?.dispose()
    views.components.NotificationMessage.instances.shift()

    super '#notification-messages-container'

  # @override
  enterDocument: ->
    super()
    @listen @$('.close-btn'), 'click', _.bind(@hideMessage, @)

    @$(".#{@innerClassName}").animate {'margin-top': 0}, =>
      if @timeout
        setTimeout _.bind(@hideMessage, @), @timeout

  #
  hideMessage: ->
    @$(".#{@innerClassName}").animate {'margin-top': -70}, =>
      @dispose()

views.components.addNormalMessage = (msg, opts={}, mode=null)->
  messageView = new views.components.NotificationMessage
    mode: mode
    message: msg
    timeout: opts.timeout
    closeable: opts.closeable
    parse: opts.parse
  messageView.render()
  views.components.NotificationMessage.instances.push messageView

views.components.addErrorMessage = (msg, opts={})->
  views.components.addNormalMessage(msg, opts, 'error')

views.components.addSuccessMessage = (msg, opts={})->
  views.components.addNormalMessage(msg, opts, 'success')
