class role::kerberos_kdc {
  include profile::redhat::epel
  include profile::kerberos::kdc
}