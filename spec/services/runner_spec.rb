require "rails_helper"

RSpec.describe ::CommandProposal::Services::Runner do
  let(:subject) { described_class.new }
  let(:execute) { subject.execute(iteration) }

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
    "3: b + 1"
  }

  context "without approval" do
    it "does not run the task" do
      expect(subject).to_not receive(:run)
      expect(DummyCallerBack).not_to receive(:success)
      expect(DummyCallerBack).not_to receive(:failed)

      expect { execute }.to raise_error(::CommandProposal::Error)
      iteration.reload

      expect(iteration.result).to be_blank
    end
  end

  context "runs the task" do
    before do
      iteration.update(status: :approved)
    end

    it "shows the output of the task" do
      expect(subject).to receive(:run).and_call_original
      expect(DummyCallerBack).to receive(:success)
      expect(DummyCallerBack).not_to receive(:failed)

      execute
      iteration.reload

      expect(iteration.result).to eq(expected_result)
    end
  end

  context "with multiple runs" do
    before do
      iteration.update(status: :approved)
    end

    it "retains local vars" do
      runner = ::CommandProposal::Services::Runner.new

      expect(DummyCallerBack).to receive(:success)
      runner.execute(iteration)
      iteration.reload

      expect(iteration.result).to eq(expected_result)

      task.update(code: "a")
      iteration2 = task.current_iteration
      iteration2.update(status: :approved)

      expect(DummyCallerBack).to receive(:success)
      runner.execute(iteration2)
      iteration2.reload

      expect(iteration2.result).to eq("1")
    end

    it "retains methods" do
      runner = ::CommandProposal::Services::Runner.new

      iteration.update(code: "def doit; 5; end")
      expect(DummyCallerBack).to receive(:success)
      runner.execute(iteration)
      iteration.reload

      expect(iteration.result).to eq("doit")

      task.update(code: "doit")
      iteration2 = task.current_iteration
      iteration2.update(status: :approved)

      expect(DummyCallerBack).to receive(:success)
      runner.execute(iteration2)
      iteration2.reload

      expect(iteration2.result).to eq("5")
    end
  end

  context "with failing code" do
    before do
      iteration.update(status: :approved, code: failing_code)
    end

    it "returns output before the error and the error message" do
      expect(subject).to receive(:run).and_call_original
      expect(DummyCallerBack).not_to receive(:success)
      expect(DummyCallerBack).to receive(:failed)

      execute
      iteration.reload

      expect(iteration.result).to eq(expected_error)
    end
  end
  #
  # context "with bad args" do
  #   before do
  #     iteration.update(status: :approved, code: "sleep sleep1 1")
  #   end
  #
  #   it "does not include trace into gem" do
  #     expect(subject).to receive(:run).and_call_original
  #     expect(DummyCallerBack).not_to receive(:success)
  #     expect(DummyCallerBack).to receive(:failed)
  #
  #     execute
  #     iteration.reload
  #
  #     expect(iteration.result).to eq(expected_error)
  #   end
  # end
end
