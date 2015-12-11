notice('MODULAR: fuel-plugin-etckeeper/install_etckeeper.pp')

$package_list = ['etckeeper', 'git']

ensure_packages($package_list)

# the installation of etckeeper includes an initial initialization using bzr
# so we want to uninit etckeeper if the package changes and it is configured
# to use bzr. This plugin will configure it to use git afterwards so this should
# only run after the initial installation.
exec { 'etckeeper-uninit':
  refreshonly => true,
  path        => '/bin:/usr/bin:/usr/local/bin',
  command     => '/usr/bin/etckeeper uninit -f',
  onlyif      => 'grep -q \'^VCS="bzr"\' /etc/etckeeper/etckeeper.conf',
}

Package['etckeeper'] ~> Exec['etckeeper-uninit']
