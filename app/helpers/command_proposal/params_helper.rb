module ::CommandProposal::ParamsHelper
  def sort_order
    params[:order] == "desc" ? "desc" : "asc"
  end

  def toggled_sort_order
    params[:order] == "desc" ? "asc" : "desc"
  end

  def current_params(merged={})
    params.except(:action, :controller, :host, :port).to_unsafe_h.merge(merged)
  end

  def toggled_param(toggle_h)
    toggle_key = toggle_h.keys.first
    toggle_val = toggle_h.values.first

    if params[toggle_key].to_s == toggle_val.to_s
      current_params.except(toggle_key)
    else
      current_params(toggle_h)
    end
  end

  def truthy?(val)
    val.to_s.downcase.in?(["true", "t", "1"])
  end

  def true_param?(*param_keys)
    truthy?(params&.dig(*param_keys))
  end
end
