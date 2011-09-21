class lucid32 {
  package { "apache2":
    ensure => present,
    require => Exec["apt-update"],
  }

  service { "apache2":
    ensure => running,
    require => Package["apache2"],
  }
  
  file {"indexfile":
        path    => "/var/www/index.html",
        ensure  => present,
        content => "Halleiihe NTNU",
        require => Package["apache2"],
  }
  
  exec { "apt-update":
      command     => "/usr/bin/apt-get -q -q update",
      logoutput   => false,
  }
}

include lucid32