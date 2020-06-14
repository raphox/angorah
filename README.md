# README

This README would normally document whatever steps are necessary to get the
application up and running.

Things you may want to cover:

* Ruby version

* System dependencies

* Configuration

* Database creation

* Database initialization

* How to run the test suite

* Services (job queues, cache servers, search engines, etc.)

* Deployment instructions

* ...

## Debugging with `byebug`

## Docker compos config

```yaml
app:
  tty: true
  stdin_open: true
```

This also makes it possible to after the containers are up do docker attach project_app_1 which seems to work fine.

https://github.com/docker/compose/issues/423#issuecomment-141995398

## Neo4j

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
