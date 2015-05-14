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
    $(window).resize @menuToggle
    @listen $el.find('.menu-toggle'), 'click', @menuToggle

  menuToggle: ->
    $el = $('.sidebar')
    $responsive = $el.find('.responsive')
    if $responsive.css('display') is 'none' or $(window).width() > 720
      $el.find('.responsive').css('display', 'block')
    else
      $el.find('.responsive').css('display', 'none')

