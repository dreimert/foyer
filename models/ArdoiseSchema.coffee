'use strict'

mongoose = require 'mongoose'
Schema = mongoose.Schema

ArdoiseSchema = new Schema
  montant: Number
  lastNegatif:
    type: Date
    default: Date.now
  archive: Boolean

module.exports = ArdoiseSchema
