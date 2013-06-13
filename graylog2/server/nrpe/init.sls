{#
 Nagios NRPE check for Graylog2 Server
#}
include:
  - nrpe
  - elasticsearch.nrpe
  - mongodb.nrpe
  - apt.nrpe

{% set version = '0.11.0' %}

/usr/lib/nagios/plugins/check_new_logs.py:
  file:
    - managed
    - source: salt://graylog2/server/nrpe/check.py
    - user: nagios
    - group: nagios
    - mode: 550
    - require:
      - module: nrpe-virtualenv
      - module: pyelasticsearch
      - pkg: nagios-nrpe-server

/etc/nagios/nrpe.d/graylog2-server.cfg:
  file:
    - managed
    - template: jinja
    - user: nagios
    - group: nagios
    - mode: 440
    - source: salt://graylog2/server/nrpe/config.jinja2
    - require:
      - pkg: nagios-nrpe-server
    - context:
      version: {{ version }}

extend:
  nagios-nrpe-server:
    service:
      - watch:
        - file: /etc/nagios/nrpe.d/graylog2-server.cfg
  /etc/nagios/nrpe.d/elasticsearch.cfg:
    context:
      origin_state: graylog2
