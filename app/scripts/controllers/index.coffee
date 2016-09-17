angular = require 'angular'

angular.module "ardoise.controllers", []

require './AnonymeAccueilCtrl'
require './AnonymeCtrl'
require './AnonymePaiementCtrl'
require './LoggedAccueilCtrl'
require './LoggedAuthCtrl'
require './LoggedConsommationCtrl'
require './LoggedCtrl'
require './LoggedDeconnexionCtrl'
require './LoggedRfAccueilCtrl'
require './LoggedRfBarCtrl'
require './loggedRfConsommationCtrl'
require './LoggedRfCreateUserCtrl'
require './loggedRfFrigoCtrl'
require './LoggedRfHistoriqueCtrl'
require './LoggedRfLogCtrl'
require './LoggedRfRemplirCtrl'
require './LoggedRfUserCtrl'
require './LoggedRfUserDetailCtrl'
require './LoginCtrl'

module.exports = "ardoise.controllers"
