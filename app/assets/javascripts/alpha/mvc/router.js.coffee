#
# @fileoverview Backbone.Router with handle url routing
#

alpha.export 'alpha.mvc.Router'

# @constructor
# @extends {Backbone.Router}
class alpha.mvc.Router extends Backbone.Router

  # @param {String} .
  # @return {Object} .
  parseQuery: (query) ->
    parsed = {}

    return parsed unless query

    if query[0] is '&' or query[0] is '#'
      query = query.slice(1, query.length)

    pairs = query.split('&')
    for pair in pairs
      p = pair.split('=')
      if p.length > 1
        parsed[p[0]] = p[1]

    return parsed

  # backbonerouterではdecodeURIComponentを通したparamsを返してくるが、不便なため変更。
  # きちんと手動でdecodeすること。
  # @override
  _extractParameters: (route, fragment) ->
    params = route.exec(fragment).slice(1);
    return _.map params, (param) ->
      return param || null
