notice('MODULAR: fuel-plugin-etckeeper/commit_etckeeper.pp')

exec { 'etckeeper-commit':
  path    => '/bin:/usr/bin:/usr/local/bin',
  command => '/usr/bin/etckeeper commit "Deployment End"',
}
