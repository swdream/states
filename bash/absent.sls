{#
 Remove bash customisation
 #}
/etc/profile.d/bash_prompt.sh:
  file:
    - absent

/root/.bashrc:
  file:
    - comment
    - regex: bash_prompt
