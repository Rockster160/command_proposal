module CommandProposal
  class Configuration
    attr_accessor(
      # Required
      :user_class,
      # Default
      :approval_required,
      # Optional
      :proposal_callback,
      :success_callback,
      :failed_callback
    )

    def initialize
      # Required
      @user_class = nil

      # Default
      @approval_required = true

      # Optional
      @proposal_callback = nil
      @success_callback = nil
      @failed_callback = nil
    end
  end
end
