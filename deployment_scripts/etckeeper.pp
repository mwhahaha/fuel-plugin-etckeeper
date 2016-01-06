notice('MODULAR: fuel-plugin-etckeeper/etckeeper.pp')

Augeas {
  lens => 'Shellvars.lns',
  incl => '/etc/etckeeper/etckeeper.conf'
}

$etckeeper_hash = hiera_hash('fuel-plugin-etckeeper', {})
$etckeeper_scm = pick($etckeeper_hash['vcs'], 'git')
if !($etckeeper_scm in ['git', 'hg', 'bzr']) {
  fail("Unsupported SCM '${etckeeper_scm}'")
}
$etckeeper_scm_package = $etckeeper_scm ? {
  /git/ => 'git',
  /hg/  => 'mercurial',
  /bzr/ => 'bazaar',
}

$package_list = ['etckeeper', $etckeeper_scm_package]

ensure_packages($package_list)

if $::operatingsystem == 'Ubuntu' and $etckeeper_scm != 'bzr' {
  # the installation of etckeeper includes an initial initialization using bzr
  # so we want to uninit etckeeper if the package changes and it is configured
  # to not use bzr.
  exec { 'etckeeper-uninit':
    refreshonly => true,
    path        => '/bin:/usr/bin:/usr/local/bin',
    command     => '/usr/bin/etckeeper uninit -f',
    onlyif      => 'grep -q \'^VCS="bzr"\' /etc/etckeeper/etckeeper.conf',
  }
  Package['etckeeper'] ~> Exec['etckeeper-uninit']
  Package['etckeeper'] ->
    Exec['etckeeper-uninit'] ->
      Augeas['etckeeper-vcs']
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

exec { 'etckeeper-commit':
  path    => '/bin:/usr/bin:/usr/local/bin',
  command => '/usr/bin/etckeeper commit "Deployment End"',
}

Package['etckeeper'] ->
  Exec['etckeeper-init'] ->
    Exec['etckeeper-commit']
