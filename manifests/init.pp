class s3fs ( $s3fs_version = '1.78', $fuse_version = '2.9.3', $tarball_url, $tarball_dir = '/usr/local/src' ) {

  Exec {
    path => '/usr/bin/:/bin:/usr/sbin:/sbin',
  }

  package { [
            'gcc',
            'libstdc++-devel',
            'gcc-c++',
            'libcurl-devel',
            'libxml2-devel',
            'openssl-devel',
            'mailcap',
            ]:
    ensure => installed,
    before => [ Exec['configure-s3fs'], Exec['configure-fuse'], ],
  }

  $s3fs_tarball = "s3fs-${s3fs_version}.tar.gz"
  $fuse_tarball = "fuse-${fuse_version}.tar.gz"

  include wget

  #Install a new version of Fuse
  wget::fetch { 'fuse':
    source      => "${tarball_url}/${fuse_tarball}",
    destination => "${tarball_dir}/${fuse_tarball}",
  }
  exec {'extract-fuse':
    cwd     => "${tarball_dir}",
    command => "tar zxf ${fuse_tarball}",
    creates => "${tarball_dir}/fuse-${fuse_version}",
    require => Wget::Fetch['fuse'],
  }
  exec {'configure-fuse':
    cwd      => "${tarball_dir}/fuse-${fuse_version}/",
    provider => 'shell',
    command  => "./configure --prefix=/usr",
    creates  => "${tarball_dir}/fuse-${fuse_version}/Makefile",
    require  => Exec['extract-fuse'],
  }
  exec {'compile-fuse':
    cwd      => "${tarball_dir}/fuse-${fuse_version}/",
    provider => 'shell',
    command  => "make && make install && ldconfig",
    unless   => "/usr/bin/fusermount -V | grep ${fuse_version}",
    require  => Exec['configure-fuse'],
  }

  #Install S3FS
  wget::fetch { 's3fs':
    source      => "${tarball_url}/${s3fs_tarball}",
    destination => "${tarball_dir}/${s3fs_tarball}",
  }
  exec {'extract-s3fs':
    cwd     => "${tarball_dir}",
    command => "tar zxf ${s3fs_tarball}",
    creates => "${tarball_dir}/s3fs-${s3fs_version}",
    require => Wget::Fetch['s3fs'],
  }
  exec {'autogen-configure-s3fs':
    cwd         => "${tarball_dir}/s3fs-${s3fs_version}/",
    provider    => 'shell',
    command     => "./autogen.sh",
    creates     => "${tarball_dir}/s3fs-${s3fs_version}/configure",
    require     => [ Exec['extract-s3fs'], Exec['compile-fuse'], ],
  }
  exec {'configure-s3fs':
    cwd         => "${tarball_dir}/s3fs-${s3fs_version}/",
    provider    => 'shell',
    environment => "PKG_CONFIG_PATH=/usr/lib/pkgconfig:/usr/lib64/pkgconfig/",
    command     => "./configure --prefix=/usr",
    creates     => "${tarball_dir}/s3fs-${s3fs_version}/Makefile",
    require     => [ Exec['extract-s3fs'], Exec['compile-fuse'], Exec['autogen-configure-s3fs'], ],
  }
  exec {'compile-s3fs':
    cwd      => "${tarball_dir}/s3fs-${s3fs_version}/",
    provider => 'shell',
    command  => "make && make install",
    unless   => "/usr/bin/s3fs --version | grep ${s3fs_version}",
    require  => Exec['configure-s3fs'],
  }

}
