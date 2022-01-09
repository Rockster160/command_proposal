module ::CommandProposal::ParamsHelper
  def sort_order
    params[:order] == "desc" ? "desc" : "asc"
  end

  def toggled_sort_order
    params[:order] == "desc" ? "asc" : "desc"
  end

  def current_params(merged={})
    params.except(:action, :controller, :host, :port, :authenticity_token, :utf8, :commit).to_unsafe_h.merge(merged)
  end

  def toggled_param(toggle_h)
    toggle_key = toggle_h.keys.first
    toggle_val = toggle_h.values.first

    if params[toggle_key].to_s == toggle_val.to_s
      cmd_path(:tasks, current_params.except(toggle_key))
    else
      cmd_path(:tasks, current_params(toggle_h))
    end
  end

  def current_path(new_params={})
    if @task.present?
      new_params.merge!(iteration: @iteration.id) if @iteration.present? && !@iteration.primary_iteration?
      cmd_path(@task, new_params)
    else
      cmd_path(:tasks, current_params(new_params))
    end
  end

  def truthy?(val)
    val.to_s.downcase.in?(["true", "t", "1"])
  end

  def true_param?(*param_keys)
    truthy?(params&.dig(*param_keys))
  end

  def humanized_duration(seconds)
    return "N/A" if seconds.blank?

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

  def div(opts={}, &block)
    "<div #{opts.map { |k, v| "#{k}=\"#{v}\"" }.join(" ")}>#{yield}</div>".html_safe
  end

  def command_paginate(paged_collection)
    collection = paged_collection.unscope(:limit, :offset)

    per = ::CommandProposal::PAGINATION_PER
    total_pages = (collection.count / per.to_f).ceil
    current_page = params[:page].presence&.to_i || 1

    return if total_pages <= 1

    div(class: "cmd-pagination") do
      links = []
      links << ["<<", { page: 1 }] if current_page > 1
      links << ["<", { page: current_page - 1 }] if current_page > 1

      (current_page-2..current_page+2).each do |page_window|
        next if page_window < 1
        next if page_window > total_pages

        links << [page_window, { page: page_window }]
      end

      links << [">", page: current_page + 1] if current_page < total_pages
      links << [">>", page: total_pages] if current_page < total_pages

      links.map do |link_text, link_params|
        "<a class=\"cmd-pagination-link #{'current-page' if link_params[:page] == current_page}\" href=\"#{current_path(link_params)}\">#{link_text}</a>"
      end.join("\n")
    end
  end
end
