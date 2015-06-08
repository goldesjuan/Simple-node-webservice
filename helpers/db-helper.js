// Generated by CoffeeScript 1.9.2

/*
 * Database helper class
 */

(function() {
  var DbHelper, async, mongo, util;

  async = require('async');

  util = require('util');

  mongo = require('mongoskin');

  DbHelper = (function() {
    function DbHelper(databaseUrl) {
      this.db = mongo.db(databaseUrl, {
        native_parser: true
      });
    }

    DbHelper.prototype.getCollection = function(collectionName, callback) {
      this.db.collection(collectionName).find().toArray(function(error, result) {
        if (error != null) {
          console.log("Error finding items of collection " + collectionName + " : " + (util.inspect(error)));
          return callback(error);
        }
        return callback(null, result);
      });
    };

    DbHelper.prototype.insertUser = function(user, finalCallback) {
      var checkDuplicates, collection, createUser;
      collection = this.db.collection('userlist');
      async.waterfall([
        checkDuplicates = function(callback) {
          collection.findOne({
            'username': user.username
          }, function(error, object) {
            if (error != null) {
              return callback(error);
            }
            if (object != null) {
              return callback(null, true);
            }
            return callback(null, false);
          });
        }, createUser = function(alreadyExists, callback) {
          if (alreadyExists) {
            return callback(null, 'Ok');
          }
          collection.insert(user, function(error, result) {
            if (error != null) {
              return callback(error);
            } else {
              return callback(null, 'Ok');
            }
          });
        }
      ], function(error, result) {
        if (error != null) {
          return finalCallback("Error inserting user to collection : " + (util.inspect(error)));
        }
        return finalCallback(null, result);
      });
    };

    DbHelper.prototype.deleteUser = function(userId, callback) {
      this.db.collection('userlist').removeById(userId, function(error, result) {
        if (error != null) {
          return callback(error);
        } else {
          return callback(null, 'Ok');
        }
      });
    };

    return DbHelper;

  })();

  module.exports = DbHelper;

}).call(this);
