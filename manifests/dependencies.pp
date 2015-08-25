# Class: download_uncompress::dependencies
#
# Installs dependencies needed for the module.
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
  ensure_packages($enhancers)
}
