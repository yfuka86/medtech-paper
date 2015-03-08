alpha.export 'views.paper_lists.PaperList'

# @constructor
# @extends {alpha.mvc.View}
class views.paper_lists.PaperList extends alpha.mvc.View

  # @override
  enterDocument: ->
    super()
    @listen @$('.toggle-userlist'), 'click', @toggleUserlist

  toggleUserlist: (e)->
    e.preventDefault()
    @$('.userlist').toggle()

