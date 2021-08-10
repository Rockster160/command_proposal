::CommandProposal.configure do |config|
  # Change if your base user class has a different model name
  config.user_class_name = "User"

  # Scope for your user class that determines users who are permitted to interact with commands (highly recommended to make this very exclusive, as any users in this scope will be able to interact with your database directly)
  config.role_scope = :admin

  # Method called to display a user's name
  config.user_name = :name

  # Callbacks for proposal state changes
  # `proposal` is the current proposal
  # Methods available:
  # `proposal.name`
  # `proposal.description`
  # `proposal.args`
  # `proposal.code`
  # `proposal.result`
  # `proposal.status`
  # `proposal.author`
  # `proposal.requester_name`
  # `proposal.approver_name`
  # `proposal.approved_at`
  # `proposal.started_at`
  # `proposal.completed_at`
  # `proposal.stopped_at`
  # `proposal.duration`

  # Called when a command is proposed for review
  config.proposal_callback = Proc.new { |proposal|
    # proposal_path = Rails.application.routes.url_helpers.command_url(iteration)
    # Slack.notify("#{proposal.requester_name} has proposed #{proposal.name}.\n<Click Here|#{proposal_url}> to view this proposal and approve.")
  }
  # Called when a command runs and completes successfully
  config.success_callback = Proc.new { |iteration|
    # proposal_path = Rails.application.routes.url_helpers.command_url(iteration)
    # Slack.notify("The task #{proposal.name} has completed in #{proposal.duration}s.\n<Click Here|#{proposal_url}> to view the results.")
  }
  config.failed_callback = Proc.new { |iteration|
    # proposal_path = Rails.application.routes.url_helpers.command_url(iteration)
    # Slack.notify("The task #{proposal.name} has completed in #{proposal.duration}s.\n<Click Here|#{proposal_url}> to view what went wrong.")
  }
end
