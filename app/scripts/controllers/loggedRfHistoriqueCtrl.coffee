angular.module "ardoise.controllers"
.controller "LoggedRfHistoriqueCtrl", (
  $scope,
  $q,
  $http,
  historique,
  total
) ->
  $scope.logs = historique
  $scope.total = total

  console.log $scope.logs

  $scope.selected = []

  $scope.label =
    text: "Lignes par page"
    of: "sur"

  $scope.query =
    filter: '',
    order: '-date',
    limit: 10,
    page: 1

  success = (logs) ->
    $scope.logs = logs

  getHistorique = (page, limit) ->
    $q (resolve, reject) ->
      skip = limit * page - limit

      $http.get "api/historique?limit=#{limit}&skip=#{skip}"
      .success (data) ->
        success data
        resolve data
      .error (data) ->
        reject data

  $scope.onOrderChange = (order) ->
    console.log "onOrderChange", order
    getHistorique($scope.query.page, $scope.query.limit)

  $scope.onPaginationChange = (page, limit) ->
    console.log "onPaginationChange", page, limit
    getHistorique(page, limit)
