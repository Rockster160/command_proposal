module ::CommandProposal::ParamsHelper
  def sort_order
    params[:order] == "desc" ? "desc" : "asc"
  end

  def toggled_sort_order
    params[:order] == "desc" ? "asc" : "desc"
  end

  def truthy?(val)
    val.to_s.downcase.in?(["true", "t", "1"])
  end

  def true_param?(*param_keys)
    truthy?(params&.dig(*param_keys))
  end
end
