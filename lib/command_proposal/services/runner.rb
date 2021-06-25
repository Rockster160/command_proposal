require "pry"

# def doit; puts "hi"; 3; end; doit

module CommandProposal
  module Services
    class Runner
      attr_accessor :session
      # Add expiration and things like that...

      def initialize
        @session = session
      end

      def execute(iteration)
        @iteration = iteration
        prepare

        run

        complete
        @iteration = nil
      end

      private

      def session
        binding
      end

      def prepare
        raise CommandProposal::Error, "Cannot run task without approval" unless @iteration.approved?

        @iteration.update(started_at: Time.current, status: :started)
      end

      def run
        begin
          stored_stdout = $stdout
          $stdout = StringIO.new
          result = @session.eval(@iteration.code).inspect # rubocop:disable Security/Eval - Eval is scary, but in this case it's exactly what we need.
        rescue Exception => e # rubocop:disable Lint/RescueException - Yes, rescue full Exception so that we can catch typos in evals as well
          @iteration.status = :failed

          result = results_from_exception(e)
        ensure
          output = $stdout.try(:string)

          $stdout = stored_stdout
        end

        output = nil if output == ""

        @iteration.result = [output, "#{result || 'nil'}"].compact.join("\n")
      end

      def complete
        @iteration.completed_at = Time.current
        @iteration.status = :success unless @iteration.failed?
        @iteration.save!

        if @iteration.success?
          ::CommandProposal.configuration.success_callback&.call(@iteration)
        else
          ::CommandProposal.configuration.failed_callback&.call(@iteration)
        end
      end

      def results_from_exception(exc)
        klass = exc.class
        msg = exc.try(:message) || exc.try(:body) || exc.to_s
        msg.gsub!(/ for \#\<CommandProposal.*/, "") # Remove proposal context
        info = gather_exception_info(exc)

        ["#{klass}: #{msg}", info.presence].compact.join("\n")
      end

      def gather_exception_info(exception)
        error_info = []
        backtrace = full_trace_from_exception(exception)

        eval_trace = backtrace.select { |row| row.include?("(eval)") }.presence || []
        eval_trace = eval_trace.map do |row|
          eval_row_number = row[/\(eval\)\:\d+/].to_s[7..-1]
          next if eval_row_number.blank?

          error_line = @iteration.code.split("\n")[eval_row_number.to_i - 1]
          "#{eval_row_number}: #{error_line}" if error_line.present?
        end.compact
        error_info += ["\n>> Command Trace"] + eval_trace if eval_trace.any?

        app_trace = backtrace.select { |row|
          row.include?("/app/") && !row.match?(/command_proposal\/(lib|app)/)
        }.presence || []
        error_info += ["\n>> App Trace"] + app_trace if app_trace.any?

        error_info.join("\n")
      end

      def full_trace_from_exception(exception)
        trace = exception.try(:backtrace).presence
        return trace if trace.present?

        trace = @session.send(:caller).dup
        return trace if trace.present?

        trace = caller.dup
        trace
      end
    end
  end
end
