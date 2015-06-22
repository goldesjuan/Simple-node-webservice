express = require 'express'
path = require 'path'
favicon = require 'serve-favicon'
logger = require 'morgan'
cookieParser = require 'cookie-parser'
bodyParser = require 'body-parser'
routes = require './routes/index'
Users = require './services/users'
Emails = require './facades/emails'
Sms = require './facades/sms'
#Notifications = require './services/notifications'
Database = require './facades/database'

app = express()
database = new Database 'mongodb://localhost:27017/nodetest2'
users = new Users database
#notifications = new Notifications database
emails = new Emails database
sms = new Sms database

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
app.delete '/users/:id', users.delete
app.post '/postemail', emails.postEmail
app.post '/postsms', sms.postSms

app.use '/', routes

module.exports = app
