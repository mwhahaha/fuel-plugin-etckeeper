notice('MODULAR: fuel-plugin-etckeeper/install_etckeeper.pp')

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
}

