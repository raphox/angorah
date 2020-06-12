require 'route_recognizer'

class User
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Slug

  field :first_name, type: String
  field :last_name, type: String
  field :website, type: String
  field :titles, type: Array
  field :subtitles, type: Array
  field :introduction, type: String
  field :neo4j_uuid, type: String

  attr_accessor :skip_get_website_titles

  slug :first_name, reserve: ['admin', 'root'] + RouteRecognizer.initial_path_segments

  validates :first_name, presence: true
  validates :website, uniqueness: true, presence: true, website: true

  after_save :get_website_titles, unless: :skip_get_website_titles
  after_save :sync_neoj4
  before_destroy :destroy_neoj4

  def full_name
    [first_name, last_name].join(' ')
  end

  def references
    (titles.to_a + subtitles.to_a).uniq
  end

  def reload_titles!
    # TODO: Use async_perform with Sidekiq
    WebsiteScrapperWorker.new.perform(id)
  end

  protected

  def get_website_titles
    return unless changed_attributes.keys.include?('website')

    reload_titles!
  end

  def sync_neoj4
    return unless changed_attributes.present?

    params = attributes.slice(
      :first_name,
      :last_name,
      :website,
      :titles,
      :subtitles,
      :introduction
    )

    if neo4j_uuid.present?
      user = UserNeo4j.find(neo4j_uuid)
      user.update(params)
    else
      user = UserNeo4j.create(params)
      update({ neo4j_uuid: user.uuid })
    end
  end

  def destroy_neoj4
    UserNeo4j.find(neo4j_uuid).destroy
  end
end
