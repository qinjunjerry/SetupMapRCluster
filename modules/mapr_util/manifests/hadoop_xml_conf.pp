define mapr_util::hadoop_xml_conf ( 
  $file,
  $value       = 'value',
  $description = 'No description given here',
  $ensure      = 'present',
) {

  $property_name = $title

  case $ensure {
    'present': {
      $changes = [
        "defnode property_node configuration/property[name/#text='$property_name'] ''",
        "set \$property_node/name/#text        '$property_name'",
        "set \$property_node/value/#text       '$value'",
        "set \$property_node/description/#text '$description'",
      ]
    }

    'absent': {
      $changes = "rm configuration/property[name/#text='$property_name']"
    }

    default: {
      fail("Unknown value for ensure: ${ensure}")
    }
  }

  augeas { "update $property_name in ${file}":
    incl    => $file,
    lens    => 'Xml.lns',
    changes => $changes,
  } ~>
  # format xml using xmllint after a change
  exec { "format $property_name in ${file}":
    command     => "/usr/bin/xmllint --format $file --output $file",
    logoutput   => on_failure,
    refreshonly => true,
  }

}