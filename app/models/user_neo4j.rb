require 'route_recognizer'

class UserNeo4j
  include Neo4j::ActiveNode
  include Neo4j::Timestamps

  property :slug
  property :first_name
  property :last_name
  property :website
  property :titles
  property :subtitles
  property :introduction

  serialize :titles, Array
  serialize :subtitles, Array

  attr_accessor :skip_get_website_titles

  has_many :out, :friends, type: :FRIEND, model_class: self, labels: false, unique: true

  validates :slug, exclusion: { in: ['admin', 'root'] + RouteRecognizer.initial_path_segments }, uniqueness: true
  validates :first_name, presence: true
  validates :website, uniqueness: true, presence: true, website: true

  before_validation :set_slug

  after_save :get_website_titles, unless: :skip_get_website_titles

  def set_slug
    slug = first_name.parameterize
  end

  def full_name
    [first_name, last_name].join(' ')
  end

  def references
    (titles.to_a + subtitles.to_a).uniq
  end

  def reload_titles!
    # TODO: Use async_perform with Sidekiq
    WebsiteScrapperWorker.new.perform(uuid, self.class)
  end

  protected

  def get_website_titles
    # The below line not working for now
    # return unless changed_attributes.keys.include?('website')

    reload_titles!
  end
end
