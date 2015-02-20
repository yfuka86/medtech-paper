#
# @fileoverview XMLHttpRequest wrapper.
#
alpha.export 'alpha.async.ajax'


# Usage
#    defer = alpha.async.ajax
#      type: 'POST'
#      url: '/items'
#      target: $('form')
#    defer.done (data, status, xhr) ->
#      // success!
#    defer.fail (xhr, status, err) ->
#      // failure!
#    defer.always () ->
#      // either success or failure!
#
# @param {Object} options .
# @param {boolean} loading .
# @return {jQuery.Deferred} .
alpha.async.ajax = (options = {}, loading = true) ->
  unless options.url?
    throw new Error('URL must be required')
  ajaxOptions = _.extend(_.clone(alpha.async.ajax.defaultOptions), options)
  context = ajaxOptions.context ? null
  defer = $.Deferred()

  # 200
  ajaxOptions.success = (data, status, xhr) ->
    alpha.async.ajax._enable options.target if options.target
    _.bind(defer.resolve, context).apply(@, arguments)

  # 500 or 404 or 401
  ajaxOptions.error = (xhr, status, err) ->
    if xhr.status == 401
      alpha.async.ajax.sessionExpired?()

    data = $.parseJSON xhr.responseText

    alpha.async.ajax._enable options.target if options.target
    _.bind(defer.reject, context).apply(@, [data, xhr, err])

  alpha.async.ajax._disable options.target if options.target

  xhr = $.ajax ajaxOptions
  defer.xhr = xhr
  return defer


# @private
alpha.async.ajax._enable = (opt_element) ->
  if opt_element
    targets = opt_element.find('a', ':input[type=button]', ':input[type=submit]', ':button')
    targets.attr 'disabled', null
  $(document.body).spin(false)


# @private
alpha.async.ajax._disable = (opt_element) ->
  if opt_element
    targets = opt_element.find('a', ':input[type=button]', ':input[type=submit]', ':button')
    targets.attr 'disabled', 'disabled'
  $(document.body).spin()


# @type {Object}
alpha.async.ajax.defaultOptions =
  type: 'GET'
  dataType: 'json'
