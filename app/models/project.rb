class Project < ApplicationRecord
  include HasCoverPhoto
  include PgSearch::Model

  belongs_to :user

  validates :name, presence: true
  validates :short_description, length: { maximum: 129 }
  validate :must_have_one_skill, on: :create
  validate :date_order, on: :create

  has_many :volunteers, dependent: :destroy
  has_many :volunteered_users, through: :volunteers, source: :user, dependent: :destroy

  acts_as_taggable_on :skills
  acts_as_taggable_on :categories
  acts_as_taggable_on :project_types
  acts_as_taggable_on :locations
  acts_as_taggable_on :completions

  pg_search_scope :search, against: %i(name description participants looking_for volunteer_location target_country target_location highlight)

  after_save do
    # expire homepage caches if they contain this project
    Settings.project_categories.each do |category|
      cache_key = "project_category_#{category[:name].downcase}_featured_projects"
      featured_projects = Rails.cache.read cache_key

      next if featured_projects.blank?

      Rails.cache.delete(cache_key) if featured_projects.map(&:id).include? self.id
    end
  end

  validates :status, inclusion: { in: Settings.project_statuses }

  before_validation :default_values

  def default_values
    self.status = Settings.project_statuses.first if self.status.blank?
  end

  def to_param
    [id, name.parameterize].join('-')
  end

  def can_edit?(edit_user)
    edit_user && (self.user == edit_user || edit_user.is_admin?)
  end

  def volunteer_emails
    self.volunteered_users.collect { |u| u.email }
  end

  def volunteered_users_count
    volunteered_users.count
  end

  def serializable_hash(options = {})
    super(
      only: [
        :id,
        :name,
        :description,
        :participants,
        :goal,
        :looking_for,
        :volunteer_location,
        :target_country,
        :target_location,
        :contact,
        :highlight,
        :progress,
        :docs_and_demo,
        :number_of_volunteers,
        :accepting_volunteers,
        :created_at,
        :updated_at,
        :status,
        :short_description
      ],
      methods: [:to_param, :volunteered_users_count, :project_type_list, :location_list, :category_list, :skill_list]
    )
  end

  def must_have_one_skill
    errors.add(:base, 'You must select at least one skill') if self.skill_list.all?{|skill| skill.blank? }    
  end

  def date_order
    if self.end_date_recurring != true
      if self.end_date != ''
        errors.add(:base, 'End date must be after start date') if Date.parse(self.start_date) > Date.parse(self.end_date)
      elsif self.end_date == ''
        errors.add(:base, 'You must provide an end date or select "Recurring"')
      end 
    end
  end

  def category
    project_categories = {}
    begin
      Settings.project_categories.each do |category|
        intersection = self.project_type_list.to_a & category['project_types'].to_a
        project_categories[category.name] = intersection.count
      end

      present_category = project_categories.sort_by { |k, v| v }.reverse.first.first
    end

    present_category
  end

  def cover_photo(category_override = nil)
    Rails.cache.fetch(cdn_image_cache_key, expires_in: 1.month) do

      if self.image.present?
        cdn_variant(resize_to_limit: [600, 600])
      else
        # FIXME use slug of category instead? and fallback if this is missing
        filename = category_override.blank? ? self.category.downcase.gsub(' ', '-') : category_override.downcase

        # There is no `image_pack_path` -- see https://github.com/rails/webpacker/issues/2562
        ActionController::Base.helpers.asset_pack_path "media/images/#{filename}-default.png"
      end
    end
  end

  def self.get_featured_projects
    projects_count = Settings.homepage_featured_projects_count
    Project.where(highlight: true).includes(:project_types, :categories, :locations, :skills, :volunteers).limit(projects_count).order('RANDOM()')
  end
end
