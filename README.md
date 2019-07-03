# Local ELK stack
This repo contains a `docker-compose.yml` file along with some related config files for running a local [ELK stack](https://www.elastic.co/elk-stack) to monitor the logs of your locally running containers. Much of this information already exists online or is available in other projects, but this repo is a record of the simplest approach I could come up with. It is not intended to be an exhaustive example or reference, but rather the simplest starting point to start interrogating logs locally.

## Usage
Simply run `docker-compose up` in this directory and navigate to `http://localhost:5601` to view Kibana. You'll need to create an index pattern for `logstash-*` in order to start viewing your logs.

> The basic config presented in this repo will ingest your logs in their raw format. If they are structured, for example as JSON, read on.

## What if my logs need parsing? e.g. they're JSON.
If your logs need parsing, this can be achieved in the `./filebeat/filebeat.yml` config or in the `./logstash/pipeline.conf` depending on which approach you'd like to take (Filebeat vs. Logstash).

If your logs are structured as JSON, the simplest thing to do is get Filebeat to parse them. An example `filebeat.yml` is as follows:

```yml

filebeat.config:
  modules:
    path: ${path.config}/modules.d/*.yml
    reload.enabled: false

filebeat.autodiscover:
  providers:
    - type: docker
      hints.enabled: true
      templates:
        - condition:
            contains:
              docker.container.image: YOUR_CONTAINER_NAME 
          config:
          - type: docker
            containers.ids:
              - "${data.docker.container.id}"
            json.keys_under_root: true
            json.add_error_key: true

output.logstash:
  hosts: 'logstash:5044'
```

> In this example, replace `YOUR_CONTAINER_NAME` with part of your container's image name. This will instruct Filebeat to only try parsing structured logs for your particular container (and avoid it trying to parse unstructured logs).

## What if my logs are not parsed correctly?
Often, Filebeat does an *alright* job of parsing your logs, but might get things like datatypes wrong. Parsing the correct datatypes (or anything else more complicated) cannot be done in Filebeat, but a simple pipeline in Logstash can be used. An example `pipeline.conf` demonstrates this:

```
input {
  beats {
    port => 5044
  }
}
filter {
  mutate {
    convert => {
      "YOUR_NUMERIC_FIELD" => "integer"
    }
  }
}
output {
  elasticsearch { hosts => ["elasticsearch:9200"] }
}
```

> In this example, the field `YOUR_NUMERIC_FIELD` in your JSON log message has been converted to an integer by Logstash.

## More information
A more detailed explanation of this repo's content can be found in its corresponding blog post, [here](http://andykuszyk.github.io/2019-07-03-local-elk.html).
