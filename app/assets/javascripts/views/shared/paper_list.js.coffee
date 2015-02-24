alpha.export 'views.shared.PaperList'

# @constructor
# @extends {alpha.mvc.View}
class views.shared.PaperList extends alpha.mvc.View

  # @override
  enterDocument: ->
    super()
    _.each @$('.paper'), (el) =>
      @listen $(el).find('.summary'), 'click', =>
        $(el).find('.summary').hide()
        $(el).find('.detail').show()
      @listen $(el).find('.close-bar'), 'click', =>
        $(el).find('.summary').show()
        $(el).find('.detail').hide()


