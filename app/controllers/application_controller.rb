class ApplicationController < ActionController::Base
  protect_from_forgery prepend: true, with: :exception

  before_action :set_theme_view_if_present
  before_action :show_global_announcements
  before_action :set_bg_gray
  around_action :switch_locale

  def ensure_admin
    redirect_to root_path if !current_user || !current_user.is_admin?
  end

  def set_filters_open
    @filters_open = case cookies['filters_open']
                    when 'nil'
                    when true
                    when 'true'
                      true
                    when false
                    when 'false'
                      false
                    else
                      true
    end
  end

  def hide_global_announcements
    @show_global_announcements = false
  end

  def show_global_announcements
    @show_global_announcements = true
  end

  def set_bg_gray
    @bg_color = 'bg-gray-100'
  end

  def set_bg_white
    @bg_color = 'bg-white'
  end

  def users_filtering(scope)
    params[:page] ||= 1

    @show_search_bar = true
    @show_sorting_options = true

    @users = User
    @users = @users.tagged_with(params[:skills], any: true, on: :skills) if params[:skills].present?

    @applied_filters = {}

    if params[:skills].present?
      @applied_filters[:skills] = params[:skills]
    end

    if params[:query].present?
      @users = @users.search(params[:query])
    else
      @users = @users
    end

    if scope == 'office_hours'
      users_with_office_hours = OfficeHour.where('start_at > ?', DateTime.now).select(:user_id).group(:user_id).all.collect { |oh| oh.user_id }.compact.uniq
      @users = @users.where(id: users_with_office_hours)

      @users = @users.where(id: params[:id]) if params[:id].present?
      # Make sure the owner's card is always first.
      @users = @users.order("
        CASE
          WHEN id = '#{current_user.id}' THEN '1'
        END") if current_user

      @show_filters = true unless params[:id]
    else
      @users = @users.where(visibility: true) unless current_user && current_user.is_admin?

      @show_filters = true
    end

    @users = @users.order(get_order_param) if params[:sort_by]

    @users = @users.includes(:skills).page(params[:page]).per(24)

    @index_from = (@users.prev_page || 0) * @users.limit_value + 1
    @index_to = [@index_from + @users.limit_value - 1, @users.total_count].min
    @total_count = @users.total_count
  end

  private

    def set_theme_view_if_present
      prepend_view_path "#{Rails.root.join('theme', 'views')}"

    end

    def hydrate_project_categories
      @project_categories = Settings.project_categories
      @project_locations = Settings.project_locations

      exclude_ids = []
      @project_categories.each do |category|
        exclude_ids.flatten!
        category[:featured_projects] = Rails.cache.fetch("project_category_#{category[:name].downcase}_featured_projects", expires_in: 1.hour) { Project.where(highlight: true).includes(:project_types, :skills, :categories, :volunteers).where.not(id: exclude_ids).tagged_with(category[:name], any: true, on: :categories).limit(3).order('RANDOM()') }
        exclude_ids << category[:featured_projects].map(&:id)
        # byebug
        category[:projects_count] = Rails.cache.fetch("project_category_#{category[:name].downcase}_projects_count", expires_in: 1.hour) { Project.tagged_with(category[:name], any: true, on: :categories).count }
        # byebug
      end
      @project_locations.each do |location|
        exclude_ids.flatten!
        location[:featured_projects] = Rails.cache.fetch("project_location_#{location[:name].downcase}_featured_projects", expires_in: 1.hour) { Project.where(highlight: true).includes(:project_types, :skills, :categories, :volunteers).where.not(id: exclude_ids).tagged_with(location[:name], any: true, on: :locations).limit(3).order('RANDOM()') }
        exclude_ids << location[:featured_projects].map(&:id)
        # byebug
        location[:projects_count] = Rails.cache.fetch("project_location_#{location[:name].downcase}_projects_count", expires_in: 1.hour) { Project.tagged_with(location[:name], any: true, on: :locations).count }
        # byebug
        # puts location[:projects_count]
      end
    end

    def track_event(event_name)
      session[:track_event] = event_name
    end

    def switch_locale(&action)
      locale = params[:locale] || extract_locale_from_accept_language_header || I18n.default_locale
      logger.debug "* Locale: overriding with ?locale param=#{params[:locale].inspect}" if params[:locale].present?
      logger.debug "* Locale: HTTP Accept-Language: #{extract_locale_from_accept_language_header.inspect}" if extract_locale_from_accept_language_header.present?
      logger.info "* Locale set to #{locale.inspect}"
      I18n.with_locale(locale, &action)
    end

    def extract_locale_from_accept_language_header
      return nil if request.env['HTTP_ACCEPT_LANGUAGE'].blank?
      request.env['HTTP_ACCEPT_LANGUAGE'].scan(/^[a-z]{2}/).first
    end

end
