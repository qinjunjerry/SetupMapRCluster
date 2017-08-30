# include classes from hiera
lookup('classes', {merge => unique}).include

node default {
  # look in hiera
}
