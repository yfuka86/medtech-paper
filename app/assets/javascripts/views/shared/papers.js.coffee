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

      star = ->
        $star.removeClass('fa-star-o')
        $star.addClass('fa-star')
        $el.find('.summary').addClass('favorited')
        _.each $el.find('.popularity'), (popularity)->
          num = parseInt($.trim($(popularity).text()) || 0, 10)
          $(popularity).text(num + 1)

      unstar = ->
        $star.removeClass('fa-star')
        $star.addClass('fa-star-o')
        $el.find('.summary').removeClass('favorited')
        _.each $el.find('.popularity'), (popularity)->
          num = parseInt($.trim($(popularity).text()) || 0, 10)
          $(popularity).text(num - 1 || '')

      if $star.hasClass('fa-star')
        unstar()
        defer = alpha.async.ajax
          type: 'DELETE'
          url: '/api/p/paper_lists/remove_paper'
          data:
            id: $star.data('favorite-list-id')
            pubmed_id: $el.data('pubmed-id')
        defer.done (data, status, xhr) ->
          return
        defer.fail (data, xhr, err) =>
          star()
          views.components.addNormalMessage data.message, {}, 'error'

      else if $star.hasClass('fa-star-o')
        star()
        defer = alpha.async.ajax
          type: 'PUT'
          url: '/api/p/paper_lists/add_paper'
          data:
            id: $star.data('favorite-list-id')
            pubmed_id: $el.data('pubmed-id')
        defer.done (data, status, xhr) ->
          return
        defer.fail (data, xhr, err) =>
          unstar()
          views.components.addNormalMessage data.message, {}, 'error'

  setSummaryCss: ->
    _.each @$('.paper'), (el)=>
      $el = $(el)
      $summary = $el.find('.summary')
      abstract_width = $summary.outerWidth() - $summary.find('.favorite').outerWidth() - $summary.find('.popularity').outerWidth() - $summary.find('.title').outerWidth() - $summary.find('.authors').outerWidth()
      $summary.find('.abstract').outerWidth(abstract_width - 30)
