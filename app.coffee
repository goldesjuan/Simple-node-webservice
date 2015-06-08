express = require 'express'
path = require 'path'
favicon = require 'serve-favicon'
logger = require 'morgan'
cookieParser = require 'cookie-parser'
bodyParser = require 'body-parser'
routes = require './routes/index'
Users = require './services/users'
email = require './routes/email'
DbHelper = require './helpers/db-helper'

app = express()
database = new DbHelper 'mongodb://localhost:27017/nodetest2'
users = new Users database

#view engine setup
app.set 'views', path.join(__dirname, 'views')
app.set 'view engine', 'jade'

app.use logger('dev')
app.use bodyParser.json()
app.use bodyParser.urlencoded({ extended: false })
app.use cookieParser()
app.use express.static(path.join(__dirname, 'public'))

app.get '/userlist', users.list
app.post '/adduser', users.postUser
app.delete '/deleteuser/:id', deleteUser

app.use '/', routes
#app.use '/users', users
app.use '/email', email

module.exports = app
