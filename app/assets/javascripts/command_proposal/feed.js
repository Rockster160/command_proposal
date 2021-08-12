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
        console.log("err:", err);
        return {
          error: err,
        }
      })

      var json = await res

      terminal.nextElementSibling.CodeMirror.doc.setValue(json.result || "")
      document.querySelector("td[data-iteration-status]").innerText = json.status
      document.querySelector("td[data-iteration-duration]").innerText = json.duration

      if (json.status == "started" || json.status == "stop") {
        setTimeout(function() { pingFeed(terminal) }, 1000)
      } else {
        document.querySelector(".stop-btn").remove()
      }
    })
  }
})
