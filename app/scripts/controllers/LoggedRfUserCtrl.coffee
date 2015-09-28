angular.module "ardoise.controllers"
.controller "LoggedRfUserCtrl", ($scope, $http) ->
  $scope.$watch 'search', (value) ->
    $scope.results = []
    if not value? or value.length <= 2
      $http.get '/api/user'
      .success (data) ->
        $scope.results = data
    else
      $http.get '/api/user', params: {search: value}
      .success (data) ->
        $scope.results = data
