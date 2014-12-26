{#-
Use of this source code is governed by a BSD license that can be found
in the doc/license.rst file.

-#}
rsyslog:
  pkg:
    - purged
    - require:
      - service: rsyslog
  file:
    - absent
    - name: /etc/rsyslog.conf
    - require:
      - pkg: rsyslog
  service:
    - dead
  cmd:
    - run
    - name: 'apt-key del 431533D8'
    - onlyif: apt-key list | grep -q 431533D8
  pkgrepo:
    - absent
{%- set files_archive = salt['pillar.get']('files_archive', False) %}
{%- if files_archive %}
    - name: deb {{ files_archive|replace('https://', 'http://') }}/mirror/rsyslog/7.4.4 {{ grains['lsb_distrib_codename'] }} main
{%- else %}
    - ppa: tmortensen/rsyslogv7
{%- endif %}

/etc/apt/sources.list.d/tmortensen-rsyslogv7-{{ grains['oscodename'] }}.list:
  file:
    - absent
    - require:
      - pkgrepo: rsyslog

/etc/rsyslog.d:
  file:
    - absent
    - require:
      - service: rsyslog

/etc/apt/sources.list.d/rsyslogv7.list:
  file:
    - absent

/var/spool/rsyslog:
  file:
    - absent
    - require:
      - pkg: rsyslog

/var/log/lastlog:
  file:
    - absent
    - require:
      - pkg: rsyslog

rsyslog_absent_mail_logs:
  cmd:
    - run
    - name: rm -f /var/log/mail.*
    - require:
      - service: rsyslog
