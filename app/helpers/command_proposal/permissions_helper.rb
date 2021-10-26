module CommandProposal
  module PermissionsHelper
    def can_command?(user=command_user)
      return false unless permitted_to_use?
      return true unless approval_required?

      command_user.try("#{cmd_config.role_scope}?")
    end

    def can_approve?(iteration)
      return false unless permitted_to_use?
      return true unless approval_required?
      return if iteration.nil?

      command_user.try("#{cmd_config.role_scope}?") && !current_is_author?(iteration)
    end

    def has_approval?(task)
      return false unless permitted_to_use?
      return true unless approval_required?

      task&.approved?
    end

    def approval_required?
      cmd_config.approval_required?
    end

    def current_is_author?(iteration)
      return false unless permitted_to_use?

      command_user&.id == iteration&.requester&.id
    end

    def permitted_to_use?
      return true if cmd_config.controller_var.blank?

      command_user&.send("#{cmd_config.role_scope}?")
    end

    def command_user(user=nil)
      @command_user ||= begin
        if user.present?
          user
        elsif cmd_config.controller_var.blank?
          nil
        else
          send(cmd_config.controller_var)
        end
      end
    end

    def cmd_config
      ::CommandProposal.configuration
    end
  end
end
