# Simple-node-webservice
This is a simple web service that uses a Node.js server and is coded in CoffeeScript.
It consists of a small userlist with people's emails and phone numbers and it allows to perform basic CRUD operations on the user list as well as sending emails and text messages to them.

The service has a MongoDB database used for storing users, emails and text messages. Each of the previous with separate collections: 'userlist', 'emails' and 'sms' respectively.

##Idempotence
An idempotent operation is one that has no additional effect if it is called more than once with the same input parameters

This service implements idempotent operations for posting users to the database and posting emails and text messages to their respective APIs. By doing this we ensure that, when posting a new user we do not have duplicates and when posting emails or text messages, if by any reason the request is sent multiple times to the service that handles them, the emials or messages get sent only once to the respective APIs
##Mailgun API
[Mailgun](http://www.mailgun.com/) is a powerful email API that allows you to send, receive, and track email in your websites and apps.

This service uses Mailgun to send automated emails.
* Requires a Mailgun account and credentials (credentials should be replaced in the Notifications class)

##Twilio API
[Twilio](https://www.twilio.com/) allows software developers to programmatically make and receive phone calls and send and receive text messages using its web service APIs.

This service uses Twilio to send automated text messages.
* Requires a Twilio account and credentials (credentials should be replaced in the Notifications class)
