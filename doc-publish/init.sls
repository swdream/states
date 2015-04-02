{#- Usage of this is governed by a license that can be found in doc/license.rst -#}

{%- set ssl = salt['pillar.get']('doc:ssl', False) %}
{%- set ssl_redirect = salt['pillar.get']('doc:ssl_redirect', False) %}
{%- set is_test = salt['pillar.get']('__test__', False) %}
{%- set hostnames = salt['pillar.get']('doc:hostnames') %}
include:
  - cron
  - doc
  - local
  - nginx
  - python
  - pysc
{%- if ssl %}
  - ssl
{%- endif %}

/usr/local/salt-common-doc:
  file:
    - directory
    - user: root
    - group: www-data
    - mode: 750
    - require:
      - file: /usr/local
      - user: web

/etc/doc-publish.yml:
  file:
    - managed
    - template: jinja
    - source: salt://doc-publish/config.jinja2
    - user: root
    - group: root
    - mode: 400
    - context:
{%- if opts['file_client'] == 'local' %}
  {%- set cwd = opts['file_roots'][opts['file_roots'].keys()[0]][0] %}
{%- else -%}
    {%- set saltenv = salt['common.saltenv']() %}
  {%- set cwd = opts['cachedir'] ~ "/files/" ~  saltenv %}
{%- endif %}
{%- if is_test %}
        minion_config_file: /root/salt/states/test/minion
{%- endif %}
        cwd: {{ cwd }}
        output: /usr/local/salt-common-doc
        saltenv: {{ salt['common.saltenv']() }}
        virtualenv: {{ opts['cachedir'] }}/doc

doc-publish:
  file:
    - managed
    - name: /etc/cron.hourly/doc-publish
    - source: salt://doc-publish/build.py
    - user: root
    - group: root
    - mode: 500
    - require:
      - cmd: doc
      - file: /usr/local/salt-common-doc
      - file: /etc/doc-publish.yml
      - module: pysc
      - pkg: cron
  cmd:
    - wait
    - name: /etc/cron.hourly/doc-publish
    - watch:
      - file: /etc/cron.hourly/doc-publish
      - file: doc-publish

/etc/nginx/conf.d/salt-doc.conf:
  file:
    - managed
    - source: salt://doc-publish/nginx.jinja2
    - template: jinja
    - user: root
    - group: www-data
    - mode: 440
    - require:
      - pkg: nginx
      - user: web
      - cmd: doc-publish
{%- if ssl %}
      - cmd: ssl_cert_and_key_for_{{ ssl }}
{%- endif %}
    - watch_in:
      - service: nginx
    - context:
        hostnames: {{ hostnames }}
        ssl: {{ ssl }}
        ssl_redirect: {{ ssl_redirect }}

{%- if ssl %}
extend:
  nginx.conf:
    file:
      - context:
          ssl: {{ ssl }}
  nginx:
    service:
      - watch:
        - cmd: ssl_cert_and_key_for_{{ ssl }}
{%- endif %}