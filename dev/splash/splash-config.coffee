module.exports = {

  log: (string)->
    if console
      console.log(string)

  transferDir: (conn, remotePath, localPath, compression, cb)->
    tar = require("tar-fs")
    zlib = require("zlib")

    cmd = "tar cf - \"" + localPath + "\" 2>/dev/null"
    if typeof compression is "function"
      cb = compression
    else compression = 6  if compression is true
    if typeof compression is "number" and compression >= 1 and compression <= 9
      cmd += " | gzip -" + compression + "c 2>/dev/null"
    else
      compression = `undefined`
    conn.exec cmd, (err, stream) ->
      return cb(err)  if err
      exitErr = undefined
      tarStream = tar.extract(remotePath)
      tarStream.on "finish", ->
        cb exitErr
        return

      stream.on("exit", (code, signal) ->
        if typeof code is "number" and code isnt 0
          exitErr = new Error("Remote process exited with code " + code)
        else exitErr = new Error("Remote process killed with signal " + signal)  if signal
        return
      ).stderr.resume()
      stream = stream.pipe(zlib.createGunzip())  if compression
      stream.pipe tarStream
      return

    return
}

# USAGE ===============================================================
#ssh = require("ssh2")
#conn = new ssh()
## uses compression with default level of 6
#conn.on("ready", ->
#  transferDir conn, "/home/foo", __dirname + "/download", true, (err) ->
#    throw err  if err
#    console.log "Done transferring"
#    conn.end()
#    return
#
#  return
#).connect
#  host: "192.168.100.10"
#  port: 22
#  username: "foo"
#  password: "bar"

