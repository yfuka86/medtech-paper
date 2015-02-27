alpha.export 'views.shared.PaperList'

# @constructor
# @extends {alpha.mvc.View}
class views.shared.PaperList extends alpha.mvc.View

  # @override
  enterDocument: ->
    super()
    _.each @$('.paper'), (el) =>
      $el = $(el)
      $summary = $el.find('.summary')
      $detail = $el.find('.detail')
      @listen $el.find('.summary'), 'click', =>
        $summary.hide()
        $detail.show()
      @listen $(el).find('.close-bar'), 'click', =>
        $summary.show()
        @setSummaryCss()
        $detail.hide()
    @setSummaryCss()
    $(window).resize @setSummaryCss

  setSummaryCss: ->
    _.each @$('.paper'), (el) =>
      $el = $(el)
      $summary = $el.find('.summary')
      abstract_width = $summary.outerWidth() - $summary.find('.popularity').outerWidth() - $summary.find('.title').outerWidth() - $summary.find('.authors').outerWidth()
      $summary.find('.abstract').outerWidth(abstract_width - 30)

