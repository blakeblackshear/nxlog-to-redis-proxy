express = require 'express'
redis = require 'redis'
fs = require 'fs'
app = express()

options =
  key: fs.readFileSync('/etc/nginx/ssl/logs.nextgxdx.com.key')
  cert: fs.readFileSync('/etc/nginx/ssl/logs.nextgxdx.com.cert')

client = redis.createClient()

rawBody = (req, res, next) ->
  req.setEncoding('utf8')
  req.rawBody = ''

  req.on 'data', (chunk) ->
    req.rawBody += chunk

  req.on 'end', ->
    next()

app.configure ->
  app.use rawBody
  app.use app.router

app.post '/', (req, res) ->
  client.rpush 'logstash', req.rawBody
  res.send(200)

server = require('https').createServer(options, app)
server.listen(3000)