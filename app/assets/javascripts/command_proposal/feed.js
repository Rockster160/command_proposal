docReady(function() {
  var terminals = document.querySelectorAll("[data-feed]")
  var queue = Promise.resolve()
  var continue_statuses = ["started", "approved", "cancelling"]

  terminals.forEach(function(terminal) {
    if (continue_statuses.includes(terminal.dataset.status)) {
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
      })

      var json = await res

      if (terminal.nextElementSibling && terminal.nextElementSibling.CodeMirror) {
        terminal.nextElementSibling.CodeMirror.doc.setValue(json.result || "")
      } else {
        terminal.innerHTML = json.result_html
      }
      document.querySelector("td[data-iteration-status]").innerText = json.status
      document.querySelector("td[data-iteration-duration]").innerText = json.duration

      if (continue_statuses.includes(json.status)) {
        setTimeout(function() { pingFeed(terminal) }, 1000)
      } else {
        if (document.querySelector(".cancel-btn")) {
          document.querySelector(".cancel-btn").remove()
        }
      }
    })
  }
})
