class DummyCallerBack
  def self.proposal(iteration)
    puts "proposal_callback: #{iteration.id}"
  end

  def self.success(iteration)
    puts "success_callback: #{iteration.id}"
  end

  def self.failed(iteration)
    puts "failed_callback: #{iteration.id}"
  end
end

::CommandProposal.configure do |config|
  # config.user_class = User
  config.proposal_callback = Proc.new { |iteration|
    DummyCallerBack.proposal(iteration)
  }
  config.success_callback = Proc.new { |iteration|
    DummyCallerBack.success(iteration)
  }
  config.failed_callback = Proc.new { |iteration|
    DummyCallerBack.failed(iteration)
  }
end
