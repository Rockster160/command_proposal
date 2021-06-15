module ::CommandProposal::PermissionsHelper
  def can_command?
    return true unless cmd_config.approval_required?

    command_user.try("#{cmd_config.role_scope}?")
  end

  def has_approval?(task)
    return true unless cmd_config.approval_required?

    task&.approved?
  end

  def command_user
    @command_user ||= send(cmd_config.controller_var)
  end

  def cmd_config
    ::CommandProposal.configuration
  end
end
