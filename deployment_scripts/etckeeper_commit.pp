notice('MODULAR: fuel-plugin-etckeeper/etckeeper_commit.pp')

exec { 'etckeeper-commit':
  path    => '/bin:/usr/bin:/usr/local/bin',
  command => '/usr/bin/etckeeper commit "Deployment End"',
}
