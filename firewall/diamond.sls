{#-
Copyright (c) 2014, Hung Nguyen Viet
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

Author: Viet Hung Nguyen <hvn@robotinfra.com>
Maintainer: Viet Hung Nguyen <hvn@robotinfra.com>
-#}
{% if grains['virtual'] != 'openvzve' %}
include:
  - diamond
  - firewall
  - rsyslog.diamond

firewall_nf_conntrack_diamond_collector:
  file:
    - managed
    - name: /etc/diamond/collectors/ConnTrackCollector.conf
    - contents: |
        # {{ salt['pillar.get']('message_do_not_modify') }}

        enabled = True
        dir = /proc/sys/net/netfilter
        files = nf_conntrack_count,nf_conntrack_max
    - require:
      - file: /etc/diamond/collectors
      - kmod: firewall_nf_conntrack
    - watch_in:
      - service: diamond
{% endif %}
