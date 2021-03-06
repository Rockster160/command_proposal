module CommandProposal
  class Configuration
    attr_accessor(
      # Required
      :user_class_name,
      :role_scope,
      :user_name,
      :controller_var,
      # Default
      :approval_required,
      # Optional
      :proposal_callback,
      :approval_callback,
      :success_callback,
      :failed_callback,
      :skip_approval_for_types,
    )

    def initialize
      # Default
      @approval_required = true

      # User details - highly recommended
      @user_class_name = nil
      @role_scope = nil
      @user_name = nil
      @controller_var = nil

      # Optional
      @proposal_callback = nil
      @approval_callback = nil
      @success_callback = nil
      @failed_callback = nil
      @skip_approval_for_types = nil
    end

    def user_class
      @user_class ||= @user_class_name&.constantize
    end

    def approval_required?
      !!approval_required
    end
  end
end
