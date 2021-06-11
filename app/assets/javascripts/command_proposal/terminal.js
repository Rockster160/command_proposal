docReady(function() {
  var terminal = document.querySelector(".terminal")
  var term_input = document.querySelector(".terminal .input")
  var lines = document.querySelector(".terminal .lines")
  var queue = Promise.resolve()

  terminal.addEventListener("click", function(evt) {
    term_input.focus()
  })

  terminal.addEventListener("keydown", function(evt) {
    if (evt.key == "Enter" && !event.shiftKey) {
      evt.preventDefault()

      submitTerminalCode()

      return false
    }
  })

  function submitTerminalCode() {
    var line = document.createElement("div")
    line.classList.add("line")
    line.textContent = term_input.textContent

    term_input.textContent = ""
    lines.appendChild(line)

    runTerminalCode(line)
  }

  function runTerminalCode(line) {
    queue = queue.then(async function() {
      $.rails.refreshCSRFTokens()

      var code = line.textContent
      var res = await fetch(terminal.dataset.exeUrl, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "X-CSRF-Token": $.rails.csrfToken()
        },
        body: JSON.stringify({ code: code, task_id: terminal.dataset.task })
      })

      var json = await res.json()

      var result = document.createElement("div")
      result.classList.add("result")
      result.textContent = json.result

      line.appendChild(result)
    })
  }
})





// eventTarget.addEventListener("keydown", event => {
//   if (event.isComposing || event.keyCode === 229) {
//     return;
//   }
//   // do something
// });
