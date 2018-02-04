class profile::mysql_server (
) {

  exec { 'install mysql-community-release repo':
    command   => "/usr/bin/yum install -y http://repo.mysql.com/mysql-community-release-el7-5.noarch.rpm",
    logoutput => on_failure,
    creates   => "/etc/yum.repos.d/mysql-community.repo",
  }
  ->
  package { 'mysql-server':
    ensure => present,
  }
  ->
  service { 'mysqld':
  	ensure => running,
  }

}
