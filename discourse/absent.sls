{#-
Uninstall Discourse
#}

{%- set web_root_dir = "/usr/local/discourse" %}

discourse:
  user:
    - absent
    - force: True
  group:
    - absent
    - require:
      - user: discourse

{%- for file in (web_root_dir, '/home/discourse', '/etc/uwsgi/discourse.ini', '/etc/nginx/conf.d/discourse.conf', '/etc/logrotate.d/discourse', '/etc/init/discourse.conf', '/var/log/sidekiq.log') %}
{{ file }}:
  file:
    - absent
{%- endfor %}
