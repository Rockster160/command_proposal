// Add tab / shift-tab for changing indents
docReady(function() {
  terminal = document.querySelector(".cmd-terminal")
  var open = "<div class=\"line\">"
  var close = "</div>"
  var empty_line = open + "<br>" + close

  if (terminal) {
    terminal.addEventListener("keydown", handleInput)
    terminal.addEventListener("keyup", handleInput)
    terminal.addEventListener("input", handleInput)
    terminal.addEventListener("paste", handleInput)
    terminal.addEventListener("blur", function() {
      document.querySelector("#task_code_html").value = terminal.innerHTML
    })

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

    function handleInput(evt) {
      fixEmptyEditor(evt)
      handleNewLines()
      unnestLines()
    }

    function fixEmptyEditor(event) {
      // setTimeout(function() {
        var evt = event || window.event
        var elem = evt.target || evt.srcElement
        if (elem.nodeType == 3) {
          elem = elem.parentNode
        } // Defeat Safari bug

        if (elem.innerHTML == "") {
          elem.innerHTML = empty_line
        }
      // }, 0)
    }

    function generateToken() {
      var token = "abc"

      while (terminal.innerHTML.indexOf(token) >= 0) {
        token = Math.random().toString(36).substring(2, 15)
      }

      return token
    }

    function unnestLines() {
      var token = generateToken()
      var newHtml  = terminal.innerHTML

      if (!newHtml.match(/<div class=\"line\">[^(<\/div)]*?<div class=\"line\">/gi)) { return }
      console.log("Nest found!");

      newHtml = newHtml.replaceAll(/<\/?br>/gi, "<>" + token + "<>")
      // newHtml = newHtml.replaceAll(/<div class="line">[\s\n]*?<\/?br>[\s\n]*?<\/div>/gi, "<>" + token + "<>")

      var inner_tag_regexp = />[^<>]+?</ig
      var lines = (newHtml.match(inner_tag_regexp) || []).map(function(line_match) {
        return line_match.substr(1, line_match.length-2) || ""
      })

      var joined_lines = open + lines.join(close + open) + close

      terminal.innerHTML =  joined_lines.replaceAll(token, "<br>")
    }
    // terminal.innerHTML = unnestLines()

    function handleNewLines(evt) {
      // console.log("1", getCaretIndex(terminal));
      setTimeout(function() {
        if (terminal.innerHTML.indexOf("\n") >= 0) {
          var newline_count = (terminal.innerHTML.match(new RegExp("\n", "g")) || []).length
          var idx = getCaretIndex(terminal)

          terminal.innerHTML = terminal.innerHTML.replaceAll("\n", close + open)
          // terminal.innerHTML = terminal.innerHTML.replaceAll(open + close, empty_line)

          // console.log("2", getCaretIndex(terminal));
          setCaretIndex(terminal, idx - newline_count - 1)
          // setCaretIndex(terminal, idx)
        }
        // if (terminal.innerHTML.indexOf("<br>") >= 0) {
        //   terminal.innerHTML = terminal.innerHTML.replaceAll("<br>", "")
        // }
        //
        // if (terminal.innerHTML.indexOf("\n") >= 0) {
        // }
      }, 0)
    }
  }
})
