{#- Usage of this is governed by a license that can be found in doc/license.rst -#}

{%- from 'nrpe/passive.jinja2' import passive_check with context %}
include:
  - apt.nrpe
  - nrpe
  - postgresql.server.nrpe
  - rsyslog.nrpe
  - web

{{ passive_check('proftpd') }}

extend:
  check_psql_encoding.py:
    file:
      - require:
        - file: nsca-proftpd
  /usr/lib/nagios/plugins/check_pgsql_query.py:
    file:
      - require:
        - file: nsca-proftpd
