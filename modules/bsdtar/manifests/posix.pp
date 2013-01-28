class bsdtar::posix {
  require build_essential

  $autotools_environment = $bsdtar::autotools_environment
  $file_cache_dir        = $bsdtar::file_cache_dir
  $install_dir           = $bsdtar::install_dir

  $source_dir_path = "${file_cache_dir}/libarchive-3.1.1"
  $source_package_path = "${file_cache_dir}/libarchive.tar.gz"
  $source_url = "https://github.com/libarchive/libarchive/archive/v3.1.1.tar.gz"

  if $kernel == 'Darwin' {
    # Make sure we have a later version of automake/autoconf
    homebrew::package { "automake":
      creates => "/usr/local/bin/automake",
      link    => true,
      before  => Exec["automake-libarchive"],
    }

    homebrew::package { "autoconf":
      creates => "/usr/local/bin/autoconf",
      link    => true,
      before  => Exec["automake-libarchive"],
    }
  }

  #------------------------------------------------------------------
  # Download and Setup
  #------------------------------------------------------------------
  download { "libarchive":
    source      => $source_url,
    destination => $source_package_path,
  }

  exec { "untar-libarchive":
    command => "tar xvzf ${source_package_path}",
    creates => $source_dir_path,
    cwd     => $file_cache_dir,
    require => Download["libarchive"],
  }

  #------------------------------------------------------------------
  # Compile
  #------------------------------------------------------------------
  # Create configuration script
  exec { "automake-libarchive":
    command => "/bin/sh build/autogen.sh",
    creates => "${source_dir_path}/configure",
    cwd     => $source_dir_path,
    require => Exec["untar-libarchive"],
  }

  # Build it
  autotools { "libarchive":
    configure_flags  => "--prefix=${install_dir} --disable-dependency-tracking",
    cwd              => $source_dir_path,
    environment      => $real_autotools_environment,
    install_sentinel => "${install_dir}/bin/bsdtar",
    make_sentinel    => "${source_dir_path}/bsdtar",
    require          => Exec["automake-libarchive"],
  }
}
