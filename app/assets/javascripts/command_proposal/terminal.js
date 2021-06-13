docReady(function() {
  var terminal = document.querySelector(".console")
  var term_input = document.querySelector(".console .input")
  var lines = document.querySelector(".console .lines")
  var queue = Promise.resolve()
  var prev_cmd_idx = undefined, prev_entry = ""

  terminal.addEventListener("click", function(evt) {
    if (!window.getSelection().toString().length) {
      term_input.focus()
    }
  })

  terminal.addEventListener("keydown", function(evt) {
    // console.log(evt.key);
    if (evt.key == "Enter" && !event.shiftKey) {
      evt.preventDefault()

      submitTerminalCode()

      return false
    }
    if (evt.key == "ArrowUp") {
      // CMD + up -> Jump to top of line? or jump to first idx?
      // OPT, CMD, Shift -> What do they do?
      // cancel scroll unless cursor is at the beginning or end of line? Or only beginning?
      var commands = getPrevCommands()

      if (!prev_cmd_idx) {
        prev_cmd_idx = commands.length
        prev_entry = term_input.textContent
      }

      prev_cmd_idx -= 1
      console.log("prev_cmd_idx", prev_cmd_idx);
      console.log("commands[prev_cmd_idx]", commands[prev_cmd_idx]);
      term_input.textContent = commands[prev_cmd_idx]
    }
    // if (evt.key == "ArrowDown") {
    //
    // }
  })

  function getPrevCommands() {
    return Array.prototype.map.call(document.querySelectorAll(".line"), function(line) {
      var text_node = Array.prototype.find.call(line.childNodes, function(node) {
        return node.nodeName == "#text"
      })

      return text_node ? text_node.textContent : ""
    })
  }

  function submitTerminalCode() {
    var line = document.createElement("div")
    line.classList.add("line")
    line.textContent = term_input.textContent

    term_input.textContent = ""
    lines.appendChild(line)

    runTerminalCode(line)
  }

  function runTerminalCode(line) {
    if (/^[\s\n]*$/m.test(line.textContent)) { return }

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
