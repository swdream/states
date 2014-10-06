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

Author: Bruno Clermont <patate@fastmail.cn>
Maintainer: Bruno Clermont <patate@fastmail.cn>
-#}
include:
  - nrpe
  - backup.client.base.nrpe
  - bash.nrpe
  - virtualenv.nrpe

/etc/nagios/backup.yml:
  file:
    - managed
    - template: jinja
    - source: salt://backup/client/s3/nrpe/config.jinja2
    - user: nagios
    - group: nagios
    - mode: 440
    - require:
      - pkg: nagios-nrpe-server

backup_client_nrpe-requirements:
  file:
    - managed
    - name: /usr/local/nagios/backup.client.s3.nrpe-requirements.txt
    - template: jinja
    - user: root
    - group: root
    - mode: 440
    - source: salt://backup/client/s3/nrpe/requirements.jinja2
    - require:
      - virtualenv: nrpe-virtualenv
  module:
    - wait
    - name: pip.install
    - upgrade: True
    - bin_env: /usr/local/nagios
    - requirements: /usr/local/nagios/backup.client.s3.nrpe-requirements.txt
    - require:
      - virtualenv: nrpe-virtualenv
    - watch:
      - file: backup_client_nrpe-requirements

check_backup.py:
  file:
    - managed
    - name: /usr/lib/nagios/plugins/check_backup.py
    - source: salt://backup/client/s3/nrpe/check.py
    - user: nagios
    - group: nagios
    - mode: 550
    - require:
      - file: /etc/nagios/backup.yml
      - file: /usr/local/nagios/lib/python2.7/check_backup_base.py
      - pkg: nagios-nrpe-server
      - module: backup_client_nrpe-requirements

{#- use this file instead of using /etc/s3lite.yml because it needs another
    process name - for bfs config #}
/etc/nagios/s3lite.yml:
  file:
    - managed
    - template: jinja
    - source: salt://backup/client/s3/s3lite/nrpe/check_config.jinja2
    - user: nagios
    - group: nagios
    - mode: 440
    - require:
      - pkg: nagios-nrpe-server

/usr/lib/nagios/plugins/check_backup_s3lite.py:
  file:
    - managed
    - source: salt://backup/client/s3/s3lite/nrpe/check_s3lite.py
    - user: nagios
    - group: nagios
    - mode: 550
    - require:
      - file: /etc/nagios/s3lite.yml
      - pkg: nagios-nrpe-server
      - module: nrpe-virtualenv
