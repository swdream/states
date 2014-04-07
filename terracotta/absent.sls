{#-
Copyright (c) 2013, Hung Nguyen Viet
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

Author: Hung Nguyen Viet <hvnsweeting@gmail.com>
Maintainer: Hung Nguyen Viet <hvnsweeting@gmail.com>
-#}
{% set version = '3.7.0' %}
terracotta:
  file:
    - absent
    - name: /etc/init/terracotta.conf
    - require:
      - service: terracotta
  service:
    - dead
    - order: first
  user:
    - absent
    - require:
      - service: terracotta

/usr/local/terracotta-{{ version }}:
  file:
    - absent
    - name: /usr/local/terracotta-{{ version }}
    - require:
      - service: terracotta

/etc/terracotta.conf:
  file:
    - absent
    - require:
      - service: terracotta

/var/lib/terracotta:
  file:
    - absent
    - require:
      - service: terracotta

/var/log/terracotta:
  file:
    - absent
    - require:
      - service: terracotta

terracotta-upstart-log:
  cmd:
    - run
    - name: find /var/log/upstart/ -maxdepth 1 -type f -name 'terracotta.log*' -delete
    - require:
      - service: terracotta

/etc/rsyslog.d/terracotta-upstart.conf:
  file:
    - absent
