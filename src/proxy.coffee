express = require 'express'
redis = require 'redis'
app = express()
client = redis.createClient()

app.configure ->
  app.use express.bodyParser()
  app.use app.router

app.post '/', (req, res) ->
  client.rpush 'logstash', JSON.stringify(req.body)
  res.send req.body

app.listen(3000);