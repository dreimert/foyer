'use strict'

Crypto = require('crypto')

mongoose = require 'mongoose'
Schema = mongoose.Schema

UserSchema = new Schema
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
  mail:
    type: String
    required: true
  
  montant:
    type: Number
    default: 0
  lastNegatif:
    type: Date
    default: Date.now
  archive:
    type: Boolean
    default: false

  promo: Number
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
  Crypto.createHash('md5').update(plaintext).digest("hex")

UserSchema.methods.authenticate = (plaintext) ->
  @encryptPassword(plaintext) is @password

UserSchema.methods.authenticateWithRole = (roleName, plaintext) ->
  for role in @roles
    if role.name is roleName
      return (@encryptPassword(plaintext) is role.pass_hash)

  false

module.exports = UserSchema
