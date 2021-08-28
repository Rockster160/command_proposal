module CommandProposal
  module IconsHelper
    def icon(status)
      {
        created: "cmd-icon-grey fa fa-check",
        approved: "cmd-icon-green fa fa-check",
        started: "cmd-icon-grey fa fa-clock-o",
        cancelling: "cmd-icon-yellow fa fa-hourglass-half",
        cancelled: "cmd-icon-yellow fa fa-stop-circle",
        terminated: "cmd-icon-red fa fa-stop-circle",
        failed: "cmd-icon-red fa fa-times-circle",
        success: "cmd-icon-green fa fa-check-circle",
      }[status&.to_sym] || "cmd-icon-yellow fa fa-question"
    end
  end
end
