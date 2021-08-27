::CommandProposal.configure do |config|
  # Change if your base user class has a different model name
  config.user_class_name = "User"

  # Helper method used by controllers to identify the currently logged in account.
  config.controller_var = :current_user

  # Scope for your user class that determines users who are permitted to interact with commands
  # It is highly recommended to make this very exclusive, as any users in this scope will be able
  # to interact with your database directly.
  config.role_scope = :admin

  # Method called to display a user's name
  config.user_name = :name

  # Callbacks for proposal state changes
  # `proposal` is the current proposal
  # Methods available:
  # `proposal.url`
  # `proposal.type`
  # `proposal.name`
  # `proposal.description`
  # `proposal.args`
  # `proposal.code`
  # `proposal.result`
  # `proposal.status`
  # `proposal.requester`
  # `proposal.approver`
  # `proposal.approved_at`
  # `proposal.started_at`
  # `proposal.completed_at`
  # `proposal.stopped_at`
  # `proposal.duration`

  # Called when a command is proposed for review
  config.proposal_callback = Proc.new { |proposal|
    # Slack.notify("#{proposal.requester} has proposed #{proposal.name}.\n<#{proposal.url}|Click Here> to view this proposal and approve.")
  }
  # Called when a command runs and completes successfully
  config.success_callback = Proc.new { |proposal|
    # Slack.notify("The task #{proposal.name} has completed in #{proposal.duration}s.\n<#{proposal.url}|Click Here> to view the results.")
  }
  # Called when a command runs but fails to complete
  config.failed_callback = Proc.new { |proposal|
    # Slack.notify("The task #{proposal.name} has failed!\n<#{proposal.url}|Click Here> to see what went wrong.")
  }
end
