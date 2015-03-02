'use strict'

mongoose = require 'mongoose'
Schema = mongoose.Schema

TransfertSchema = new Schema
  debiteur:
    type: Schema.Types.ObjectId
    required: true
    ref: 'User'
  crediteur:
    type: Schema.Types.ObjectId
    required: true
    ref: 'User'
  montant:
    type: Number
    required: true
  date:
    type: Date
    required: true
    default: Date.now

module.exports = TransfertSchema
