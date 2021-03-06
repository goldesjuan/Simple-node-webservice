// Generated by CoffeeScript 1.9.2
(function() {
  var Users, async, express, util,
    bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  express = require('express');

  async = require('async');

  util = require('util');

  Users = (function() {
    function Users(database) {
      this["delete"] = bind(this["delete"], this);
      this.postUser = bind(this.postUser, this);
      this.list = bind(this.list, this);
      this.database = database;
    }

    Users.prototype.list = function(req, res) {
      return this.database.getCollection('userlist', function(error, result) {
        if (error != null) {
          console.log("" + (util.inspect(error)));
          return res.status(500).send('Error finding users');
        } else {
          return res.json(result);
        }
      });
    };

    Users.prototype.postUser = function(req, res) {
      return this.database.insertUser(req.body, function(error, result) {
        if (error != null) {
          console.log("Error inserting object in collection userlist : " + (util.inspect(error)));
          return res.status(500).send({
            error: 'Error inserting user'
          });
        } else {
          return res.status(200).send({
            status: 200
          });
        }
      });
    };

    Users.prototype["delete"] = function(req, res) {
      var userId;
      userId = req.params.id;
      return this.database.deleteUser(userId, function(error, result) {
        if (error != null) {
          console.log("Error deleting user : " + (util.inspect(error)));
          return res.status(500).send('Error deleting user');
        } else {
          return res.status(200).send('Ok');
        }
      });
    };

    return Users;

  })();

  module.exports = Users;

}).call(this);
