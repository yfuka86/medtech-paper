alpha.export 'views.shared.Papers'

# @constructor
# @extends {alpha.mvc.View}
class views.shared.Papers extends alpha.mvc.View

  # @override
  enterDocument: ->
    super()
    @bindPapersEvent()
    @setSummaryCss()
    $(window).resize @setSummaryCss

  bindPapersEvent: ->
    _.each @$('.paper'), (el) =>
      $el = $(el)
      $summary = $el.find('.summary')
      $detail = $el.find('.detail')
      @listen $el.find('i.fa-star'), 'click',
      @listen $el.find('i.fa-star-o'), 'click',

      @listen $el.find('.summary'), 'click', =>
        _.each @$('.paper'), (el) =>
          $el = $(el)
          $el.find('.summary').show()
          @setSummaryCss()
          $el.find('.detail').hide()
        $summary.hide()
        $detail.show()
      @listen $(el).find('.close-bar'), 'click', =>
        $summary.show()
        @setSummaryCss()
        $detail.hide()


  setSummaryCss: ->
    _.each @$('.paper'), (el) =>
      $el = $(el)
      $summary = $el.find('.summary')
      abstract_width = $summary.outerWidth() - $summary.find('.favorite').outerWidth() - $summary.find('.popularity').outerWidth() - $summary.find('.title').outerWidth() - $summary.find('.authors').outerWidth()
      $summary.find('.abstract').outerWidth(abstract_width - 30)
