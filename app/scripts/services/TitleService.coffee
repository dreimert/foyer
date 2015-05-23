angular.module "ardoise.services"
.factory "TitleService", () ->
  new class TitleService
    constructor: () ->
      @title = "Accueil"
    setTitle: (title, backButton = false) ->
      @title = title
      @backButton = backButton
    showBackButton: () ->
      @backButton
    getTitle: () ->
      @title
