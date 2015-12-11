notice('MODULAR: fuel-plugin-etckeeper/configure_etckeeper.pp')

Augeas {
  lens => 'Shellvars.lns',
  incl => '/etc/etckeeper/etckeeper.conf'
}

$etckeeper_hash = hiera_hash('fuel-plugin-etckeeper', {})
$etckeeper_scm = pick($etckeeper_hash['vcs'], 'git')

$etckeeper_scm_dir = $etckeeper_scm ? {
  /git/: { '/etc/.git' },
  /hg/: { '/etc/.hg' },
  /bzr/: { '/etc/.bzr' },
  default: {
    fail("Unsupported SCM '${etckeeper_scm}'")
  }
}

augeas { 'etckeeper-vcs':
  changes => [
    "set VCS '\"${etckeeper_scm}\"'"
  ]
}


# if the .git folder does not exist then run the etckeeper git process
exec { 'etckeeper-init':
  path    => '/bin:/usr/bin:/usr/local/bin',
  command => '/usr/bin/etckeeper init -f',
  unless  => "test -d ${etckeeper_scm_dir}"
}
