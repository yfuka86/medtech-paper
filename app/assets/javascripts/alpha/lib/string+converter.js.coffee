String::camelize = ->
  @replace /(-|_)\w/g, (match) -> return match[1].toUpperCase()

String::snakenize = ->
  if @match(/[a-z][A-Z]/)
    @replace /[a-z][A-Z]/g, (match) -> return match[0] + '_' + match[1].toLowerCase()
  else
    @replace /-\w/g, (match) -> return '_' + match[1].toLowerCase()

String::dashnize = ->
  if @match(/[a-z][A-Z]/)
    @replace /[a-z][A-Z]/g, (match) -> return match[0] + '-' + match[1].toLowerCase()
  else
    @replace /_\w/g, (match) -> return '-' + match[1].toLowerCase()