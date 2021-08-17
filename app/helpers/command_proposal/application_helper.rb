module CommandProposal
  module ApplicationHelper
    # In order to keep the regular app's routes working in the base template, we have to manually
    #   render the engine routes. Built a helper for this because it's long and nasty otherwise.
    def cmd_path(*args)
      model_names = [:tasks, :iterations, :comments, :task, :iteration, :comment]
      args.map! { |arg|
        if arg.in?(model_names)
          "command_proposal_#{arg}".to_sym
        elsif arg == :task_iterations
          :iterations
        else
          arg
        end
      }

      command_proposal_engine.url_for(args)
    end

    # Runner controller doesn't map to a model, so needs special handling
    def runner_path(task, iteration=nil)
      if iteration.present?
        command_proposal_engine.command_proposal_task_runner_url(task, iteration)
      else
        command_proposal_engine.command_proposal_task_runner_index_url(task)
      end
    end
  end
end
