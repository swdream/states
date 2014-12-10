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
{%- from 'cron/test.jinja2' import test_cron with context %}
{%- from 'diamond/macro.jinja2' import diamond_process_test with context %}
include:
  - doc
  - proftpd
  - proftpd.backup
  - proftpd.backup.nrpe
  - proftpd.backup.diamond
  - proftpd.diamond
  - proftpd.nrpe

{%- call test_cron() %}
- sls: proftpd
- sls: proftpd.backup
- sls: proftpd.backup.nrpe
- sls: proftpd.backup.diamond
- sls: proftpd.diamond
- sls: proftpd.nrpe
{%- endcall %}

test:
  diamond:
    - test
    - map:
        ProcessResources:
          {{ diamond_process_test('proftpd') }}
    - require:
      - sls: proftpd
      - sls: proftpd.diamond
  monitoring:
    - run_all_checks
    - wait: 5  {# wait for proftpd create database structure #}
    - order: last
    - require:
      - cmd: test_crons
  qa:
    - test
    - name: proftpd
    - additional:
      - proftpd.backup
    - pillar_doc: {{ opts['cachedir'] }}/doc/output
    - require:
      - cmd: doc
