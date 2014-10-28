{#-
Copyright (c) 2014, Quan Tong Anh
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

Author: Quan Tong Anh <quanta@robotinfra.com>
Maintainer: Quan Tong Anh <quanta@robotinfra.com>

Install a dummy package, then remove it and expect a HALF INSTALLED after checking
-#}
include:
  - apt
  - apt.nrpe

install_screen:
  pkg:
    - installed
    - name: screen
    - require:
      - cmd: apt_sources

remove_screen:
  pkg:
    - removed
    - name: screen
    - require:
      - pkg: install_screen

apt_rc:
  monitoring:
    - run_check
    - accepted_failure: 'HALFINSTALLED CRITICAL'
    - require:
      - file: /usr/lib/nagios/plugins/check_apt-rc.py
      - pkg: remove_screen
  pkg:
    - purged
    - name: screen
    - require:
      - monitoring: apt_rc
    - require_in:
      - monitoring: test

test:
  monitoring:
    - run_all_checks
    - order: last