class User
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Slug

  field :name, type: String
  field :website, type: String
  field :website_data_collection, type: Hash

  slug :name, reserve: ['users', 'admin', 'root']

  validates :name, uniqueness: true, presence: true
  validates :website, presence: true

  def shortest_path_to(name)
    query = Arango::AQL.new({
      database: $arangodb,
      query: "FOR v, e IN OUTBOUND
        SHORTEST_PATH 'persons/eve' TO 'persons/dave'
        GRAPH 'knows_graph'
        RETURN [v._key, e._key]"
    })

    result = query.execute
    result[:result].map(&:first).join(' -> ')
  end
end
