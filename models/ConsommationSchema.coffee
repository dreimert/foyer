'use strict'

mongoose = require 'mongoose'
Schema = mongoose.Schema

ConsommationSchema = new Schema
  consommable: String
  quantity: Number
  montant: Number
  lieu: String
  ardoise:
    type: Schema.Types.ObjectId
    ref: "Ardoise"
  date:
    type: Date
    default: Date.now

module.exports = ConsommationSchema
