node 'centosgradle.local', 'ubuntugradle.local' {
  class {'gradle':
        version => '1.8',
  }
}
