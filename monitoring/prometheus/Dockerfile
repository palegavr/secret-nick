FROM prom/prometheus:latest

COPY prometheus.yml /etc/prometheus/prometheus.yml

VOLUME [ "/prometheus" ]

EXPOSE 9090


CMD [ "--config.file=/etc/prometheus/prometheus.yml", "--storage.tsdb.path=/prometheus", "--web.route-prefix=/prometheus", "--web.external-url=/prometheus"]