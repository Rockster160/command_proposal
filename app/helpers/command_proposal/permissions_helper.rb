module CommandProposal
  module PermissionsHelper
    def can_command?(user=command_user)
      return true unless cmd_config.approval_required?

      command_user.try("#{cmd_config.role_scope}?")
    end

    def can_approve?(iteration)
      return true unless cmd_config.approval_required?
      return if iteration.nil?

      command_user.try("#{cmd_config.role_scope}?") && !current_is_author?(iteration)
    end

    def has_approval?(task)
      return true unless cmd_config.approval_required?

      if task&.console?
        task.first_iteration&.approved_at?
      else
        task&.approved_at?
      end
    end

    def current_is_author?(iteration)
      command_user&.id == iteration&.requester&.id
    end

    def command_user(user=nil)
      @command_user ||= begin
        if user.present?
          user
        elsif cmd_config.controller_var.blank?
          nil
        else
          try(cmd_config.controller_var)
        end
      end
    end

    def cmd_config
      ::CommandProposal.configuration
    end
  end
end
