class CommandProposal
  class CommandError < RuntimeError; end
  class Runner
    attr_accessor :task, :iteration, :session

    def initialize(iteration, session=nil)
      self.iteration = iteration
      self.task = iteration.task
      self.session = session || binding
    end

    def execute
      prepare

      run

      complete
    end

    private

    def prepare
      raise CommandError, "Cannot run task without approval" unless iteration.approved?

      iteration.update(started_at: Time.current)
      # trigger started callback
    end

    def run
      begin
        stored_stdout = $stdout
        $stdout = StringIO.new
        res = session.eval(iteration.code) # rubocop:disable Security/Eval - Eval is scary, but in this case it's exactly what we need.
      rescue Exception => e # rubocop:disable Lint/RescueException - Yes, rescue full Exception so that we can catch typos in evals as well
        iteration.failure = true

        res = results_from_exception(e)
      ensure
        output = $stdout.try(:string)

        $stdout = stored_stdout
      end

      iteration.result = [output, result].map(&:presence).compact.join("\n")
    end

    def complete
      iteration.completed_at = Time.current
      iteration.save
      # trigger completed callback
    end

    def results_from_exception(exc)
      klass = exc.class
      msg = exc.try(:message) || exc.try(:body) || exc.to_s
      info = gather_exception_info(exc)

      "#{klass}: #{msg}\n\n#{info}"
    end

    def gather_exception_info(exception)
      error_info = []
      backtrace = full_trace_from_exception(exception)

      eval_trace = backtrace.select { |row| row.include?("(eval)") }.presence || []
      eval_trace = eval_trace.map do |row|
        eval_row_number = row[/\(eval\)\:\d+/].to_s[7..-1]
        next if eval_row_number.blank?

        error_line = iteration.code.split("\n")[eval_row_number.to_i - 1]
        "#{eval_row_number}: #{error_line}" if error_line.present?
      end.compact
      error_info += [">> Eval Trace"] + eval_trace + ["\n"] if eval_trace.any?

      app_trace = backtrace.select { |row| row.include?("/app/") }.presence || []
      error_info += [">> App Trace"] + app_trace + ["\n"] if app_trace.any?

      error_info.join("\n")
    end

    def full_trace_from_exception(exception)
      trace = exception.try(:backtrace).presence
      return trace if trace.present?

      trace = caller.dup
      trace
    end
  end
end
