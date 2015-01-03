module.exports =
  derequire:
      src: './build/video.js'
      dest: './build/video.js'
      replacements: [
        {
          from: /require\(/g
          to: "__derequire__("
        }
        {
          from: /function\(require/g
          to: "function(__derequire__"
        }
      ]
