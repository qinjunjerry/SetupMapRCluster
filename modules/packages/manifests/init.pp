# Class: package
#
# This module installs simple packages via puppet package resource
#
class packages (
) {

  $toinstall = lookup('packages::toinstall', {merge => unique})
  $toinstall.each |$name| {
    package { $name:
      ensure => present,
    }
  }

}