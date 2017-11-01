define mapr_util::hadoop_xml_conf ( 
  $file,
  $value,
  $description = 'No description given here',
  $ensure = 'present',
) {

  $key = $title

  case $ensure {
    'present': {
      $changes = [
        "defnode property configuration/property[name/#text='$key'] ''",
        "set \$property/name/#text        '$key'",
        "set \$property/value/#text       '$value'",
        "set \$property/description/#text '$description'",
      ]
    }

    'absent': {
      $changes = "rm configuration/property[name/#text='$key']"
    }

    default: {
      fail("Unknown value for ensure: ${ensure}")
    }
  }

  augeas { "${file}/${key}":
    incl    => $file,
    lens    => 'Xml.lns',
    changes => $changes,
  }

}