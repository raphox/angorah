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

  has_many :both, :friends, type: :FRIEND, model_class: self, labels: false, unique: true

  validates :slug, exclusion: { in: ['admin', 'root'] + RouteRecognizer.initial_path_segments }, uniqueness: true
  validates :first_name, presence: true
  validates :website, uniqueness: true, presence: true, website: true

  before_validation :set_slug

  after_save :get_website_titles

  def set_slug
    slug = first_name&.parameterize if slug.blank? || slug_changed?
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

  def friendsBySearch(term)
    byebug
    friends_path = {}
    uuids = friends(:l, :r, rel_length: { max: 5 }).
      where("ANY(title IN l.titles WHERE toLower(title) CONTAINS toLower({title}))").
      params({ title: term }).
      pluck(:uuid)

    uuids.each do |uuid|
      friends_path[uuid] = Neo4j::ActiveBase.current_session.
        query("MATCH (r:UserNeo4j { uuid: '#{self.uuid}' }),
          (l:UserNeo4j { uuid: '#{uuid}' }),
          p = shortestPath((r)-[FRIEND*..5]->(l))
          RETURN p", limit: 1).first.p.nodes.
        map { |node| User.find_by({ neo4j_uuid: node.properties[:uuid] }) }
    end

    return uuids, friends_path

    # FIXME: May it works
    # as(:user).
    #   friends(:friends).
    #   query.
    #   with('shortestPath((user)-[:FRIEND*..5]->(friends)) AS shortest_path').
    #   where("ANY(title IN friends.titles WHERE toLower(title) CONTAINS toLower({title}))").
    #   params({ title: term }).
    #   pluck(:shortest_path)
  end

  protected

  def get_website_titles
    return if skip_get_website_titles

    # The below line not working for now https://github.com/neo4jrb/activegraph/issues/1351
    # return unless changed_attributes.keys.include?('website')

    reload_titles!
  end
end
