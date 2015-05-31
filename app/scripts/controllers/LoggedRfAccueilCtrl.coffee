angular.module "ardoise.controllers"
.controller "LoggedRfAccueilCtrl", ($scope) ->
  menus = [
    icon: "css/icons/ic_person_add_24px.svg"
    title: "Créer un utilisateurs"
    state: "logged.rf.createUser"
  ,
    icon: "css/icons/ic_person_24px.svg"
    title: "Utilisateurs"
    state: "logged.rf.user"
  ,
    icon: "css/icons/ic_import_export_24px.svg"
    title: "Trasnfert"
    state: "logged.rf.trasnfert"
  ,
    icon: "css/icons/ic_local_drink_24px.svg"
    title: "Produits"
    state: "logged.rf.produits"
  ,
    icon: "css/icons/ic_toys_24px.svg"
    title: "Frigo"
    state: "logged.rf.frigo"
  ,
    icon: "css/icons/ic_list_24px.svg"
    title: "Consommations"
    state: "logged.rf.consommation"
  ,
    icon: "css/icons/ic_local_grocery_store_24px.svg"
    title: "Commandes"
    state: "logged.rf.commandes"
  ,
    icon: "css/icons/ic_local_bar_24px.svg"
    title: "Soirées"
    state: "logged.rf.soirees"
  ,
    icon: "css/icons/ic_supervisor_account_24px.svg"
    title: "Rôles"
    state: "logged.rf.roles"
  ,
    icon: "css/icons/ic_history_24px.svg"
    title: "Historique"
    state: "logged.rf.historique"
  ]

  build = (menus) ->
    for menu, index in menus
      menu.span =
        row : 1
        col : 1
      menu.background = switch index+1
        when 1 then  "red"
        when 2 then  "green"
        when 3 then  "darkBlue"
        when 4 then  "blue"
        when 5 then  "yellow"
        when 6 then  "pink"
        when 7 then  "darkBlue"
        when 8 then  "purple"
        when 9 then  "deepBlue"
        when 10 then "lightPurple"
        when 11 then "yellow"
    menus

  $scope.menus = build(menus)
