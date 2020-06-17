# Angora

## Dependencies

* Docker https://docs.docker.com
* Docker Compose https://docs.docker.com/compose/

## Running

Run the below code:

```
docker-compose up web
```

## Setup

You need execute migrations to neo4j and populate database with default test data to see the system works.

```
docker-compose run web rails neo4j:migrate RAILS_ENV=development
docker-compose run web rake db:seed
```

## Testing

Run the below code:

```
docker-compose run web rails test
```

## Debugging with `byebug` inside the Docker

```yaml
app:
  tty: true
  stdin_open: true
```

This also makes it possible to after the containers are up do `docker attach angorah_web_1` which seems to work fine.

https://github.com/docker/compose/issues/423#issuecomment-141995398

## Neo4j tips

### Removing data

Removing nodes:

```
MATCH (n { first_name: 'Raphael' })
DETACH DELETE n
```

Removing relations:

```
MATCH (Raphael)-[r:FRIEND]->(It)
DELETE r
```

Removing constraint:

```
DROP UserNeo4j
```

## TODO

* Use async_perform with Sidekiq https://github.com/raphox/angorah/blob/08ac2baa10afc036ae9b2478708cc535d1b8a2bc/app/models/user_neo4j.rb#L46
* Use only one query to get users and shortest paths https://github.com/raphox/angorah/blob/08ac2baa10afc036ae9b2478708cc535d1b8a2bc/app/models/user_neo4j.rb#L60
* Use only queries to generate order https://github.com/raphox/angorah/blob/08ac2baa10afc036ae9b2478708cc535d1b8a2bc/app/models/user_neo4j.rb#L69
* Implement worker with sidekiq https://github.com/raphox/angorah/blob/16b3b9e6309b8d33edc2fd82560a7bb242aef107/app/workers/website_scrapper_worker.rb#L3
