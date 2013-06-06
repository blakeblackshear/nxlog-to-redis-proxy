express = require 'express'
redis = require 'redis'
fs = require 'fs'
https = require 'https'
httpProxy = require 'http-proxy'

# app to receive events
app = express()

options =
  key: fs.readFileSync('/opt/log-proxy/ssl/logs.nextgxdx.com.key')
  cert: fs.readFileSync('/opt/log-proxy/ssl/logs.nextgxdx.com.crt')

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

# Proxy for elasticsearch
server = https.createServer(options, app)
server.listen(443)

proxy_options =
  https: options

httpProxy.createServer(9200, 'localhost', proxy_options).listen(8080)