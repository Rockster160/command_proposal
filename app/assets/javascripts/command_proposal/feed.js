docReady(function() {
  var terminals = document.querySelectorAll(".cmd-terminal")
  var queue = Promise.resolve()

  terminals.forEach(function(terminal) {
    if (terminal.dataset.status == "started") {
      pingFeed(terminal)
    }
  })

  function pingFeed(terminal) {
    queue = queue.then(async function() {
      $.rails.refreshCSRFTokens()

      var res = await fetch(terminal.dataset.feed, {
        method: "GET",
        headers: {
          "Content-Type": "text/html",
          "X-CSRF-Token": $.rails.csrfToken()
        },
      }).then(function(res) {
        if (res.ok) {
          return res.json()
        } else {
          throw new Error("Server error")
        }
      }).catch(function(err) {
        return {
          error: err,
        }
      })

      var json = await res

      terminal.innerHTML = json.html
      document.querySelector("td[data-iteration-status]").innerText = json.status
      document.querySelector("td[data-iteration-duration]").innerText = json.duration

      if (json.status == "started") {
        setTimeout(function() { pingFeed(terminal) }, 1000)
      }
    })
  }
})
