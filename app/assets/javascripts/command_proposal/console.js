// Add tab / shift-tab for changing indents
docReady(function() {
  var cmdconsole = document.querySelector(".cmd-console")

  if (cmdconsole) {
    var console_input = document.querySelector(".cmd-console .cmd-input")
    var lines = document.querySelector(".cmd-console .lines")
    var queue = Promise.resolve()
    var history_cmd_idx = undefined
    var stored_entry = undefined
    var commands = getPrevCommands()

    cmdconsole.addEventListener("click", function(evt) {
      if (!window.getSelection().toString().length && console_input) {
        console_input.focus()
      }
    })

    cmdconsole.addEventListener("keydown", function(evt) {
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
        history_cmd_idx = undefined
        stored_entry = console_input.textContent
        console_input.textContent = ""
      }

      if (isNaN(history_cmd_idx)) { history_cmd_idx = undefined }
      if (evt.key == "ArrowUp" && getCaretIndex(console_input) == 0) {
        handleUpKey(evt)
      }
      if (evt.key == "ArrowDown" && getCaretIndex(console_input) == console_input.textContent.length) {
        handleDownKey()
      }
    })

    function handleUpKey() {
      if (history_cmd_idx == undefined) {
        // Not scrolling through history
        if (console_input.textContent) {
          // Text has been entered
          stored_entry = console_input.textContent
        }
        // Set history index to begin scrolling
        history_cmd_idx = commands.length
      } else if (history_cmd_idx == 0) {
        return
      }

      history_cmd_idx -= 1
      console_input.textContent = commands[history_cmd_idx]
    }

    function handleDownKey() {
      if (history_cmd_idx != undefined) {
        var cmd = ""
        if (history_cmd_idx < commands.length - 1) {
          history_cmd_idx += 1
          cmd = commands[history_cmd_idx]
        } else if (stored_entry && history_cmd_idx == commands.length - 1) {
          history_cmd_idx += 1
          cmd = stored_entry
        } else {
          history_cmd_idx = undefined
        }

        console_input.textContent = cmd
        if (cmd) {
          setCaretIndex(console_input, console_input.textContent.length)
        }
      }
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
      return Array.prototype.map.call(document.querySelectorAll(".line:not(.cmd-input)"), function(line) {
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
      stored_entry = undefined
      history_cmd_idx = undefined

      runConsoleCode(line)
    }

    function runConsoleCode(line) {
      if (/^[\s\n]*$/.test(line.textContent)) { return }

      commands.push(line.textContent)
      queue = queue.then(async function() {
        $.rails.refreshCSRFTokens()

        var params = { code: line.textContent, task_id: cmdconsole.dataset.task }

        var res = await fetch(cmdconsole.dataset.exeUrl, {
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
