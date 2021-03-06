{#- Usage of this is governed by a license that can be found in doc/license.rst -#}

include:
  - apt
  - rsyslog

/etc/network/iptables.conf:
  file:
    - absent

{%- set allowed_protocols = salt['pillar.get']('firewall:allowed_protocols', ['icmp']) -%}
{%- if 'icmp' not in allowed_protocols -%}
  {%- do allowed_protocols.append('icmp') -%}
{%- endif %}

iptables:
  file:
    - managed
    - name: /etc/iptables/rules.v4
    - template: jinja
    - user: root
    - group: root
    - mode: 440
    - source: salt://firewall/config.jinja2
    - context:
        ip_addrs_key: ip_addrs
        allowed_protocols: {{ allowed_protocols }}
        allowed_ips: {{ salt['pillar.get']('firewall:allowed_ips', []) }}
        filter: {{ salt['pillar.get']('firewall:filter', {}) }}
        blacklist: {{ salt['pillar.get']('firewall:blacklist', []) }}
    - require:
      - pkg: iptables
  pkg:
    - installed
    - pkgs:
      - iptables
      - iptstate
      - iptables-persistent
    - require:
      - cmd: apt_sources
  cmd:
    - wait
    - name: iptables-restore < /etc/iptables/rules.v4
    - stateful: False
    - watch:
      - file: iptables

{%- set allowed_protocol6s = salt['pillar.get']('firewall:allowed_protocol6s', ['icmpv6']) -%}
{%- if 'icmpv6' not in allowed_protocol6s -%}
  {%- do allowed_protocol6s.append('icmpv6') -%}
{%- endif %}

ip6tables:
  file:
    - managed
    - name: /etc/iptables/rules.v6
    - template: jinja
    - user: root
    - group: root
    - mode: 440
    - source: salt://firewall/config.jinja2
    - context:
        ip_addrs_key: ip_addrs6
        allowed_protocols: {{ allowed_protocol6s }}
        allowed_ips: {{ salt['pillar.get']('firewall:allowed_ip6s', []) }}
        filter: {{ salt['pillar.get']('firewall:filter6', {}) }}
        blacklist: {{ salt['pillar.get']('firewall:blacklist6', []) }}
    - require:
      - pkg: iptables
  cmd:
    - wait
    - name: ip6tables-restore < /etc/iptables/rules.v6
    - stateful: False
    - watch:
      - file: ip6tables

{% if grains['virtual'] != 'openvzve' %}
firewall_nf_conntrack:
  kmod:
    - present
    - name: nf_conntrack

  {% if salt['pillar.get']('firewall:filter', {})|length > 0 and 21 in salt['pillar.get']('firewall:filter:tcp', []) %}
nf_conntrack_ftp:
   kmod:
     - present
     - require:
       - kmod: firewall_nf_conntrack
  {% endif %}
{% endif %}

/etc/rsyslog.d/firewall.conf:
  file:
    - managed
    - source: salt://firewall/rsyslog.jinja2
    - template: jinja
    - mode: 440
    - user: root
    - group: root
    - require:
      - pkg: rsyslog
    - watch_in:
      - service: rsyslog
