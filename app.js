var express = require('express');
var readdirp = require('readdirp');

var app = express();
app.set('views', __dirname + '/public/app');
app.set('view engine', 'pug');

/*
Set bower and app directories for static retrieval.
JS files from app will use this path, not pug files becaue those need to be rendered
*/
app.use('/static/common', express.static(__dirname + '/public/common'));
app.use('/static/framework', express.static(__dirname + '/public/app/framework'));

/*
Scan through the app directory to dynamically add js files to html file
*/
var frameworkFiles = [];
var dashboardFiles = [];

//Framework js files
readdirp({ root: __dirname + '/public/app/framework/', fileFilter: '*.pug' })
  .on('data', function (entry) {
    frameworkFiles.push('/app-render/framework/' + entry.path);
  });

/*
Some routing...may put this in another file later
*/
app.get(['/','/crouton','/crouton/*'], function (req, res) {
  var returnObj = {};
  returnObj.title = "Crouton";
  returnObj.css = [
    '/static/common/bower/font-awesome/css/font-awesome.min.css',
    '/static/common/css/toast.css',
    // '/static/common/css/style.css',
    '/static/common/css/tmpl.css',
    '/static/common/bower/chartist/dist/chartist.min.css'
  ];
  returnObj.jsExternal = [
    '/static/common/js/browserMqtt.js',
    '/static/common/bower/webcomponentsjs/webcomponents-lite.js',
    '/static/common/bower/packery/dist/packery.pkgd.min.js',
    '/static/common/bower/draggabilly/dist/draggabilly.pkgd.min.js',
    '/static/common/bower/jquery/dist/jquery.min.js',
    '/static/common/bower/chartist/dist/chartist.min.js'
  ];
  returnObj.frameworkFiles = frameworkFiles;
  res.render('index',returnObj);
});
//intercept templating for css files in framework
app.get('/app-render/framework/**/*.css', function (req, res) {
  res.sendFile(__dirname + "/public/app/framework/"+req.params[0]+"/"+req.params[2]+".css");
});
app.get('/app-render/dashboard-elements/**/*.css', function (req, res) {
  res.sendFile(__dirname + "/public/app/dashboard-elements/"+req.params[0]+"/"+req.params[2]+".css");
});
//templating angular html (pug) files
app.get('/app-render/framework/**/*.pug', function (req, res) {
  res.render("framework/"+req.params[0]+"/"+req.params[2]+".pug");
});
app.get('/app-render/dashboard-elements/**/*.pug', function (req, res) {
  res.render("dashboard-elements/"+req.params[0]+"/"+req.params[2]+".pug");
});
//For documentation
app.get('/app-render/documentation/*.css', function (req, res) {
  res.sendFile(__dirname + "/public/app/documentation/"+req.params[0]+".css");
});
app.get('/app-render/documentation/*.js', function (req, res) {
  res.sendFile(__dirname + "/public/app/documentation/"+req.params[0]+".js");
});
app.get('/app-render/documentation/*.md', function (req, res) {
  res.sendFile(__dirname + "/public/app/documentation/"+req.params[0]+".md");
});
app.get(['/documentation'], function (req, res) {
  res.render('documentation/documentation.pug');
});
//404
app.use(function(req, res, next) {
  res.redirect('/crouton/404');
});

/*
Start the app
*/
var port = process.env.PORT || 8080;
var server = app.listen(port, function () {
  var host = process.env.VCAP_APP_HOST || 'localhost';
  console.log('Crouton started at http://%s:%s', host, port);
});
