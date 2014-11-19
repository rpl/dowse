var union = require('union');
var director = require('director');
var ecstatic = require('ecstatic');
var path = require('path');

/* base http service */

var router = new director.http.Router({
  '/events': { get: require("./http-server-sent-events") }
});

function directorDispatcher(req, res) {
  var found = router.dispatch(req, res);
  if (!found) {
    res.emit('next');
  }
}

var staticAssets = ecstatic({
    handleError: true,
    root: path.join(__dirname, 'webui-assets')
});

var server = union.createServer({
  before: [
    directorDispatcher,
    staticAssets
  ]
});

module.exports = server;
