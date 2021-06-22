module CommandProposal
  class Configuration
    attr_accessor(
      # Required
      :user_class,
      :role_scope,
      :user_name,
      :controller_var,
      # Default
      :approval_required,
      # Optional
      :proposal_callback,
      :success_callback,
      :failed_callback
    )

    def initialize
      # Required
      if Object.const_defined?("User")
        @user_class = User
        @role_scope = :admin
        @user_name = :name
        @controller_var = "current_#{@user_class.name.downcase}"
      end

      # Default
      @approval_required = true

      # Optional
      @proposal_callback = nil
      @success_callback = nil
      @failed_callback = nil
    end

    def approval_required?
      !!approval_required
    end
  end
end
