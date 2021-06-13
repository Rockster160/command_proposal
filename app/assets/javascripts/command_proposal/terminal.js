docReady(function() {
  var terminal = document.querySelector(".console")
  var term_input = document.querySelector(".console .input")
  var lines = document.querySelector(".console .lines")
  var queue = Promise.resolve()
  var prev_cmd_idx = undefined, prev_entry = ""
  var caret = document.querySelector(".caret")

  term_input.addEventListener("blur", stopCaretFlash)
  term_input.addEventListener("focus", function() {
    startCaretFlash()
    moveCaretToFocus()
  })
  term_input.addEventListener("keydown", moveCaretToFocus)
  term_input.addEventListener("keyup", moveCaretToFocus)
  term_input.addEventListener("mousedown", moveCaretToFocus)

  terminal.addEventListener("click", function(evt) {
    if (!window.getSelection().toString().length) {
      term_input.focus()
    }
  })

  terminal.addEventListener("keydown", function(evt) {
    // console.log(evt.key)
    if (evt.key == "Enter" && !event.shiftKey) {
      evt.preventDefault()

      submitTerminalCode()

      return false
    }
    if (evt.key == "ArrowUp") {
      console.log(getCaretIndex(terminal));
      if (getCaretIndex(terminal) == 0) {
        var commands = getPrevCommands()

        if (!prev_cmd_idx) {
          prev_cmd_idx = commands.length - 1
          prev_entry = term_input.textContent
        }

        prev_cmd_idx -= 1
        console.log("prev_cmd_idx", prev_cmd_idx)
        console.log("commands[prev_cmd_idx]", commands[prev_cmd_idx])
        term_input.textContent = commands[prev_cmd_idx]
        // change focus to end of line
      }
      // if start of line
        //
      // CMD + up -> Jump to top of line? or jump to first idx?
      // OPT, CMD, Shift -> What do they do?
      // cancel scroll unless cursor is at the beginning or end of line? Or only beginning?
    }
    // if (evt.key == "ArrowDown") {
    //
    // }
  })

  function stopCaretFlash() {
    caret.classList.remove("flash")
  }

  function startCaretFlash() {
    caret.classList.add("flash")
  }

  function moveCaretToFocus() {
    setTimeout(function() {
      caret.classList.remove("hidden")
      caret.classList.remove("flash")
      void caret.offsetWidth
      caret.classList.add("flash")
      var coords = getCaretCoordinates()
      var offset = getOffset(terminal)
      var left = coords.x - offset.left
      var top = coords.y - offset.top
      if (coords.x == 0 && coords.y == 0) {
        left = offset.left
        top = offset.top
      }

      caret.style.left = left + "px"
      caret.style.top = top + "px"
    }, 1)
  }
  moveCaretToFocus()

  function getCaretCoordinates() {
    var x = 0, y = 0
    if (window.getSelection) {
      var selection = window.getSelection()
      if (selection.rangeCount !== 0) {
        var range = selection.getRangeAt(0).cloneRange()
        range.collapse(true)
        var rect = range.getClientRects()[0]
        if (rect) {
          x = rect.left
          y = rect.top
        } else {
          var offset = getOffset(range.startContainer)
          x = offset.left
          y = offset.top
        }
      }
    }

    return { x, y }
  }

  function getCaretIndex(element) {
    var position = 0
    if (window.getSelection) {
      var selection = window.getSelection()
      if (selection.rangeCount !== 0) {
        var range = window.getSelection().getRangeAt(0)
        var preCaretRange = range.cloneRange()
        preCaretRange.selectNodeContents(element)
        preCaretRange.setEnd(range.endContainer, range.endOffset)
        position = preCaretRange.toString().length
      }
    }

    return position
  }

  function getOffset(el) {
    const rect = el.getBoundingClientRect()
    return {
      left: rect.left,
      top: rect.top
    }
  }

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
//     return
//   }
//   // do something
// })
