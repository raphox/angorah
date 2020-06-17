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
  property :slug

  serialize :titles, Array
  serialize :subtitles, Array

  attr_accessor :skip_load_website_titles

  has_many :out, :friends, type: :FRIEND, model_class: self, labels: false, unique: true

  validates :slug, exclusion: { in: %w[admin root] + RouteRecognizer.initial_path_segments }, uniqueness: true
  validates :first_name, presence: true
  validates :website, uniqueness: true, presence: true, website: true

  before_validation :set_slug

  after_save :load_website_titles

  def set_slug
    self.slug = first_name&.parameterize if slug.blank? || slug_changed?
  end

  def full_name
    [first_name, last_name].join(' ')
  end

  def references
    (titles.to_a + subtitles.to_a).uniq
  end

  def reload_titles!
    return unless persisted?

    # TODO: Use async_perform with Sidekiq
    WebsiteScrapperWorker.new.perform(uuid, self.class)
  end

  def friends_by_search(term)
    friends_path = {}

    friends = as(:user).friends(:l, :r, rel_length: { max: 5 }).
      where('ANY(title IN l.titles WHERE toLower(title) CONTAINS toLower({title})) OR
        ANY(subtitle IN l.subtitles WHERE toLower(subtitle) CONTAINS toLower({title}))').
      where('l <> user').
      params({ title: term }).
      to_a

    # TODO: Use only one query to get users and shortest paths
    friends.each do |friend|
      friends_path[friend.uuid] = Neo4j::ActiveBase.current_session.
        query("MATCH (r:UserNeo4j { uuid: '#{uuid}' }),
          (l:UserNeo4j { uuid: '#{friend.uuid}' }),
          p = shortestPath((r)-[FRIEND*..5]->(l))
          RETURN p", limit: 1).first.p.nodes
    end

    # TODO: Use only queries to generate order
    friends.sort_by! do |item|
      total = 0

      total += (friends_path[item.uuid].length - 2) * 10
      total += item.titles.any? { titles.include?(term) } ? -10 : 0
      total += item.subtitles.any? { |subtitle| subtitle.include?(term) } ? -5 : 0

      total
    end

    [friends, friends_path]
  end

  def invite(uuid)
    friend_a = self
    friend_b = UserNeo4j.find(uuid)

    if friend_a.friends(rel_length: 1).where({ uuid: friend_b.uuid }).present?
      friend_a.friends.delete(friend_b)
      friend_b.friends.delete(friend_a)
    else
      friend_a.friends << friend_b
      friend_b.friends << friend_a
    end
  end

  protected

  def load_website_titles
    return if skip_load_website_titles

    # The below line not working for now https://github.com/neo4jrb/activegraph/issues/1351
    # return unless changed_attributes.keys.include?('website')

    reload_titles!
  end
end
