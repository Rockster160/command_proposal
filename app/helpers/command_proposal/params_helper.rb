module ::CommandProposal::ParamsHelper
  def sort_order
    params[:order] == "desc" ? "desc" : "asc"
  end

  def toggled_sort_order
    params[:order] == "desc" ? "asc" : "desc"
  end

  def current_params(merged={})
    params.except(:action, :controller, :host, :port, :authenticity_token, :utf8).to_unsafe_h.merge(merged)
  end

  def toggled_param(toggle_h)
    toggle_key = toggle_h.keys.first
    toggle_val = toggle_h.values.first
    
    if params[toggle_key].to_s == toggle_val.to_s
      command_proposal.url_for(current_params.except(toggle_key))
    else
      command_proposal.url_for(current_params(toggle_h))
    end
  end

  def truthy?(val)
    val.to_s.downcase.in?(["true", "t", "1"])
  end

  def true_param?(*param_keys)
    truthy?(params&.dig(*param_keys))
  end

  def humanized_duration(seconds)
    remaining = seconds.round
    str_parts = []

    durations = {
      w: 7 * 24 * 60 * 60,
      d: 24 * 60 * 60,
      h: 60 * 60,
      m: 60,
      s: 1,
    }

    durations.each do |label, length|
      count_at_length = 0

      while remaining > length do
        remaining -= length
        count_at_length += 1
      end

      next if count_at_length == 0

      str_parts.push("#{count_at_length}#{label}")
    end

    return "< 1s" if str_parts.none?
    str_parts.join(" ")
  end
end
