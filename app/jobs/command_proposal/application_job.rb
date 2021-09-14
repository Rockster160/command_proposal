module CommandProposal
  class ApplicationJob < ActiveJob::Base
    rescue_from(StandardError) do |exception|
      Rails.logger.error "[#{self.class.name}] Job failed and will not retry: #{exception.to_s}"
    end
  end
end
