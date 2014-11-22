"use strict"

# Filters 
angular.module("aae.filters", []).filter( "interpolate", [
  "version"
  (version) ->
    return (text) ->
      String(text).replace /\%VERSION\%/g, version
]).filter( 'reverse', ->
  (items) ->
    items.slice().reverse()
)
