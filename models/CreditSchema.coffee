'use strict'

mongoose = require 'mongoose'
Schema = mongoose.Schema

CreditSchema = new Schema
  ardoise:
    type: Schema.Types.ObjectId
    required: true
    ref: 'Ardoise'
  montant:
    type: Number
    required: true
  mode:
    type: String
    required: true
  date:
    type: Date
    required: true
    default: Date.now

module.exports = CreditSchema
