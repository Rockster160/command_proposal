// Add tab / shift-tab for changing indents
docReady(function() {
  var console = document.querySelector(".cmd-console")

  if (console) {
    var console_input = document.querySelector(".cmd-console .input")
    var lines = document.querySelector(".cmd-console .lines")
    var queue = Promise.resolve()
    var prev_cmd_idx = undefined, prev_entry = undefined
    var caret = document.querySelector(".caret")
    var commands = getPrevCommands()
    // Caret block is neat, but not very cross-browser compatible and has some functional issues.
    var display_caret_block = false

    if (display_caret_block) {
      caret.classList.remove("hidden")
      console.style.caretColor = "transparent"
    } else {
      caret.remove()
    }

    console_input.addEventListener("blur", stopCaretFlash)
    console_input.addEventListener("focus", function() {
      startCaretFlash()
      placeBlockAtCaret()
    })
    console_input.addEventListener("keydown", placeBlockAtCaret)
    console_input.addEventListener("keyup", placeBlockAtCaret)
    console_input.addEventListener("mousedown", placeBlockAtCaret)

    console.addEventListener("click", function(evt) {
      if (!window.getSelection().toString().length) {
        console_input.focus()
      }
    })

    console.addEventListener("keydown", function(evt) {
      // console.log(evt.key)
      // evt.shiftKey
      // evt.ctrlKey
      // evt.altKey
      // evt.metaKey (windows key or CMD key)

      if (evt.key == "Enter" && !evt.shiftKey) {
        evt.preventDefault()
        submitConsoleCode()
        return false
      }

      if (evt.ctrlKey && evt.key == "c") {
        prev_cmd_idx = undefined
        prev_entry = console_input.textContent
        console_input.textContent = ""
      }

      if (evt.key == "ArrowUp" && getCaretIndex(console_input) == 0) {
        handleUpKey(evt)
      }
      if (evt.key == "ArrowDown" && getCaretIndex(console_input) == console_input.textContent.length) {
        handleDownKey()
      }
    })

    function handleUpKey() {
      if (!prev_cmd_idx) {
        if (prev_entry) {
          prev_cmd_idx = commands.length - 1
          console_input.textContent = prev_entry

          return
        }

        prev_cmd_idx = commands.length
        prev_entry = console_input.textContent
      }

      prev_cmd_idx -= 1
      console_input.textContent = commands[prev_cmd_idx]
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

        console_input.textContent = cmd
        if (cmd) {
          setCaretIndex(console_input, console_input.textContent.length)
        }
      }
    }

    function stopCaretFlash() {
      if (!display_caret_block) { return }
      caret.classList.remove("flash")
    }

    function startCaretFlash() {
      if (!display_caret_block) { return }
      caret.classList.add("flash")
    }

    function placeBlockAtCaret() {
      if (!display_caret_block) { return }
      setTimeout(function() {
        caret.classList.remove("hidden")
        caret.classList.remove("flash")
        void caret.offsetWidth
        caret.classList.add("flash")
        var coords = getCaretCoordinates()
        var offset = getOffset(console)
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

    function submitConsoleCode() {
      var line = document.createElement("div")
      line.classList.add("line")
      line.textContent = console_input.textContent

      console_input.textContent = ""
      lines.appendChild(line)
      prev_entry = undefined
      prev_cmd_idx = undefined

      runConsoleCode(line)
    }

    function runConsoleCode(line) {
      if (/^[\s\n]*$/.test(line.textContent)) { return }

      commands.push(line.textContent)
      queue = queue.then(async function() {
        $.rails.refreshCSRFTokens()

        var params = { code: line.textContent, task_id: console.dataset.task }

        var res = await fetch(console.dataset.exeUrl, {
          method: "POST",
          headers: {
            "Content-Type": "application/json",
            "X-CSRF-Token": $.rails.csrfToken()
          },
          body: JSON.stringify(params)
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

        var result = document.createElement("div")
        result.classList.add("result")

        if (json.error) {
          result.classList.add("cmd-error")
          result.textContent = json.error
        } else {
          result.textContent = json.result
        }

        line.appendChild(result)
      })
    }
  }
})
