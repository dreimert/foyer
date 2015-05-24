angular.module "ardoise.controllers"
.controller "LoggedRfUserCtrl", ($scope, $http) ->
  $scope.$watch 'search', (value) ->
    if not value? or value.length <= 2
      $scope.results = []
    else
      $http.get '/api/user', params: {search: value}
      .success (data) ->
        $scope.results = data
