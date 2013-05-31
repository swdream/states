{#
 Remove Nagios NRPE check for OpenVPN
#}
{% if 'shinken_pollers' in pillar %}
include:
  - nrpe

extend:
  nagios-nrpe-server:
    service:
      - watch:
        - file: /etc/nagios/nrpe.d/openvpn.cfg
{% endif %}

/etc/nagios/nrpe.d/openvpn.cfg:
  file:
    - absent
