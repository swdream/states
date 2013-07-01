{#
 Install Mercurial source control management client.
 #}
include:
  - pip

mercurial:
  pkg:
    - purged
    - name: mercurial-common
  file:
    - managed
    - name: {{ opts['cachedir'] }}/salt-mercurial-requirements.txt
    - source: salt://mercurial/requirements.jinja2
    - template: jinja
    - user: root
    - group: root
    - mode: 440
  module:
    - wait
    - name: pip.install
    - requirements: {{ opts['cachedir'] }}/salt-mercurial-requirements.txt
    - watch:
      - file: mercurial
    - require:
      - module: pip

/etc/apt/sources.list.d/mercurial-ppa-releases-precise.list:
  file:
    - absent

/etc/apt/sources.list.d/mercurial-ppa-releases-precise.list.save:
  file:
    - absent
