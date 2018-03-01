class ActsDatatable
  delegate :params, :h, :link_to, to: :@view

  def initialize(view)
    @view = view
  end

  def as_json(options = {})
    {
      sEcho: params[:sEcho].to_i,
      iTotalRecords: Act.count,
      iTotalDisplayRecords: acts.total_entries,
      aaData: data
    }
  end

private

  def data
    acts.map do |act|
      [
        link_to(act.act_name, act)
        # ERB::Util.h(act.act_gp_date)
      ]

    end
  end

  def acts
    @acts ||= fetch_acts
  end

  def fetch_acts
    # acts = Act.order("#{sort_column} #{sort_direction}")
    acts = Act.where(actx: FALSE, gp_sts: 'Valid').order("#{sort_column} #{sort_direction}")

    acts = acts.page(page).per_page(per_page)
    if params[:sSearch].present?
      acts = acts.where("act_name like :search", search: "%#{params[:sSearch]}%")
    end
    acts
  end

  def page
    params[:iDisplayStart].to_i/per_page + 1
  end

  def per_page
    params[:iDisplayLength].to_i > 0 ? params[:iDisplayLength].to_i : 10
  end

  def sort_column
    # columns = %w[act_name]
    # columns = %w[act_name act_gp_date]
    columns = %w[act_name]
    columns[params[:iSortCol_0].to_i]
  end

  def sort_direction
    params[:sSortDir_0] == "desc" ? "desc" : "asc"
  end
end
