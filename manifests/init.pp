class s3fs ( $version = '1.74', $tarball_url, $tarball_dir = '/usr/local' ) {

  package { [
            'gcc',
            'libstdc++-devel',
            'gcc-c++',
            'fuse',
            'fuse-devel',
            'libcurl-devel',
            'libxml2-devel',
            'openssl-devel',
            'mailcap',
            ]:
    ensure => installed,
    before => Exec['configure-s3fs'],
  }

  $tarball = "s3fs-${version}.tar.gz"

  include wget
  wget::fetch { 's3fs':
    source      => "${tarball_url}/${tarball}",
    destination => "${tarball_dir}/${tarball}",
  }

  Exec {
    path => '/usr/bin/:/bin:/usr/sbin:/sbin',
  }

  exec {'extract-s3fs':
    cwd     => "${tarball_dir}",
    command => "tar zxf ${tarball}",
    creates => "${tarball_dir}/s3fs-${version}",
    require => Wget::Fetch['s3fs'],
  }

  exec {'configure-s3fs':
    cwd      => "${tarball_dir}/s3fs-${version}/",
    provider => 'shell',
    command  => "./configure --prefix=/usr",
    creates  => "${tarball_dir}/s3fs-${version}/Makefile",
    require  => Exec['extract-s3fs'],
  }

  exec {'compile-s3fs':
    cwd      => "${tarball_dir}/s3fs-${version}/",
    provider => 'shell',
    command  => "make && make install",
    unless   => "/usr/bin/s3fs --version | grep ${version}",
    require  => Exec['configure-s3fs'],
  }

}
