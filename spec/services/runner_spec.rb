require "rails_helper"

RSpec.describe CommandProposal::Services::Runner do
  let(:subject) { described_class.new(iteration) }
  let(:task) {
    CommandProposal::Task.create(
      session_type: :task,
    )
  }
  let(:iteration) {
    CommandProposal::Task.create(
      task: task,
      code: "a = 1\nputs 'Hello, World!'\na",
      status: :approved,
    )
  }

  context "runs the function" do
    before do
      subject
    end

    it "shows the output of the function" do
      expect(iteration.result).to eq("Hello, World\n1")
    end
  end
end
