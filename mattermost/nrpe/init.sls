{#- Usage of this is governed by a license that can be found in doc/license.rst -#}

{%- from 'nrpe/passive.jinja2' import passive_check with context %}
include:
  - nginx.nrpe
  - postgresql.server.nrpe
{%- if salt['pillar.get']('mattermost:ssl', False) %}
  - ssl.nrpe
{%- endif %}

{{ passive_check('mattermost') }}
