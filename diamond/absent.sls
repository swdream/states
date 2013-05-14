{#
 Uninstall diamond
#}

diamond:
  service:
    - dead

{% for filename in ('/etc/diamond', '/usr/local/diamond', '/etc/init/diamond.conf', '/var/log/upstart/diamond.log') %}
{{ filename }}:
  file:
    - absent
    - require:
      - service: diamond
{% endfor %}
