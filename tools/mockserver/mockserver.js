/**
 * Install nodejs using https://github.com/creationix/nvm then run
 * $ node mockserver.js
 */

var http = require('http');
var url = require('url');

var port = 8000;

var server = http.createServer(function (request, response) {
    "use strict";

    var parsed,
        time;

    console.log('request for URL: ' + request.url);

    parsed = url.parse(request.url, true);

    if (parsed.pathname === '/echo') {
        response.writeHead(200, {"Content-Type": "text/plain"});
        response.end(parsed.query.d + "\n");
        return;
    }

    if (parsed.pathname === '/sleep') {
        time = parsed.query.t;
        response.writeHead(200, {"Content-Type": "text/plain"});
        //response.write('will sleep for ' + parsed.query.t + '\n');
        setTimeout(function () {
            response.end('finished sleeping\n');
        }, time);
        return;
    }

    if (parsed.pathname === '/timeout') {
        return;
    }

    if (parsed.pathname === '/slow') {
        response.writeHead(200, {"Content-Type": "text/plain"});
        response.write('slow...\n');
        var send = function () {
            response.write('slow...\n');
            setTimeout(send, 1*1000);
        };
        setTimeout(send, 1*1000);
        return;
    }


    response.write("USAGE:\n");
    response.write("  /echo?d=DATA\n");
    response.write("  /sleep?t=TIME\n");
    response.write("  /timeout\n");
    response.write("  /slow\n");
    response.end();
});

server.listen(port, '::');

console.log("Mock server running on port " + port);

