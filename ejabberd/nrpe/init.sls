{#-
Copyright (c) 2014, Dang Tung Lam
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

1. Redistributions of source code must retain the above copyright notice, this
   list of conditions and the following disclaimer.
2. Redistributions in binary form must reproduce the above copyright notice,
   this list of conditions and the following disclaimer in the documentation
   and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

Author: Dang Tung Lam <lamdt@familug.org>
Maintainer: Dang Tung Lam <lamdt@familug.org>

NRPE check for ejabberd - XMPP Server
#}

include:
  - apt.nrpe
  - erlang.nrpe
  - nginx.nrpe
  - nrpe
  - postgresql.server.nrpe
  - ssl.nrpe

/etc/nagios/nrpe.d/ejabberd.cfg:
  file:
    - managed
    - template: jinja
    - user: nagios
    - group: nagios
    - mode: 440
    - source: salt://ejabberd/nrpe/config.jinja2
    - require:
      - pkg: nagios-nrpe-server
    - watch_in:
      - service: nagios-nrpe-server

/etc/nagios/nrpe.d/ejabberd-nginx.cfg:
  file:
    - managed
    - template: jinja
    - user: nagios
    - group: nagios
    - mode: 440
    - source: salt://nginx/nrpe/instance.jinja2
    - require:
      - pkg: nagios-nrpe-server
    - context:
      deployment: ejabberd
      domain_name: {{ pillar['ejabberd']['hostnames'][0] }}
      http_uri: /admin
{%- if salt['pillar.get']('ejabberd:ssl', False) %}
      https: True
      https_result: 401 Unauthorized
    {%- if salt['pillar.get']('ejabberd:ssl_redirect', False) %}
      http_result: 301 Moved Permanently
    {%- else %}
      http_result: 401 Unauthorized
    {%- endif -%}
{%- else %}
      http_result: 401 Unauthorized
{%- endif %}
    - watch_in:
      - service: nagios-nrpe-server

/etc/nagios/nrpe.d/postgresql-ejabberd.cfg:
  file:
    - managed
    - template: jinja
    - user: nagios
    - group: nagios
    - mode: 440
    - source: salt://postgresql/nrpe.jinja2
    - require:
      - pkg: nagios-nrpe-server
    - context:
      database: {{ salt['pillar.get']('ejabberd:db:name', 'ejabberd') }}
      username: {{ salt['pillar.get']('ejabberd:db:username', 'ejabberd') }}
      password: {{ salt['password.pillar']('ejabberd:db:password', 10) }}
    - watch_in:
      - service: nagios-nrpe-server