module CommandProposal
  class EngineController < ::ApplicationController
    layout "layouts/application"
    # layout "layouts/command_proposal/application"

    rescue_from ActionView::Template::Error, with: ->(err) {
      method = err.message[/\`[a-z_]+\'/][1..-2]

      if (method.to_s.end_with?('_path') || method.to_s.end_with?('_url')) && main_app.respond_to?(method)
        main_app.send(method)
      else
        puts "\e[33m[LOGIT]method:'#{method}'\e[0m"
        # No method found, raise original error
        raise err
      end
    }
  end
end
