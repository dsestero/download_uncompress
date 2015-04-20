# Class: download_uncompress::dependencies
#
# Install dependencies needed for the module.
#
# == Actions:
#
# Install the package +unzip+.
#
# == Requires:
# none
#
# == Sample usage:
#
# include download_uncompress::dependencies
#
class download_uncompress::dependencies {
  $enhancers = ['unzip']

  package { $enhancers:
    ensure => installed,
  }
}
