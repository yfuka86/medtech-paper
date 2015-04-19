alpha.export 'views.shared.MainView'

# @constructor
# @extends {alpha.mvc.View}
class views.shared.MainView extends alpha.mvc.View

  # @override
  enterDocument: ->
    super()
    @menuBinder()

  menuBinder: () ->
    $el = $('.sidebar')
    @listen $el.find('.menu-toggle'), 'click', ()->
      $responsive = $el.find('.responsive')
      if $responsive.css('display') is 'none'
        $el.find('.responsive').css('display', 'block')
      else
        $el.find('.responsive').css('display', 'none')

