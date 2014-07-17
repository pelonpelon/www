(function() {
  module.exports = {
    log: function(string) {
      if (console) {
        return console.log(string);
      }
    },
    transferDir: function(conn, remotePath, localPath, compression, cb) {
      var cmd, tar, zlib;
      tar = require("tar-fs");
      zlib = require("zlib");
      cmd = "tar cf - \"" + localPath + "\" 2>/dev/null";
      if (typeof compression === "function") {
        cb = compression;
      } else {
        if (compression === true) {
          compression = 6;
        }
      }
      if (typeof compression === "number" && compression >= 1 && compression <= 9) {
        cmd += " | gzip -" + compression + "c 2>/dev/null";
      } else {
        compression = undefined;
      }
      conn.exec(cmd, function(err, stream) {
        var exitErr, tarStream;
        if (err) {
          return cb(err);
        }
        exitErr = void 0;
        tarStream = tar.extract(remotePath);
        tarStream.on("finish", function() {
          cb(exitErr);
        });
        stream.on("exit", function(code, signal) {
          if (typeof code === "number" && code !== 0) {
            exitErr = new Error("Remote process exited with code " + code);
          } else {
            if (signal) {
              exitErr = new Error("Remote process killed with signal " + signal);
            }
          }
        }).stderr.resume();
        if (compression) {
          stream = stream.pipe(zlib.createGunzip());
        }
        stream.pipe(tarStream);
      });
    }
  };

}).call(this);
