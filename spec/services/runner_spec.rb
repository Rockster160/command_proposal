require "rails_helper"

RSpec.describe ::CommandProposal::Services::Runner do
  let(:subject) { described_class.new(iteration) }
  let(:execute) { subject.execute }

  let(:task) { ::CommandProposal::Task.create(session_type: :task) }
  let(:iteration) {
    ::CommandProposal::Iteration.create(
      task: task,
      code: passing_code,
    )
  }

  let(:passing_code) { "a = 1\nputs 'Hello, World!'\na + 1" }
  let(:failing_code) { "a = 1\nputs 'Hello, World!'\nb + 1" }
  let(:expected_result) { "Hello, World!\n\n2" }
  let(:expected_error) {
    "Hello, World!\n\n"\
    "NameError: undefined local variable or method `b'\n\n"\
    ">> Command Trace\n"\
    "3: b + 1\n\n"
  }

  context "without approval" do
    it "does not run the function" do
      expect(subject).to_not receive(:run)

      expect { execute }.to raise_error(::CommandProposal::Error)
      iteration.reload

      expect(iteration.result).to be_blank
    end
  end

  context "runs the function" do
    before do
      iteration.update(status: :approved)
    end

    it "shows the output of the function" do
      expect(subject).to receive(:run).and_call_original

      execute
      iteration.reload

      expect(iteration.result).to eq(expected_result)
    end
  end

  context "with failing code" do
    before do
      iteration.update(status: :approved, code: failing_code)
    end

    it "returns output before the error and the error message" do
      expect(subject).to receive(:run).and_call_original

      execute
      iteration.reload

      expect(iteration.result).to eq(expected_error)
    end
  end
end
