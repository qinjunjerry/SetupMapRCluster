# Class: profile::packages
#
# This module installs simple packages via puppet package resource
#
class profile::packages (
) {

  $toinstall = lookup('profile::packages::toinstall', {merge => unique})
  $toinstall.each |$name| {
    package { $name:
      ensure => installed,
    }
  }

}