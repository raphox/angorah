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
