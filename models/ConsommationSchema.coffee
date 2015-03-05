'use strict'

mongoose = require 'mongoose'
Schema = mongoose.Schema

ConsommationSchema = new Schema
  consommable:
    type: String
    required: true
  quantity:
    type: Number
    required: true
  montant:
    type: Number
    required: true
  lieu:
    type: String
    required: true
  user:
    type: Schema.Types.ObjectId
    ref: "User"
  date:
    type: Date
    default: Date.now
    required: true

module.exports = ConsommationSchema
