{#
 Install a Graylog2 logging server backend
 #}
include:
  - graylog2
  - mongodb
  - apt

{# TODO: set Email output plugin settings straight into MongoDB from salt #}

{% set version = '0.11.0' %}
{% set checksum = 'md5=135c9eb384a03839e6f2eca82fd03502' %}
{% set server_root_dir = '/usr/local/graylog2-server-' + version %}

graylog2-server_upstart:
  file:
    - managed
    - name: /etc/init/graylog2-server.conf
    - template: jinja
    - user: root
    - group: root
    - mode: 600
    - source: salt://graylog2/server/upstart.jinja2
    - context: 
      version: {{ version }}

{#graylog2-server_logrotate:#}
{#  file:#}
{#    - managed#}
{#    - name: /etc/logrotate.d/graylog2-server#}
{#    - template: jinja#}
{#    - user: root#}
{#    - group: root#}
{#    - mode: 600#}
{#    - source: salt://graylog2/server/logrotate.jinja2#}

{# For cluster using, all node's data should be explicit: http,master,data,port and/or name #}
/etc/graylog2-elasticsearch.yml:
  file:
    - managed
    - source: salt://elasticsearch/config.jinja2
    - template: jinja
    - user: root
    - group: root
    - mode: 440
    - context:
      master: 'false'
      data: 'false'
{#
 Graylog2 documentation says that the http interface should be turned off in the
 built-in Elasticsearch instance.
 But, until that we have multiple graylog2 server, we won't do that.
      http: 'false'
#}

graylog2-server:
  archive:
    - extracted
    - name: /usr/local/
    - source: http://download.graylog2.org/graylog2-server/graylog2-server-{{ version }}.tar.gz
    - source_hash: {{ checksum }}
    - archive_format: tar
    - tar_options: z
    - if_missing: {{ server_root_dir }}
  file:
    - managed
    - name: /etc/graylog2.conf
    - template: jinja
    - user: root
    - group: root
    - mode: 440
    - source: salt://graylog2/server/config.jinja2
    - context: 
      version: {{ version }}
  pkg:
    - latest
    - name: openjdk-7-jre-headless
    - require:
      - cmd: apt_sources
{#
 IMPORTANT:
 graylog2-server need to be restarted after any change in
 mail output plugin settings.
#}
  service:
    - running
    - enable: True
    - watch:
      - file: graylog2-server_upstart
      - pkg: graylog2-server
      - file: graylog2-server
      - file: /etc/graylog2-elasticsearch.yml
      - archive: graylog2-server
      - cmd: graylog2_email_output_plugin
    - require:
      - file: /var/log/graylog2
      - service: mongodb

graylog2_email_output_plugin:
  cmd:
    - run
    - name: java -jar graylog2-server.jar --install-plugin email_output --plugin-version 0.10.0
    - cwd: {{ server_root_dir }}
    - unless: test -e {{ server_root_dir }}/plugin/outputs/org.graylog2.emailoutput.output.EmailOutput_gl2plugin.jar
    - require:
      - archive: graylog2-server
      - pkg: graylog2-server
      - service: mongodb
