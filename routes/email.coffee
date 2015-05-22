express = require('express')
router = express.Router()
api_key = '{API KEY}'
domain = '{DOMAIN}'
mailgun = require('mailgun-js')(
  apiKey: api_key
  domain: domain)

router.post '/sendemail', (req, res) ->
  req.body.from = '{FROM}'
  mailgun.messages().send req.body, (error, body) ->
    res.send if body.message then msg: body.message else error
    console.log body
    return
  return

module.exports = router
