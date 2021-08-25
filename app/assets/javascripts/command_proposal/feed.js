cmdDocReady(function() {
  var terminals = document.querySelectorAll("[data-feed]")
  var queue = new CommandQueue
  var continue_statuses = ["started", "approved", "cancelling"]

  terminals.forEach(function(terminal) {
    if (continue_statuses.includes(terminal.dataset.status)) {
      pingFeed(terminal)
    }
  })

  function pingFeed(terminal) {
    queue.add(function(evt) {
      $.rails.refreshCSRFTokens()

      var client = new HttpClient()
      client.get(terminal.dataset.feed, {
        headers: {
          "Content-Type": "text/html",
          "X-CSRF-Token": $.rails.csrfToken()
        },
        done: function(res, status, req) {
          if (status == 200) {
            var json = JSON.parse(res)
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
          } else {
            console.log("Error: ", res, req);
          }
          evt.finish()
        }
      })
    })
  }
})
