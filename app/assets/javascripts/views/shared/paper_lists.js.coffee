alpha.export 'views.shared.PaperLists'

# @constructor
# @extends {alpha.mvc.View}
class views.shared.PaperLists extends alpha.mvc.View

  # @override
  enterDocument: ->
    super()
    @bindPaperListsEvent()

  bindPaperListsEvent: ->
    _.each @$('.single-paper-list'), (el)=>
      $el = $(el)

      @listen $el,　'click', =>
        paperListId = $el.data('id')
        location.href = "#{location.origin}/paper_lists/#{paperListId}"
