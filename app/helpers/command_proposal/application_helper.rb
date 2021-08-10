module CommandProposal
  module ApplicationHelper
    # Allows paths defined in main_app to be used from views in the engine
    def method_missing(method, *args, &block)
      if (method.to_s.end_with?('_path') || method.to_s.end_with?('_url')) && main_app.respond_to?(method)
        main_app.send(method, *args)
      else
        super
      end
    end
  end
end
