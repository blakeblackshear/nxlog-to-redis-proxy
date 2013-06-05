express = require 'express'
redis = require 'redis'
app = express()
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

app.listen(3000);