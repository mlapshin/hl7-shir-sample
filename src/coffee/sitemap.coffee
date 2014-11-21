app = require('./module')

capitalize = (s)->
  s && s[0].toUpperCase() + s.slice(1)

buildSiteMap = (x)->
  x.href ||= "#/#{x.name}"
  x.templateUrl ||= "/views/#{x.name}.html"
  x.controller ||= "#{capitalize(x.name)}Ctrl"
  x

module.exports = {
  main: [
    {label:"Home", href: "#/"}
    {name: 'page1', label:"Page1"}
    {name: 'page2', label:"Page2"}
  ].map(buildSiteMap)
}
