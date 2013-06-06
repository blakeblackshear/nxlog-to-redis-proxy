express = require 'express'
redis = require 'redis'
fs = require 'fs'
app = express()

options =
  key: fs.readFileSync('./ssl/logs.nextgxdx.com.key')
  cert: fs.readFileSync('./ssl/logs.nextgxdx.com.crt')

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

app.post '/:queue', (req, res) ->
  client.rpush req.params.queue, req.rawBody
  res.send(200)

server = require('https').createServer(options, app)
server.listen(443)