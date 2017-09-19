# Class: download_uncompress::dependencies
#
# Installs dependencies needed for the module.
#
# == Actions:
#
# Install the package +unzip+ if true.
#
# == Requires:
# none
#
# == Sample usage:
#
# include download_uncompress::dependencies
#
class download_uncompress::dependencies {
  if $install_unzip == 'true' {
    $enhancers = ['unzip']
    ensure_packages($enhancers)
  }
}
