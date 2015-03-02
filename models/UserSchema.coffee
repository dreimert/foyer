'use strict'

Crypto = require('crypto')

mongoose = require 'mongoose'
Schema = mongoose.Schema

UserSchema = new Schema
  montant: Number
  lastNegatif:
    type: Date
    default: Date.now
  archive: Boolean

  login:
    type: String
    required: true
    unique: true
    index: true
  pass_hash :
    type : String
    required : true
  nom:
    type: String
    required: true
  prenom:
    type: String
    required: true
  ardoise:
    type: Schema.Types.ObjectId
    required: true
    index: unique: true
    ref: 'Ardoise'
  promo: Number
  mail: String
  trustMail: Boolean
  departement: String
  lastMail: Date
  roles: [
    name: String
    pass_hash: String
  ]

UserSchema.virtual('password').set (password) ->
  if password?
    @pass_hash = @encryptPassword(password)

UserSchema.virtual('password').get () ->
  @pass_hash

UserSchema.methods.encryptPassword = (plaintext) ->
  crypto.createHash('md5').update(plaintext).digest("hex")

UserSchema.methods.authenticate = (plaintext) ->
  @encryptPassword(plaintext) is @password

UserSchema.methods.authenticateWithRole = (roleName, plaintext) ->
  for role in @roles
    if role.name is roleName
      return @encryptPassword(plaintext) is @password

  false

module.exports = UserSchema
