FROM docker.elastic.co/logstash/logstash:7.2.0
COPY pipeline.conf /usr/share/logstash/pipeline/pipeline.conf
COPY entrypoint.sh ./entrypoint.sh
CMD ./entrypoint.sh
