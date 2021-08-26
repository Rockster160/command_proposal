module CommandProposal
  module ApplicationHelper
    include ActionDispatch::Routing::PolymorphicRoutes
    include Rails.application.routes.url_helpers
    # In order to keep the regular app's routes working in the base template, we have to manually
    #   render the engine routes. Built a helper for this because it's long and nasty otherwise.
    def cmd_url(*args)
      return string_path(*args) if args.first.is_a?(String)
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
        command_proposal_engine.url_for(args.compact)
      rescue NoMethodError => e
        raise "Error generating route! Please make sure `config.action_mailer.default_url_options` are set."
      end
    end

    def cmd_path(*args)
      args.tap { |arg_list|
        if arg_list.last.is_a?(Hash)
          arg_list.last.merge!(only_path: true)
        else
          arg_list << { only_path: true }
        end
      }

      cmd_url(*args)
    end

    def string_path(*args)
      [command_proposal_engine.command_proposal_tasks_url + args.shift, args.to_param.presence].compact.join("?")
    end

    # Runner controller doesn't map to a model, so needs special handling
    def runner_path(task, iteration=nil)
      if iteration.present?
        command_proposal_engine.command_proposal_task_runner_path(task, iteration)
      else
        command_proposal_engine.command_proposal_task_runner_index_path(task)
      end
    end

    # Runner controller doesn't map to a model, so needs special handling
    def runner_url(task, iteration=nil)
      if iteration.present?
        command_proposal_engine.command_proposal_task_runner_url(task, iteration)
      else
        command_proposal_engine.command_proposal_task_runner_index_url(task)
      end
    end
  end
end
