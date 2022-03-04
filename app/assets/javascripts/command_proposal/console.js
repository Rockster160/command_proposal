// Add tab / shift-tab for changing indents
cmdDocReady(function() {
  var cmdconsole = document.querySelector(".cmd-console")

  if (cmdconsole) {
    var console_input = document.querySelector(".cmd-console .cmd-entry")
    var lines = document.querySelector(".cmd-console .lines")
    var queue = new CommandQueue
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

      if (!(/^[\s\n]*$/.test(line.textContent))) {
        var result = document.createElement("div")
        result.classList.add("result")

        var spinner = document.createElement("i")
        spinner.className = "fa fa-circle-o-notch fa-spin cmd-icon-grey"
        result.append(spinner)

        line.appendChild(result)
      }

      lines.appendChild(line)
      stored_entry = undefined
      history_cmd_idx = undefined

      runConsoleCode(line)
    }

    function runConsoleCode(line) {
      if (/^[\s\n]*$/.test(line.textContent)) { return }

      commands.push(line.textContent)
      queue.add(function(evt) {
        $.rails.refreshCSRFTokens()

        var params = { code: line.textContent, task_id: cmdconsole.dataset.task }

        var client = new HttpClient()
        client.post(cmdconsole.dataset.exeUrl, {
          headers: {
            "Content-Type": "application/json",
            "X-CSRF-Token": $.rails.csrfToken()
          },
          body: JSON.stringify(params),
          done: function(res, status, req) {
            if (status == 200) {
              handleSuccessfulCommand(evt, line, JSON.parse(res))
            } else {
              console.log("Error: ", res, req);
            }
          }
        })
      })
    }

    function handleSuccessfulCommand(evt, line, json) {

      if (json.error) {
        addLineResult(line, json.error, "cmd-error")
      } else if (json.status != "started") {
        addLineResult(line, json.result)
      } else {
        return setTimeout(function() { pollIteration(evt, line, json.results_endpoint) }, 2000)
      }

      evt.finish()
    }

    function addLineResult(line, text, result_class) {
      line.querySelector(".result").remove()

      if (/^[\s\n]*$/.test(text)) { return }

      var result = document.createElement("div")
      result.classList.add("result")
      if (result_class) { result.classList.add(result_class) }

      var truncate = 2000
      if (text.length > truncate-3) {
        result.textContent = text.slice(0, truncate-3) + "..."
        var encoded = encodeURIComponent(text)

        var download = document.createElement("a")
        download.classList.add("cmd-truncated-download")
        download.setAttribute("href", "data:application/txt," + encoded)
        download.setAttribute("download", "result.txt")
        download.textContent = "Output truncated. Click here to download full result."

        line.insertAdjacentElement("afterend", download)
      } else {
        result.textContent = text
      }

      line.appendChild(result)
    }

    function pollIteration(evt, line, endpoint) {
      var client = new HttpClient()
      client.get(endpoint, {
        headers: {
          "Content-Type": "application/json",
          "X-CSRF-Token": $.rails.csrfToken()
        },
        done: function(res, status, req) {
          if (status == 200) {
            var json = JSON.parse(res)
            if (json.status == "started") {
              setTimeout(function() { pollIteration(evt, line, endpoint) }, 2000)
            } else {
              addLineResult(line, json.result)
              evt.finish()
            }
          } else {
            console.log("Error: ", res, req);
            evt.finish()
          }
        }
      })
    }
  }
})
