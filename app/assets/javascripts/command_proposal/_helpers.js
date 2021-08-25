function cmdDocReady(fn) {
  // see if DOM is already available
  if (document.readyState === "complete" || document.readyState === "interactive") {
    // call on next available tick
    setTimeout(fn, 1)
  } else {
    document.addEventListener("DOMContentLoaded", fn)
  }
}

function HttpClient() {
  this.request = function(method, url, opts) {
    var req = new XMLHttpRequest()
    req.onreadystatechange = function() {
      if (req.status != 0 && req.readyState == 4 && opts.done) {
        opts.done(req.responseText, req.status, req)
      }
    }

    req.open(method, url, true)
    if (opts.headers) {
      Object.keys(opts.headers).forEach(function(key) {
        req.setRequestHeader(key, opts.headers[key])
      })
    }
    req.send(opts.body)
  }

  this.get = function(url, opts) {
    this.request("GET", url, opts)
  }

  this.post = function(url, opts) {
    this.request("POST", url, opts)
  }
}

function CommandQueue() {
  this.queue = []
  this.eventCurrentlyRunning = false
  this.runningQueue = null

  this.run = function() {
    if (!this.eventCurrentlyRunning) {
      if (this.queue.length == 0) {
        clearInterval(this.runningQueue)
        this.runningQueue = null
        return
      }
      var nextEvent = this.queue.shift()
      this.eventCurrentlyRunning = true
      nextEvent(this)
    }
  }

  this.add = function(queued_function) {
    this.queue.push(queued_function)
    this.process()
  }

  this.finish = function(ms) {
    this.eventCurrentlyRunning = false
  }

  this.process = function() {
    if (this.runningQueue) { return }
    var q = this
    this.runningQueue = setInterval(function() { q.run() }, 1)
  }
}
