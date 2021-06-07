require "rails_helper"

RSpec.describe CommandProposal::Services::Runner do
  let(:subject) { described_class.new(iteration) }
  let(:execute) { subject.execute }
  let(:task) {
    CommandProposal::Task.create(
      session_type: :task,
    )
  }
  let(:iteration) {
    CommandProposal::Iteration.create(
      task: task,
      code: "a = 1\nputs 'Hello, World!'\na + 1",
    )
  }
  let(:expected_result) { "Hello, World!\n\n2" }

  context "without approval" do
    it "does not run the function" do
      expect(subject).to_not receive(:run)

      expect { execute }.to raise_error(CommandProposal::Error)

      expect(iteration.reload.result).to be_blank
    end
  end

  context "runs the function" do
    before do
      iteration.update(status: :approved)
    end

    it "shows the output of the function" do
      expect(subject).to receive(:run).and_call_original

      execute

      expect(iteration.reload.result).to eq(expected_result)
    end
  end
end
