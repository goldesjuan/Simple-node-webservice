// Generated by CoffeeScript 1.9.2
(function() {
  var express, router;

  express = require('express');

  router = express.Router();


  /*
   * GET userlist.
   */

  router.get('/userlist', function(req, res) {
    var db;
    db = req.db;
    return db.collection('userlist').find().toArray(function(err, items) {
      return res.json(items);
    });
  });


  /*
   * POST to adduser.
   */

  router.post('/adduser', function(req, res) {
    var db;
    db = req.db;
    return db.collection('userlist').insert(req.body, function(err, result) {
      return res.send(err === null ? {
        msg: ''
      } : {
        msg: err
      });
    });
  });


  /*
   * DELETE to deleteuser.
   */

  router["delete"]('/deleteuser/:id', function(req, res) {
    var db, userToDelete;
    db = req.db;
    userToDelete = req.params.id;
    return db.collection('userlist').removeById(userToDelete, function(err, result) {
      return res.send(result === 1 ? {
        msg: ''
      } : {
        msg: 'error' + err
      });
    });
  });

  module.exports = router;

}).call(this);