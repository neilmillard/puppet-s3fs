define s3fs::config( $bucket, $mountpoint, $options = 'allow_other' ) {

  if !defined(File["$mountpoint"]) {
    file {"$mountpoint":
      ensure => directory,
    }
  }

  mount {"s3mount-$name":
    ensure => mounted,
    device => "s3fs#$bucket",
    name => "$mountpoint",
    fstype => 'fuse',
    options => $options,
    require => [ Class['s3fs'], File["$mountpoint"], ],
  }

}
