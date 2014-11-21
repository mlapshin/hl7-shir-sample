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
  $scope.hl7 = "MSH|^~\\&|MS4ADT|001|UST|001|20061003174932||ADT^A01|00000000006108683|P|2.3\nEVN|A01|20061003174930|||ADTMLORENZ\nPID|1|000191989^^^MS4^PN^|33-31-50^^^MS4^MR^001|33-31-50^^^MS4^MR^001|BURNS^REBECCA^^^||19451228|F||T|UNK^^GLENDALE^CA^91208^^^|||||||00016166449^^^MS4001^AN^001\nPV1||E|||||31310^NIKBAKHT^FARSHEED^^^^MD^^^^^^^|||EMR||||||||E||0000|5||||||||||||||||||001|OCCPD||||200610031749\nGT1|1|000191989^^^MS4^PN^|BURNS^REBECCA^^^|^^^^|UNK^^GLENDALE^CA^91208^^|||19451228|F||A|||||||||||||||||||||||||||Y|||||||||||||||||T\nIN1|1||0401|MEDICARE I/P|^^^^     |||||||19990201|||MCR|ROSTAMIAN^LIDA^^^|A|19220104|9166 TUJUNGA CANYON^(OAKVIEW CONV)^TUJUNGA^CA^91042^^^^|||1||||||||||||||602487568M|||||||F|^^^^00000|Y||||010229619\nIN2||602487568|07496^RETIRED|||602487568M||||||||||||||||||||||||||||||Y|||OTH||||W|||RETIRED|||||||||||||||||(818)352-4426||||||||P\nIN1|2||0304|MEDI-CAL SECONDARY|P.O. BOX 15600^^SACRAMENTO^CA^95851-1600|||||||19940501|||MCD|ROSTAMIAN^LIDA^^^|A|19220104|9166 TUJUNGA CANYON^(OAKVIEW CONV)^TUJUNGA^CA^91042^^^^|||2||||||||||||||93202754A45061|||||||F|^^^^00000|N||||010229619\nIN2||602487568|07496^RETIRED|||||93202754A45061||||||||||||||||||||||||||||Y|||OTH||||W|||RETIRED|||||||||||||||||(818)352-4426||||||||P\n"

  buildEncounter = (hl7) ->
    classes =
      "E": "emergency"
      "I": "inpatient"
      "O": "outpatient"

    encounter =
      resourceType: "Encounter"
      text:
        status: "generated"
        div: "<p>Generated from HL7 message</p>"

      identifier: [
        use: "temp"
        label: "Auto-generated identifier"
        value: hl7.query("PID|2[0]")[0]
      ]

      status: "planned"

      class: classes[hl7.query("PV1|2")]

    patient =
      resourceType: "Patient"
      identifier: [
        use: "usual"
        label: "MRN"
        system: "urn:oid:1.2.36.146.595.217.0.1"
        value: hl7.query("PID|2[0]")[0]
      ]
      name: [
        use: "official"
        family: hl7.query("PID|5[0]")
        given: hl7.query("PID|5[1]")
      ]
      gender: [
        coding: [
          system: "http://hl7.org/fhir/v3/AdministrativeGender"
          code: hl7.query("PID|8")
        ]
      ]
      birthDate: hl7.query("PID|7").replace(/(\d\d\d\d)(\d\d)(\d\d)/, '$1-$2-$3')
      address: [
        use: "home"
        line: hl7.query("PID|11")
        city: hl7.query("PID|11[2]")[0]
        state: hl7.query("PID|11[3]")[0]
        zip: hl7.query("PID|11[4]")[0]
      ]

    [encounter, patient]


  $scope.$watch 'hl7', (newVal, oldVal) ->
    result = l7.parse(newVal)

    if result.errors.length == 0
      $scope.result = buildEncounter(result)
    else
      $scope.result = result.errors
