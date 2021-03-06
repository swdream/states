New Formula Guidelines
======================

Terminology
-----------

- Formula is a collection of SLS files, which often locate inside the same
  directory. Formula is used to provide a software and all supported
  integration (:doc:`/nrpe/doc/index`, :doc:`/diamond/doc/index`).
- SLS (stands for SaLt State file) is a file that ends with ``.sls`` extension.
  Which often consists of multiple states.
- State is a salt-state, which is a representation of the state that a system
  should be in.
- State module is a python module, which is responsible for system will be
  in the declared state. For example, ``file`` state module is a
  `python module <https://github.com/saltstack/salt/blob/develop/salt/states/file.py>`_
  or ``/usr/share/pyshared/salt/states/file.py`` on Ubuntu OS. It is
  responsible for a file will be managed, with user/group and mode set to
  what user declared in his state.

PIP
---

all packages installed by ``pip`` must be specified version number

Good::

  MySQL-python==1.2.4

Bad::

  MySQL-python

Requirements file should be ``file.managed`` and have ``pip.install`` module
run only if they're changed.

If the Python environment destination is the root (``/usr/local``), it's
filename should be ``{{ opts['cachedir'] }}/pip/$statename``.
If it's in a virtualenv it should be ``/usr/local/$venv/salt-requirements.txt``.

When upgrade a software by pip to newer version, remember to also upgrade
its dependencies to the versions that the software required.

States
------

Each ``init.sls`` should have its counter-part ``absent.sls`` . That means:

* if a formula has ``mysql/server/init.sls``, it should have
  ``mysql/server/absent.sls``
* absent state must contain some state IDs like in ``init.sls`` ,
  if one includes both ``init.sls`` and ``absent.sls`` of a formula into
  a SLS, it will cause conflict and formula writer will easy to detect that
  (one will never want both to install a software and remove it).

Use only standard style to write state.

Good::

  mysql-server:
    pkg:
      - installed

Bad::

  mysql-server:
    pkg.installed

States should be group together if it makes sense:

Good::

  mysql-server:
    pkg:
      - installed
    service:
      - running
      - name: mysql
      - require:
        - pkg: mysql-server

Not so good::

  mysql-server:
    pkg:
      - installed

  mysql-service:
    service:
      - running
      - name: mysql
      - require:
        - pkg: mysql-server

``pkg`` state module
~~~~~~~~~~~~~~~~~~~~

Whenever you install a package using ``pkg`` state module, check if there is an
user created. Then please make sure that the shell of that user is
``/usr/sbin/nologin`` instead of leaving it as default (for e.g, ``/bin/sh``).
And ensuring that service run by this user will watch it::

  dovecot-agent:
    user:
      - present
      - shell: /usr/sbin/nologin
      - groups:
        - mail
      - watch_in:
        - service: dovecot

StateID
~~~~~~~

* StateID must not contain space. A
  `cmd.run <http://docs.saltstack.com/en/latest/ref/states/all/salt.states.cmd.html#salt.states.cmd.run>`_
  should having ``- name`` argument
  to provide its command instead of put the command in StateID.

Bad::

  nginx --version:
    cmd:
      - run

Good::

  nginx_check_version:
    cmd:
      - run
      - name: nginx --version

* Do not mix ``-`` and ``_`` in StateID
* Do not use too generic StateID, it will be easy to conflict.
  A convention to avoid ID conflicting problem is prefix stateID with formula
  name.
* Try to avoid absolute path to filename such as
  ``/usr/local/myapp-1/script.sh``
  or very specific one such as ``/etc/daemon-x/config-1.0.1.conf``. Hide the
  real ``name`` or ``path`` in argument key in state definition. This make
  refactor a lot easier and improve readability.

  This also can help you to avoid getting a `Recursive requisite found
  <https://github.com/saltstack/salt/issues/5667>`_ error if there are two
  states that use the same name and one require another.

Extend
~~~~~~

Each entity (file, user, ...) must be managed by only one state. Any
modification must be done by
`extend <https://salt.readthedocs.org/en/latest/topics/tutorials/starting_states.html#extending-included-sls-data>`_.
Because having multiple states manage one entity will cause conflict change,
make the state of that entity indeterminable.

Grains
------

States should use grains when possible:

Good::

  file:
    - absent
    - name: /etc/apt/sources.list.d/saltstack-salt-{{ grains['lsb_distrib_release'] }}.list

Bad::

  file:
    - absent
    - name: /etc/apt/sources.list.d/saltstack-salt-precise.list


Pillar
------

All user data must be embedded to SLS configuration file using pillar:

Good optional pillar::

   bind: {{ salt['pillar.get']('mysql:bind', '127.0.0.1') }}

Bad::

   bind: 127.0.0.1

Good required pillar key::

   bind: {{ salt['pillar.get']('mysql:bind') }}

Bad mandatory pillar key::

   bind: {{ salt['pillar.get']('mysql:bind') }}

.. warning::

  Optional pillar key must use ``pillar.get`` and mandatory pillar must use
  ``pillar`` dictionary. If mandatory pillar value is used with ``pillar.get``
  and the pillar key isn't defined in pillar will result with an empty string
  and might have dangerous consequence.

Document those pillar keys in the :doc:`/doc/pillar` file in formula directory.

Configs
-------

All app/daemon log messages must be sent to syslog to :doc:`/rsyslog/doc/index`
and :doc:`/graylog2/doc/index` (if support). See below for more details on
logging.

All comments must be commented by jinja2 comment. User should only get a config
file with no comment. Reason for this is make user in trouble if they do
change config file manually (which may break a system managed by salt), and
the config file will be shorter, cleaner without comments.

This means::

    # blah blah blah
    # hello 123
    log: syslog

Should be ::

    {#-
    blah blah blah
    hello 123
    #}
    log: syslog

* All config files must have a header tell that it's managed by salt
  (that string get from pillar)
* All config files must end with ``.jinja2``
* Main config file should use name ``config.jinja2`` instead of
  ``its_original_name.jinja2``
* When starting to manage a new config file, it's good practice to add the
  origin config file, then make changes and commit the changes. As this will
  help formula writer easy to change the config file without have to reinstall
  the software and read the document / config from it.

Absent
------

``absent.sls``  files are mainly used by ``integration.py`` script.

Some notices when write an ``absent.sls``:

* One ``absent.sls`` should only remove/absent stuffs managed by its
  corresponding ``init.sls``. And it should not include other ``absent.sls``,
  as ``integration.py`` will run all absent SLSes itself.
* If it has a pip.remove state, make sure that states has low order
  (often order: 1) because local.absent will remove ``/usr/local`` and
  therefore remove ``/usr/local/bin/pip``, which in turn make pip.remove
  does not work anymore.

Installing
----------

* App that installed used an alternate method than ``apt-get`` should be
  located in ``/usr/local/software_name``
* Using Ubuntu ppa is preferred to self-compile software from source.

Upgrading
---------

* Make sure formula will work with an existing-running-service and a
  new-clean-install-server. (Remove old version and install new, or just
  install then restart service, or does it need a manually migrating process?)

Service
-------

Services which run with other user than root, an have a PID file belong to
that custom user should manage the PID file. Macro ``manage_pid`` in
``macros.jinja2`` helps handle that case.

Logging
-------

Some applications have the ability to send logs directly to
:doc:`/graylog2/doc/index` using `GELF <http://www.graylog2.org/gelf>`_
protocol. Which itself is better suited than ``syslog`` protocol as it contains
additional metadata.

But, logs must also be sent (with less useful data) to syslog daemon
:doc:`/rsyslog/doc/index` in case :doc:`/graylog2/doc/index` is unreachable and
to have all logs copied locally.

As :doc:`/rsyslog/doc/index` forward incoming logs received over syslog protocol
to :doc:`/graylog2/doc/index`, an application that send logs to both
:doc:`/graylog2/doc/index` over `GELF <http://www.graylog2.org/gelf>`_ and
:doc:`/rsyslog/doc/index` over syslog will cause :doc:`/graylog2/doc/index` to
receive and index two separate message for the same log record. The one
forwarded by :doc:`/rsyslog/doc/index` will even be less useful, as it will
contains no metadata. And it might even looklook as two duplicate log records.

To avoid duplication, :doc:`/rsyslog/doc/index` is configured to forward all
logs except those in ``local7`` facility to :doc:`/graylog2/doc/index`. So, all
applications that send log records to :doc:`/graylog2/doc/index` over
`GELF <http://www.graylog2.org/gelf>`_ send a copy to :doc:`/rsyslog/doc/index`
over syslog with ``local7`` facility.
All other applications must never use ``local7``.

Backup
------

All backup archives must use ``.xz`` format. Backup scripts may use ``tar``
or ``xz`` for creating ``.xz`` archive.

Jinja2
------

* Wrapping a State into an ``if`` condition should consider to have counter
  part in ``else``. Example, if a file is managed base on a pillar condition,
  but not absent it otherwise, the file may be leave on system when the pillar
  change::

    {%- if salt['pillar.get']('nginx:blah', False) %}
    /etc/nginx/conf.d/a_config_file.cfg:
      file:
        - managed
        ...
    {%- endif %}

Then if the pillar set ``nginx:blah`` beforehand, the file is managed,
later, if that pillar is deleted as user don't want to use it anymore, the file
still located on file, it still takes effect, it just not managed by Salt.
Therefore, it's good to have an ``{%- else %}`` and absent that file to avoid
this pitfall.

Macros
------

File which contains only Jinja2 macros must end with ``.jinja2``.

Documentation
-------------

Each formula must have a ``doc`` directory to contains documentation files.
It often consists of ``pillar.rst``, ``troubleshoot.rst``, and ``usage.rst``.

* ``pillar.rst`` contains document for all pillar keys used in that formula.
  It should refer to other document instead of rewriting if needed.
* Pillar key that is not a fixed value (hostname, username, ...) should use
  ``{{ }}`` to wrap around the words.

Examples::

    elasticsearch:nodes:{{ node minion ID }}:_network:public

Upstart
-------

`Upstart <http://upstart.ubuntu.com/>`_ is an event-based replacement for the
/sbin/init daemon which handles starting of tasks and services during boot,
stopping them during shutdown and supervising them while the system is running.

Dependency
~~~~~~~~~~

An upstart script must define all their dependencies to make it starts successful
when reboot.

A typical upstart script will contains.

.. code-block:: bash

   start on (net-device-up
             and local-filesystems
             and runlevel [2345]
             and started rsyslog)

An upstart service can depends on SysV init script. In SysV init script,
generate an event with `initctl emit
<http://upstart.ubuntu.com/cookbook/#initctl-emit>`_ command.

.. code-block:: bash

   # in start section of SysV init script
   initctl emit myservice-started --no-wait

After that, we can make another upstart script start on this event.

.. code-block:: bash

   # in upstart script
   start on (net-device-up
             and local-filesystems
             and runlevel [2345]
             and myservice-started)

NRPE
----

All checks that use ``/usr/lib/nagios/plugins/check_procs``
should provide ``-C`` and ``-u`` if possible. This helps avoid the check
matching itself.

Diamond
-------

ProcessResourcesCollector
~~~~~~~~~~~~~~~~~~~~~~~~~

A Diamond collector that collects memory usage of each process defined in it's
config file by matching them with their executable filepath or the process
name. This collector can also be used to collect memory usage for the Diamond
process.

Documentation: https://github.com/BrightcoveOS/Diamond/wiki/collectors-ProcessResourcesCollector

.. copied from
   https://github.com/BrightcoveOS/Diamond/wiki/collectors-ProcessResourcesCollector

A process can be matched using exe, name or cmdline.

exe
  executable file written in ``/proc/{{ processid }}/cmdline``

name
  command name, list all running processes with their names with following
  command::

    ps -eo pid,comm

cmdline
  command with all its arguments as a string, list all running
  processes with their cmdline with following command::

    ps -eo pid,args
