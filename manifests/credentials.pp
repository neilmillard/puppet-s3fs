class s3fs::credentials ( $accesskey = undef, $secretaccesskey = undef ) {

  if $accesskey and $secretaccesskey {
    file { '/root/.passwd-s3fs':
      ensure => present,
      owner => root,
      group => root,
      mode => 600,
      content => template("s3fs/passwd-s3fs"),
    }
  }

}
