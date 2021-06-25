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

  def humanized_duration(seconds)
    remaining = seconds.round
    str_parts = []

    durations = {
      W: 7 * 24 * 60 * 60,
      D: 24 * 60 * 60,
      H: 60 * 60,
      M: 60,
      S: 1,
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

    str_parts.join(" ")
  end
end
