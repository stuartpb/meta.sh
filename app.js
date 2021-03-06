var express = require('express');
var uaIsBrowser = require('user-agent-is-browser');
var glob = require('glob');
var q = require('queue-async');
var fs = require('fs');
var marked = require('marked');
var hljs = require('highlight.js');

function highlight(code, lang) {
  // only highlight when lang is explicitly specified
  return lang ? hljs.highlight(lang, code).value : code;
}

function highlightScript(code, lang) {
  // highlight scripts "automatically" (which is to say, choose bash)
  return hljs.highlightAuto(code, ['bash']);
}

function markedHLJS(str) {
  return marked(str, {highlight: highlight});
}

module.exports = function appctor() {
  var app = express();

  function readFileOrNull(filename,cb) {
    var notfound = ['ENOENT', 'ENAMETOOLONG', 'ENOTDIR'];
    fs.readFile(filename, {encoding: 'utf8'}, function(err, data) {
      if (err) {
        if (~notfound.indexOf(err.code)) return cb(null, null);
        else return cb(err);
      }
      else return cb(null, data);
    });
  }

  var paths = Object.create(null);
  var scriptBase = __dirname + '/scripts/';
  var readmeBase = __dirname + '/readmes/';
  glob.sync(__dirname + '/scripts/**/*.sh').forEach(function (scriptName) {
    var name = scriptName.slice(scriptBase.length, -('.sh'.length));
    var readmeName = name == 'index' ? __dirname + '/README.md'
      : readmeBase + name + '.md';
    q().defer(readFileOrNull,scriptName).defer(readFileOrNull,readmeName)
      .await(function(err, script, readme) {
        var highlighted = highlightScript(script);
        var content = {script: {
          raw: script,
          html: highlighted.value,
          lang: highlighted.language
        }};
        if (readme) content.readme = {raw: readme, html: markedHLJS(readme)};
        paths[name] = content;
      });
  });

  function respondWithPage(req, res, name, opts) {
    opts = opts || {};
    opts.script = opts.script ||
      paths[name].script && paths[name].script.html;
    opts.lang = opts.lang ||
      paths[name].script && paths[name].script.lang;
    opts.readme = opts.readme ||
      paths[name].readme && paths[name].readme.html;
    opts.title = opts.title || 'meta.sh' +
      (name == 'index' ? '' : '/' + name);
    opts.host = opts.host || req.header('host');
    opts.name = opts.name || name;
    res.render(opts.template || 'script.jade', opts);
  }

  function respondWithScript(req, res, name) {
    // Send as text/plain rather than application/x-sh
    res.type('text/plain').send(paths[name].script.raw);
  }

  function switchResponse(req, res, name, template) {
    var qsbrowser = req.query.browser;
    var realua = req.header('user-agent');

    // Note that this response varies by UA, for caching
    res.header('Vary','User-Agent');

    if (qsbrowser || uaIsBrowser(realua)) {
      respondWithPage(req, res, name, {
        template: template,
        uasniffed: qsbrowser || realua
      });
    } else {
      respondWithScript(req, res, name);
    }
  }

  app.use(require('nowww')());

  app.use(express.static(__dirname + '/static'));

  app.get('/', function rootRoute(req, res) {
    switchResponse(req, res, 'index','index.jade');
  });
  app.get('/index.html', function rootRoutePage(req, res) {
    respondWithPage(req, res, 'index', {template: 'index.jade'});
  });
  app.get('/index.sh', function rootRouteSh(req, res) {
    respondWithScript(req, res, 'index');
  });
  app.get('/README.md', function rootRouteReadme(req, res, next) {
    res.type('text/plain').send(paths.index.readme.raw);
  });

  app.get('/:name(*)', function namedRoute(req, res, next) {
    if(paths[req.params.name])
      switchResponse(req, res, req.params.name);
    else next();
  });
  app.get('/:name(*).html', function namedRoutePage(req, res, next) {
    if(paths[req.params.name])
      respondWithPage(req, res, req.params.name);
    else next();
  });
  app.get('/:name(*).sh', function namedRouteSh(req, res, next) {
    if(paths[req.params.name])
      respondWithScript(req, res, req.params.name);
    else next();
  });
  app.get('/:name(*)/README.md', function namedRouteReadme(req, res, next) {
    if(paths[req.params.name] && paths[req.params.name].readme)
      res.type('text/plain').send(paths[req.params.name].readme.raw);
    else next();
  });

  app.use(function(req, res) {
    res.type('text/plain').send(404, 'echo "'
      + req.header('host') + req.url + ' not found"');
  });
  app.use(function(err, req, res, next) {
    res.type('text/plain')
      .send(500, 'echo -e ' + JSON.stringify(err.stack || err.toString()));
  });

  return app;
};
