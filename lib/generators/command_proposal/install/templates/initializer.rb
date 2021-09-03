::CommandProposal.configure do |config|
  # Determines if a user needs a different user to approve their commands.
  # Defaults to true, the recommended value.
  # However, disabling in development could help with testing.
  # config.approval_required = !Rails.env.development?

  # Change if your base user class has a different model name
  config.user_class_name = "User"

  # Helper method used by controllers to identify the currently logged in account.
  config.controller_var = :current_user

  # Scope for your user class that determines users who are permitted to interact with commands
  # It is highly recommended to make this very exclusive, as any users in this scope will be able
  # to interact with your database directly.
  # Expected that the class will respond to `#{role_scope}` and
  #   instances of the class respond to `#{role_scope}?`
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
  # Called when a command is approved
  config.approval_callback = Proc.new { |proposal|
    # Slack.notify("The task #{proposal.name} has been approved and is now ready to run.\n<#{proposal.url}|Click Here> to view.")
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
