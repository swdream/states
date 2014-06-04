:doc:`/postgresql/doc/index` user password.

Default: randomly generated.

.. note::

  If for any reason the password need to be retrieved after installation,
  use the custom salt module ``password.pillar`` and specify
  the pillar key name in format ``path:db:password``.