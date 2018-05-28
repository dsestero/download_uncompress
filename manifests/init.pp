# Downloads and possibly uncompress a file from a given url to a specified
#   destination folder.
#
# @param download_base_url [Optional[String]] base URL from which to download.
#                       Defaults to <tt>distributions_base_url</tt> key defined
#                       in hiera or <tt>undef</tt> if such key is not found.
#
# @param distribution_name [String] name of the distribution to download or
#                       full URL, in which case the parameter $download_base_url is ignored.
#
# @param dest_folder [String] destination folder where to unzip (or possibly only
#                   download) the distribution.
#
# @param creates [String] folder created after downloading and possibly unzipping,
#                   useful to make the resource type idempotent.
#
# @param uncompress [Enum['none', 'zip', 'tar.gz', 'jar']] compression type used by the distribution or
#                   +none+ if no uncompression is needed.
#                   Defaults to +none+.
#
# @param user [String] user to be used when performing the download and the
#                   eventual uncompression.
#                   Defaults to +root+.
#
# @param group [String] group to be used when performing the download and the
#                   eventual uncompression.
#                   Defaults to +root+.
#
# @param wget_options [String] options to pass to the wget command.
#                   Defaults to the empty string.
#
# @param install_unzip [Boolean] whether to install the package unzip if missing.
#                   Defaults to +true+.
#
# @example Declaring in manifest
#   download_uncompress {'dwnl_inst_swxy':
#     download_base_url  => 'http://jee.invallee.it/dist',
#     distribution_name  => 'SoftwareXY.zip',
#     dest_folder   => '/tmp',
#     creates       => '/tmp/SXYInstallFolder',
#     uncompress    => 'tar.gz',
#   }
#
# @author Dario Sestero
define download_uncompress (
  String $distribution_name,
  String $dest_folder,
  String $creates,
  Enum['none', 'zip', 'tar.gz', 'jar'] $uncompress        = 'none',
  String $user = root,
  String $group = root,
  Boolean $install_unzip = true,
  String $wget_options = '',
  Optional[String] $download_base_url = lookup('distributions_base_url', String, 'first', undef),) {

  if $install_unzip {
    $enhancers = ['unzip']
    ensure_packages($enhancers)
  }

  if $download_base_url == undef and !('http://' in $distribution_name) {
    fail("No download_base_url specified and distribution name does not begin with 'http://'")
  }

  if 'http://' in $distribution_name {
    $download_url = $distribution_name
  } else {
    $download_url = "${download_base_url}/${distribution_name}"
  }

  $dist_path_name = split($distribution_name, '/')
  $file_name = $dist_path_name[-1]
  $cmd = $uncompress ? {
    /(zip|jar)/    => "wget ${wget_options} -P /tmp/ ${download_url} -O /tmp/${file_name} && mkdir -p ${dest_folder} && unzip -o /tmp/${file_name} -d ${dest_folder}",
    'tar.gz' => "wget ${wget_options} -P /tmp/ ${download_url} -O /tmp/${file_name} && mkdir -p ${dest_folder} && tar xzf /tmp/${file_name} -C ${dest_folder}",
    default  => "wget ${wget_options} -P ${dest_folder} ${download_url}",
  }

  exec { "download_uncompress_${download_url}-${dest_folder}":
    command   => $cmd,
    creates   => $creates,
    user      => $user,
    group     => $group,
    logoutput => 'on_failure',
    path      => '/usr/local/bin/:/usr/bin:/bin/',
  }
}
