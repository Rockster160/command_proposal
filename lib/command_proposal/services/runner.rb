module CommandProposal
  module Services
    class Runner
      attr_accessor :session
      # Add expiration and things like that...

      def self.execute(friendly_id)
        task = ::CommandProposal::Task.find_by!(friendly_id: friendly_id)

        new.execute(task.primary_iteration)
      end

      def self.command(friendly_id, user, params={})
        # Hack magic because requires are not playing well with spring
        require "command_proposal/services/command_interpreter"

        params = params.to_unsafe_h if params.is_a?(ActionController::Parameters)

        iteration = ::CommandProposal::Services::CommandInterpreter.command(
          ::CommandProposal::Task.find_by!(friendly_id: friendly_id).primary_iteration,
          :run,
          user,
          { args: params }
        )

        start = Time.current
        wait_time = 5 # seconds
        loop do
          sleep 0.4

          break if iteration.reload.complete?
          break if Time.current - start > wait_time
        end

        iteration
      end

      def initialize
        @session = session
      end

      def execute(iteration)
        @iteration = iteration
        prepare

        run

        complete
        proposal = ::CommandProposal::Service::ProposalPresenter.new(@iteration)
        @iteration = nil
        proposal
      end

      def quick_fail(iteration, msg)
        @iteration = iteration
        prepare

        @iteration.status = :failed
        @iteration.result = msg

        complete
        proposal = ::CommandProposal::Service::ProposalPresenter.new(@iteration)
        @iteration = nil
        proposal
      end

      def quick_run(friendly_id)
        task = ::CommandProposal::Task.find_by!(friendly_id: friendly_id)
        iteration = task&.primary_iteration

        raise CommandProposal::Error, ":#{friendly_id} does not have approval to run." unless iteration&.approved?

        @session.eval(iteration.code)
      end

      private

      def session
        binding
      end

      def prepare
        raise CommandProposal::Error, "Cannot run task without approval" unless @iteration.approved?
        raise CommandProposal::Error, "Modules cannot be run independently" if @iteration.task.module?

        @iteration.task.update(last_executed_at: Time.current)
        @iteration.update(started_at: Time.current, status: :started)
      end

      def run
        begin
          params_str = ""
          unless @iteration.task.console? # Don't bring params into the console
            params_str = "params = #{@iteration.args || {}}.with_indifferent_access"
          end
          @session.eval("#{bring_function};#{params_str}")
        rescue Exception => e # rubocop:disable Lint/RescueException - Yes, rescue full Exception so that we can catch typos in evals as well
          return @iteration.result = results_from_exception(e)
        end

        stored_stdout = $stdout
        $stdout = StringIO.new
        result = nil # Init var for scope
        status = nil

        running_thread = Thread.new do
          begin
            # Run `bring` functions in here so we can capture any string outputs
            # OR! Run the full runner and instead of saving to an iteration, return the string for prepending here
            result = @session.eval("_ = (#{@iteration.code})").inspect # rubocop:disable Security/Eval - Eval is scary, but in this case it's exactly what we need.
            result = nil unless @iteration.task.console? # Only store final result for consoles
            status = :success
          rescue Exception => e # rubocop:disable Lint/RescueException - Yes, rescue full Exception so that we can catch typos in evals as well
            status = :failed

            result = results_from_exception(e)
          end
        end

        while running_thread.status.present?
          @iteration.reload

          if $stdout.try(:string) != @iteration.result
            @iteration.update(result: $stdout.try(:string).dup)
          end

          if @iteration.cancelling?
            running_thread.exit
            status = :cancelled
          end

          sleep 0.4
        end

        output = $stdout.try(:string)
        output = nil if output == ""
        # Not using presence because we want to maintain other empty objects such as [] and {}

        $stdout = stored_stdout
        @iteration.status = status
        @iteration.result = [output, result].compact.join("\n")
      end

      def bring_function
        "def bring(*func_names); func_names.each { |f| self.quick_run(f) }; end"
      end

      def complete
        @iteration.completed_at = Time.current
        if @iteration.cancelling? || @iteration.cancelled?
          @iteration.result += "\n\n~~~~~ CANCELLED ~~~~~"
          @iteration.status = :cancelled
        elsif @iteration.status&.to_sym == :failed
          # No-op
        else
          @iteration.status = :success
        end
        @iteration.save!

        return if @iteration.task.console? # Don't notify for every console entry
        proposal = ::CommandProposal::Service::ProposalPresenter.new(@iteration)
        if @iteration.success?
          ::CommandProposal.configuration.success_callback&.call(proposal)
        else
          ::CommandProposal.configuration.failed_callback&.call(proposal)
        end
      end

      def results_from_exception(exc)
        klass = exc.class
        # Dup to avoid frozen string errors
        msg = (exc.try(:message) || exc.try(:body) || exc.to_s).dup
        # Remove proposal context
        msg.gsub!(/ for \#\<CommandProposal.*/, "")
        msg.gsub!(/(::)?CommandProposal::Services::Runner(::)?/, "")
        # Remove gem lines
        msg.gsub!(/\/?((\w|(\\ ))*\/)*command_proposal\/services(\/(\w|(\\ ))*)*\.\w+\:\d+\: /, "")
        info = gather_exception_info(exc)

        ["#{klass}: #{msg}", info.presence].compact.join("\n")
      end

      def gather_exception_info(exception)
        error_info = []
        backtrace = full_trace_from_exception(exception)

        eval_trace = backtrace.select { |row| row.include?("(eval)") }.presence || []
        eval_trace = eval_trace.map do |row|
          eval_row_number = row[/\(eval\)\:\d+/].to_s.dup[7..-1]
          next if eval_row_number.blank?

          error_line = @iteration.code.split("\n")[eval_row_number.to_i - 1]
          "#{eval_row_number}: #{error_line}" if error_line.present?
        end.compact
        error_info += ["\n>> Command Trace"] + eval_trace if eval_trace.any?

        app_trace = backtrace.select { |row|
          row.include?("/app/") && !row.match?(/command_proposal\/(lib|app)/)
        }.presence || []
        error_info += ["\n>> App Trace"] + app_trace if app_trace.any?

        error_info.uniq.join("\n")
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
