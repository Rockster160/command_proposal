::CommandProposal.configure do |config|
  # config.user_class = User
  config.proposal_callback = Proc.new { |iteration|
    puts "proposal_callback: #{iteration.id}"
  }
  config.success_callback = Proc.new { |iteration|
    puts "success_callback: #{iteration.id}"
  }
  config.failed_callback = Proc.new { |iteration|
    puts "failed_callback: #{iteration.id}"
  }
end
