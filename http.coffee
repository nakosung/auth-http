express = require 'express'
session = require 'express-session'
cookieParser = require 'cookie-parser'
everyauth = require 'everyauth'
mongojs = require 'mongojs'
path = require 'path'

conf = 
	COOKIE_MAX_AGE : parseInt(process.env.COOKIE_MAX_AGE or 7 * 24 * 3600)
	COOKIE_SECRET : process.env.COOKIE_SECRET or 'cookie_super_secret'
	SESSION_MONGO_HOST : process.env.MONGO_IP
	SESSION_MONGO_DB : process.env.SESSION_DB or 'websession'
	USERS_MONGO_DB : [process.env.MONGO_IP, process.env.USER_DB or 'auth'].join('/')
	GITHUB :
		APP_ID : process.env.GITHUB_APPID
		APP_SECRET : process.env.GITHUB_SECRET

db = mongojs conf.USERS_MONGO_DB, ['users']

app = express()
app.use cookieParser(conf.COOKIE_SECRET)

MongoStore = (require 'connect-mongo') session
app.use session
	secret : conf.SESSION_SECRET
	cookie : maxAge : conf.COOKIE_MAX_AGE
	store : new MongoStore 
		host:conf.SESSION_MONGO_HOST
		db:conf.SESSION_MONGO_DB

everyauth.everymodule
    .findUserById (id, next) ->
    	db.users.findOne _id:id, (err,doc) ->
    		return next err if err
    		return next 404 unless doc?

if conf.GITHUB?
	github_fn = (sess, accessToken, accessTokenExtra, ghUser) ->
		promise = @Promise()

		db.users.findOne "github.id":ghUser.id, (err,doc) ->
			if doc?
				doc.id = doc._id
				promise.fulfill doc
			else
				user = {}
				user.github = ghUser

				db.users.save user, (err,doc) ->
					if doc?
						doc.id = doc._id
						# winston.info "************".bold.red, promise
						promise.fulfill doc
					else
						promise.reject()

		promise

	everyauth.github
		.appId(conf.GITHUB.APP_ID)
		.appSecret(conf.GITHUB.APP_SECRET)
		.findOrCreateUser(github_fn)
		.redirectPath('/')    

app.use everyauth.middleware()
app.set 'view engine', 'jade'
app.set 'views', path.join __dirname, 'views'
  
app.get '/', (req,res) ->
	res.render 'home'

app.get '/ping', (req,res) ->
	res.send 'OK'

app.listen 3000