require('../../bower_components/angular/angular.js')
require('../../bower_components/angular-route/angular-route.js')
require('../../bower_components/angular-sanitize/angular-sanitize.js')
require('../../bower_components/angular-animate/angular-animate.js')
require('../../bower_components/angular-cookies/angular-cookies.js')
require('../../bower_components/fhir.js/dist/ngFhir.js')
l7 = require('../../vendor/L7/index.js')

require('file?name=index.html!../index.html')
require('file?name=fhir.json!../fhir.json')
require('../less/app.less')

app = require('./module')

require('./views')
require('./data')

sitemap = require('./sitemap')

log = require('./logger')

app.config ($routeProvider) ->
  rp = $routeProvider
    .when '/',
      templateUrl: '/views/index.html'
      controller: 'WelcomeCtrl'

  mkRoute = (acc, x)->
    acc.when("/#{x.name}", x)

  rp = sitemap.main.reduce mkRoute, rp

  rp.otherwise
    templateUrl: '/views/404.html'

app.controller "WelcomeCtrl", ($scope) ->
  $scope.hl7 = "MSH+@~\\&+REG@REG@+XYZ+GOBLET+ZYX+20050912110538+SI&U+SIU@S12+4676115+P+2.3\nPID+++353966++SMITH@JOHN@@@@++19820707+F++C+108 MAIN STREET @@ANYTOWN@TX@77777@@+HARV+(512)555-0170+++++00362103+123-45-6789++++++++++++"

  $scope.$watch 'hl7', (newVal, oldVal) ->
    $scope.parsed = l7.parse(newVal)
