# Class: kerberos
#
# This module defines Kerberos related variables
#

class profile::kerberos (
  $default_realm = $kerberos::default_realm,
  $kdc_server    = $kerberos::kdc_server,
) {

}