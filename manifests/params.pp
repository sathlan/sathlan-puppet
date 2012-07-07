class puppet::params {
  $puppetserver = "$::fqdn"
  $certname_default = "${::fqdn}.cert"
}
