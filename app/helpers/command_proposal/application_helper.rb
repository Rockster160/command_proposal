module CommandProposal
  module ApplicationHelper
    # In order to keep the regular app's routes working in the base template, we have to manually
    #   render the engine routes. Built a helper for this because it's long and nasty otherwise.
    def cmd_path(*args)
      model_names = [:tasks, :iterations, :comments, :task, :iteration, :comment]
      host = nil
      args.map! { |arg|
        next host ||= arg.delete(:host) if arg.is_a?(Hash) && arg.key?(:host)
        if arg.in?(model_names)
          "command_proposal_#{arg}".to_sym
        elsif arg == :task_iterations
          :iterations
        else
          arg
        end
      }
      args << { host: host, port: nil } if host.present?

      begin
        router.url_for(args.compact)
      rescue NoMethodError => e
        raise "Error generating route! Please make sure `default_url_options` are set."
      end
    end

    # Runner controller doesn't map to a model, so needs special handling
    def runner_path(task, iteration=nil)
      if iteration.present?
        router.command_proposal_task_runner_url(task, iteration)
      else
        router.command_proposal_task_runner_index_url(task)
      end
    end

    def router
      @@router ||= begin
        routes = ::CommandProposal::Engine.routes
        routes.default_url_options = rails_default_url_options
        routes.url_helpers
      end
    end

    def rails_default_url_options
      Rails.application.config.action_mailer.default_url_options.tap do |default_opts|
        default_opts ||= {}
        default_opts[:host] ||= "localhost"
        default_opts[:port] ||= "3000"
        default_opts[:protocol] ||= "http"
      end
    end
  end
end
