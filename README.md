# puppet-s3fs

## Overview

This module installs S3FS and FUSE from source tarballs. Note this is only tested on CentOS 6.x.

## Usage

```tarball_url``` defines the location of the S3FS and FUSE .tar.gz packages, they expected to be of the form ```s3fs-1.74.tar.gz``` and ```fuse-2.9.3.tar.gz``` or whatever the specified versions are.

```
  class { 's3fs':
    tarball_url  => 'http://mydomain.com/s3fs/',
    s3fs_version => '1.78',
    fuse_version => '2.9.3',
  }
  ->
  class { 's3fs::credentials':
    accesskey       => 'ABCDEFG',
    secretaccesskey => 'HIJKLMNOPQRS',
  }
  ->
  s3fs::config { 'mybucket':
    bucket     => 'com.myorg.mybucket',
    mountpoint => '/mnt/mybucket',
    options    => 'passwd_file=/root/.passwd-s3fs,allow_other',
  }
```
