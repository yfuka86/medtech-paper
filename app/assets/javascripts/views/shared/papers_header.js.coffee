alpha.export 'views.shared.PapersHeader'

# @constructor
# @extends {alpha.mvc.View}
class views.shared.PapersHeader extends alpha.mvc.View

  Classnames: ['favorite', 'popularity', 'title', 'published-date']

  # @override
  enterDocument: ->
    super()
    @reflectQuery()
    @bindSortEvent()

  bindSortEvent: ->
    _.each @Classnames, (str) =>
      $el = @$(".#{str}")
      @listen $el.find('.fa-chevron-up'), 'click', (e) =>
        query = "#{str}_asc"
        @sortPapers(query)
      @listen $el.find('.fa-chevron-down'), 'click', (e) =>
        query = "#{str}_desc"
        @sortPapers(query)

  sortPapers: (query)->
    if location.search.length is 0
      location.href = location.origin + location.pathname + '?sort=' + query
    else if regexpResult = location.href.match(/((?:\?|&)sort=(?:\w|-)+)(?:&|$)/)
      location.href = location.href.replace(regexpResult[1], regexpResult[1][0] + 'sort=' + query)
    else
      location.href = location.href + '&sort=' + query

  reflectQuery: ->
    if @options.sort and @options.sort.length > 0
      query = @options.sort.split('_')
      $el = @$(".#{query[0]}")
      if query[1] is 'asc'
        $el.find('.fa-chevron-up').addClass('active')
      else if query[1] is 'desc'
        $el.find('.fa-chevron-down').addClass('active')
