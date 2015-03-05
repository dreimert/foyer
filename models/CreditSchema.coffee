'use strict'

mongoose = require 'mongoose'
Schema = mongoose.Schema

CreditSchema = new Schema
  user:
    type: Schema.Types.ObjectId
    required: true
    ref: 'User'
  montant:
    type: Number
    required: true
  mode:
    type: String
    required: true
  date:
    type: Date
    default: Date.now

module.exports = CreditSchema
