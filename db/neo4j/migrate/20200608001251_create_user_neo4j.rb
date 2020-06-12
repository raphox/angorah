class CreateUserNeo4j < Neo4j::Migrations::Base
  def up
    add_constraint :UserNeo4j, :uuid
  end

  def down
    drop_constraint :UserNeo4j, :uuid
  end
end
