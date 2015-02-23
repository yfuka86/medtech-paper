alpha.export 'views.shared.PaperList'

# @constructor
# @extends {alpha.mvc.View}
class views.shared.PaperList extends alpha.mvc.View

  # @override
  enterDocument: ->
    super()
    _.each @$('.paper'), (el) =>
      @listen $(el), 'click', =>
        $(el).find('.summary').toggle()
        $(el).find('.detail').toggle()

