module CommandProposal
  module PermissionsHelper
    def can_command?(user=command_user)
      return true unless cmd_config.approval_required?

      command_user.try("#{cmd_config.role_scope}?")
    end

    def can_approve?(iteration)
      return true unless cmd_config.approval_required?
      return if iteration.nil?

      command_user.try("#{cmd_config.role_scope}?") && iteration.requester&.id != command_user&.id
    end

    def has_approval?(task)
      return true unless cmd_config.approval_required?

      if task&.console?
        task.first_iteration&.approved?
      else
        task&.approved?
      end
    end

    def current_is_author?(iteration)
      command_user&.id == iteration&.requester&.id
    end

    def command_user(user=nil)
      @command_user ||= begin
        cmd_user = user

        return cmd_user unless cmd_config.approval_required?
        cmd_user || send(cmd_config.controller_var)
      end
    end

    def cmd_config
      ::CommandProposal.configuration
    end
  end
end
