# Define:  profile::hadoop::xmlconf_property
#
# This define type manipulates hadoop style xml config files via augeas

define profile::hadoop::xmlconf_property (
  $file,
  $value       = 'value',
  $description = undef,
  $ensure      = 'present',
) {

  if '@' in $title {
    # title is form of 'property@namespace' in order to be unique
    $property_name = split($title,'@')[0]
  } else {
    $property_name = $title
  }

  case $ensure {

    'present': {

      $_changes = [
        "defnode property_node configuration/property[name/#text='$property_name'] ''",
        "set \$property_node/name/#text        '$property_name'",
        "set \$property_node/value/#text       '$value'",
      ]
      # add description if set
      if $description == undef {
        $changes = $_changes
      } elsif $description == '' {
        $changes = concat($_changes, "rm  \$property_node/description")
      } else {
        $changes = concat($_changes, "set \$property_node/description/#text '$description'")
      }

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
