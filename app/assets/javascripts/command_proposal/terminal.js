docReady(function() {
  var terminal = document.querySelector(".console")
  var term_input = document.querySelector(".console .input")
  var lines = document.querySelector(".console .lines")
  var queue = Promise.resolve()
  var prev_cmd_idx = undefined, prev_entry = undefined
  var caret = document.querySelector(".caret")
  var commands = getPrevCommands()

  if (disable_block_caret) {
    caret.remove()
    terminal.style.caretColor = "lime"
  }

  term_input.addEventListener("blur", stopCaretFlash)
  term_input.addEventListener("focus", function() {
    startCaretFlash()
    placeBlockAtCaret()
  })
  term_input.addEventListener("keydown", placeBlockAtCaret)
  term_input.addEventListener("keyup", placeBlockAtCaret)
  term_input.addEventListener("mousedown", placeBlockAtCaret)

  terminal.addEventListener("click", function(evt) {
    if (!window.getSelection().toString().length) {
      term_input.focus()
    }
  })

  terminal.addEventListener("keydown", function(evt) {
    // console.log(evt.key)
    // evt.shiftKey
    // evt.ctrlKey
    // evt.altKey
    // evt.metaKey (windows key or CMD key)

    if (evt.key == "Enter" && !event.shiftKey) {
      evt.preventDefault()
      submitTerminalCode()
      return false
    }

    if (evt.ctrlKey && evt.key == "c") {
      prev_entry = term_input.textContent
      term_input.textContent = ""
    }

    if (evt.key == "ArrowUp" && getCaretIndex(term_input) == 0) {
      handleUpKey(evt)
    }
    if (evt.key == "ArrowDown" && getCaretIndex(term_input) == term_input.textContent.length) {
      handleDownKey()
    }
  })

  function handleUpKey() {
    if (!prev_cmd_idx) {
      if (prev_entry) {
        prev_cmd_idx = commands.length - 1
        term_input.textContent = prev_entry

        return
      }

      prev_cmd_idx = commands.length
      prev_entry = term_input.textContent
    }

    prev_cmd_idx -= 1
    term_input.textContent = commands[prev_cmd_idx]
  }

  function handleDownKey() {
    if (prev_cmd_idx) {
      var cmd = ""
      if (prev_cmd_idx < commands.length - 1) {
        prev_cmd_idx += 1
        cmd = commands[prev_cmd_idx]
      } else if (prev_entry && prev_cmd_idx == commands.length - 1) {
        prev_cmd_idx += 1
        cmd = prev_entry
      } else {
        prev_cmd_idx = undefined
      }

      term_input.textContent = cmd
      if (cmd) {
        setCaretIndex(term_input, term_input.textContent.length)
      }
    }
  }

  function stopCaretFlash() {
    if (disable_block_caret) { return }
    caret.classList.remove("flash")
  }

  function startCaretFlash() {
    if (disable_block_caret) { return }
    caret.classList.add("flash")
  }

  function placeBlockAtCaret() {
    if (disable_block_caret) { return }
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
  placeBlockAtCaret()

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

  function setCaretIndex(element, idx) {
    var setpos = document.createRange()
    var set = window.getSelection()

    // Set start position of range
    setpos.setStart(element.childNodes[0], idx)

    // Collapse range within its boundary points
    // Returns boolean
    setpos.collapse(true)

    // Remove all ranges set
    set.removeAllRanges()

    // Add range with respect to range object.
    set.addRange(setpos)

    // Set cursor on focus
    element.focus()
  }

  function getOffset(el) {
    const rect = el.getBoundingClientRect()
    return {
      left: rect.left,
      top: rect.top
    }
  }

  function getPrevCommands() {
    return Array.prototype.map.call(document.querySelectorAll(".line:not(.input)"), function(line) {
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
    commands.push(line)
    prev_entry = undefined

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
