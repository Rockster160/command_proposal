# ::CommandProposal::CommandFormatter.to_html_lines
module CommandProposal
  class CommandFormatter
    def self.to_html_lines text_lines
      return "<div class=\"line\"></div>".html_safe if text_lines.blank?

      text_lines.gsub("\r", "").split("\n").map do |line|
        line = line.gsub("<", "&lt;").gsub(">", "&gt;")
        "<div class=\"line\">#{line.presence || "</br>"}</div>"
      end.compact.join("").html_safe
    end

    def self.to_text_lines html_lines
      html_lines
        .gsub("<div class=\"line\">", "")
        .gsub("<div>", "")
        .gsub("</div>", "\n")
        .gsub(/<\/?br>/, "")
    end
  end
end
