notice('MODULAR: fuel-plugin-etckeeper/configure_etckeeper.pp')

Augeas {
  lens => 'Shellvars.lns',
  incl => '/etc/etckeeper/etckeeper.conf'
}

augeas { 'etckeeper-vcs':
  changes => [
    'set VCS \'"git"\''
  ]
}

# if the .git folder does not exist then run the etckeeper git process
exec { 'etckeeper-init':
  path    => '/bin:/usr/bin:/usr/local/bin',
  command => '/usr/bin/etckeeper init -f',
  unless  => 'test -d /etc/.git'
}
