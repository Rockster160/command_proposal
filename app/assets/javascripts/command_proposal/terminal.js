docReady(function() {
  var terminals = document.querySelectorAll(".cmd-terminal")

  terminals.forEach(function(terminal) {
    CodeMirror.fromTextArea(
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
  })
})
