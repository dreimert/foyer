'use strict'

mongoose = require 'mongoose'
Schema = mongoose.Schema

ConsommableSchema = new Schema
  nom:
    type: String
    required: true
  prix:
    type: Number
    required: true
  frigo:
    type: Number
    required: true
  commentaire: String

module.exports = ConsommableSchema
