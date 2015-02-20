alpha.export 'views.components.Modal'

 # @extends alpha.mvc.VueView
class views.components.ModalView extends alpha.mvc.VueView

  # render()
  # showModal()
  # @trigger 'trigger-hide'

  hideOnEscape: true
  hideOnBackgroundClick: true
  _modal: null

  constructor: (options)->
    super arguments...
    @on 'trigger-show', _.bind(@showModal, @)
    @on 'trigger-hide', _.bind(@hideModal, @)

  disposeInternal: ->
    if @_modal
      @_modal.remove()
      @_modal = null

  handleShow: ()->
    @trigger 'show', @

  handleHide: ()->
    @trigger 'hide', @

  adjust: (verticalPosition = false)->
    @_modal.adjust(verticalPosition)

  buildModal: ()->
    return if @_modal
    @_modal = new alpha.lib.Modal @el,
      showOnBuild: false
      hideOnEscape: @hideOnEscape
      hideOnBackgroundClick: @hideOnBackgroundClick
    @listenTo @_modal, 'show', _.bind(@handleShow, @)
    @listenTo @_modal, 'hide', _.bind(@handleHide, @)

  showModal: ()->
    @buildModal()
    @_modal.show()

  hideModal: ()->
    @_modal.hide()
