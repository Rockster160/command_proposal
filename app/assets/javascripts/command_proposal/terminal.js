docReady(function() {
  var terminals = document.querySelectorAll(".cmd-terminal")

  function setReadOnlyUI(cm) {
    cm.getWrapperElement().classList.add("CodeMirror-readonly")

    pencil = document.createElement("i")
    pencil.className = "fa fa-pencil fa-stack-1x"

    ban = document.createElement("i")
    ban.className = "fa fa-ban fa-stack-2x fa-flip-horizontal"

    stack = document.createElement("span")
    stack.className = "fa-stack fa-2x"
    stack.append(pencil)
    stack.append(ban)

    cm.getWrapperElement().append(stack)
  }

  terminals.forEach(function(terminal) {
    var cm = CodeMirror.fromTextArea(
      terminal,
      {
        tabSize: 2,
        lineNumbers: true,
        readOnly: terminal.readOnly || false,
        mode: "ruby",
        theme: "rubyblue",
        keyMap: "sublime",
        viewportMargin: Infinity,
        height: "auto",
      }
    )

    if (terminal.readOnly) {
      setReadOnlyUI(cm)
    }
  })
})
