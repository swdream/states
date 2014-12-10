{#-
Copyright (c) 2013, Bruno Clermont
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

Author: Bruno Clermont <bruno@robotinfra.com>
Maintainer: Viet Hung Nguyen <hvn@robotinfra.com>
-#}
include:
  - apt
  - rsyslog

{% if salt['pillar.get']('ntp:servers', []) | length > 0 %}
ntpdate:
  pkg:
    - installed
    - require:
      - cmd: apt_sources
  file:
    - managed
    - name: /etc/default/ntpdate
    - template: jinja
    - source: salt://ntp/ntpdate.jinja2
    - user: root
    - group: root
    - mode: 440
    - require:
      - pkg: ntpdate
{% endif %}

ntp:
  pkg:
    - installed
    - require:
      - cmd: apt_sources
  user:
    - present
    - shell: /bin/false
    - require:
      - pkg: ntp
  file:
    - managed
    - name: /etc/ntp.conf
    - template: jinja
    - source: salt://ntp/config.jinja2
    - user: root
    - group: root
    - mode: 440
    - require:
      - pkg: ntp
  service:
    - running
    - enable: True
    - order: 50
    - require:
      - pkg: ntp
      - service: rsyslog
    - watch:
      - file: ntp
      - user: ntp
{#- PID file owned by root, no need to manage #}
