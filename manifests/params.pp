class puppet::params {
  $puppetserver = "$::fqdn"
  $module_base_path = '/etc/puppet/environments'
  $certname_default = "${::fqdn}"
  $prod_modules_default = "${module_base_path}/production/modules"
  $prod_manifest_default = "${module_base_path}/production/manifests/site.pp"
}
