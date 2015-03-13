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
    _.each @$('.paper'), (el)=>
      $el = $(el)
      $summary = $el.find('.summary')
      $detail = $el.find('.detail')

      @listen $el.find('.summary'), 'click', =>
        _.each @$('.paper'), (el)=>
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

      @bindFavoriteEvent($el)

  bindFavoriteEvent: ($el)->
    # $elは@$('.paper')のうちの一つ
    $star = $el.find('.fa-star, .fa-star-o')
    @listen $star, 'click', (e) =>
      e.stopPropagation()
      if $star.hasClass('fa-star')
        defer = alpha.async.ajax
          type: 'DELETE'
          url: '/api/p/paper_lists/remove_paper'
          data:
            id: $star.data('favorite-list-id')
            paper_id: $el.data('paper-id')
        defer.done (data, status, xhr) ->
          $star.removeClass('fa-star')
          $star.addClass('fa-star-o')
          _.each $el.find('.popularity'), (popularity)->
            num = parseInt($.trim($(popularity).text()) || 0, 10)
            $(popularity).text(num - 1 || '')
        defer.fail (data, xhr, err) =>
          views.components.addNormalMessage data.message, {}, 'error'

      else if $star.hasClass('fa-star-o')
        defer = alpha.async.ajax
          type: 'PUT'
          url: '/api/p/paper_lists/add_paper'
          data:
            id: $star.data('favorite-list-id')
            pubmed_id: $el.data('pubmed-id')
        defer.done (data, status, xhr) ->
          $star.removeClass('fa-star-o')
          $star.addClass('fa-star')
          _.each $el.find('.popularity'), (popularity)->
            num = parseInt($.trim($(popularity).text()) || 0, 10)
            $(popularity).text(num + 1)
        defer.fail (data, xhr, err) =>
          views.components.addNormalMessage data.message, {}, 'error'

  setSummaryCss: ->
    _.each @$('.paper'), (el)=>
      $el = $(el)
      $summary = $el.find('.summary')
      abstract_width = $summary.outerWidth() - $summary.find('.favorite').outerWidth() - $summary.find('.popularity').outerWidth() - $summary.find('.title').outerWidth() - $summary.find('.authors').outerWidth()
      $summary.find('.abstract').outerWidth(abstract_width - 30)
