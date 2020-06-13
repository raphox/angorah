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
  validates :website, uniqueness: true, presence: true, website: true, unless: :skip_get_website_titles

  after_save :get_website_titles, unless: :skip_get_website_titles
  after_save :sync_neoj4
  after_create :clear_database
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
    return unless (changed_attributes.keys - ['updated_at']).any?

    params = attributes.slice(*%w[
      first_name
      last_name
      website
      titles
      subtitles
      introduction
    ]).merge({ 'skip_get_website_titles' => true })

    if neo4j_uuid.present?
      user = UserNeo4j.find(neo4j_uuid)
      user.update(params)
    else
      user = UserNeo4j.create(params)
      set({ neo4j_uuid: user.uuid })
    end
  end

  def destroy_neoj4
    return unless neo4j_uuid.present?

    UserNeo4j.find(neo4j_uuid).destroy rescue nil

    update({ neo4j_uuid: nil })
  end

  # preventing misuse of the application in an open environment
  def clear_database
    return if User.count <= 25

    User.destroy_all

    User::DEFAULT_USERS.each do |attributes|
      User.create(attributes)
    end
  end

  # Used as default user list on start project
  DEFAULT_USERS = [
    { first_name: 'Vinnie', last_name: 'Lintott', website: 'http://indiatimes.com', titles: [''], skip_get_website_titles: true },
    { first_name: 'Otha', last_name: 'Kunes', website: 'https://edublogs.org', titles: ['.NET'], skip_get_website_titles: true },
    { first_name: 'Dayle', last_name: 'Caswill', website: 'http://sohu.com', titles: ['C', 'C++'], skip_get_website_titles: true },
    { first_name: 'Erastus', last_name: 'Quilligan', website: 'http://skyrock.com', titles: ['Javascript', 'ASP'], skip_get_website_titles: true },
    { first_name: 'Jamal', last_name: 'Cullington', website: 'https://webmd.com', titles: ['Pascal'], skip_get_website_titles: true },
    { first_name: 'Joice', last_name: 'Brooke', website: 'http://marketwatch.com', titles: ['Python'], skip_get_website_titles: true },
    { first_name: 'Gwenni', last_name: 'Dines', website: 'http://typepad.com', titles: ['Go'], skip_get_website_titles: true },
    { first_name: 'Glyn', last_name: 'Clouter', website: 'https://google.ru', titles: ['PHP', 'Ruby'], skip_get_website_titles: true },
    { first_name: 'Lucienne', last_name: 'Ready', website: 'http://myspace.com', titles: ['Ruby'], skip_get_website_titles: true },
    { first_name: 'Katuscha', last_name: 'Tinman', website: 'http://umn.edu', titles: ['Java'], skip_get_website_titles: true },
  ]
end
