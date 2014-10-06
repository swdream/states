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
            Quan Tong Anh <tonganhquan.net@gmail.com>
-#}
include:
  - pysc
  - raven
  - rsyslog
  - cron

/usr/bin/mail:
  file:
    - managed
    - user: root
    - group: root
    - mode: 775
    - source: salt://raven/mail/script.py
    - require:
      - module: raven
      - service: rsyslog
      - module: pysc

/usr/bin/ravenmail:
  file:
    - symlink
    - target: /usr/bin/mail
    - require:
      - file: /usr/bin/mail

cron_sendmail_patch:
  cmd:
    - run
    - name: perl -pi -e "s|/usr/sbin/sendmail|/usr/bin/ravenmail|" /usr/sbin/cron
    - unless: grep -a ravenmail /usr/sbin/cron
    - require:
      - pkg: cron
      - file: /usr/bin/ravenmail

extend:
  cron:
    service:
      - watch:
        - cmd: cron_sendmail_patch
