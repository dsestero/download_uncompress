# = Define: download_uncompress
#
# Downloads and possibly uncompress a file from a given url to a specified
# destination folder.
#
# == Parameters:
#
# $download_base_url::  Base URL from which to download.
#                       Defaults to <tt>distributions_base_url</tt> key defined
#                       in hiera.
#
# $distribution_name::  Name of the distribution to download.
#
# $dest_folder::    Destination folder where to unzip (or possibly only
#                   download) the distribution.
#
# $creates::        Folder created after downloading and possibly unzipping,
#                   useful to make the resource type idempotent.
#
# $uncompress::     Specify the type of compression used by the distribution or
#                   if no uncompression is needed.
#                   Possible values are <tt>zip</tt>, <tt>tar.gz</tt>. Any other
#                   value is interpreted as no uncompression needed.
#                   Defaults to +false+.
#
# $user::           user to be used when performing the download and the
#                   eventual uncompression.
#                   Defaults to +root+.
#
# $group::          group to be used when performing the download and the
#                   eventual uncompression.
#                   Defaults to +root+.
#
# == Actions:
#
# Performs a wget from the specified url and possibly unzip the downloaded file
# into the destination folder.
#
# == Requires:
# the key <tt>distributions_base_url</tt> has to be definied in hiera
#
# == Sample usage:
#
# download_uncompress {'dwnl_inst_swxy':
#   download_base_url  => "http://jee.invallee.it/dist",
#   distribution_name  => "SoftwareXY.zip"
#   dest_folder   => '/tmp',
#   creates       => "/tmp/SXYInstallFolder",
#   uncompress    => 'tar.gz',
#}
define download_uncompress (
  $distribution_name,
  $dest_folder,
  $creates,
  $uncompress        = false,
  $user              = root,
  $group             = root,
  $download_base_url = hiera('distributions_base_url'),) {
  include download_uncompress::dependencies

  $download_url = "${download_base_url}/${distribution_name}"
  $dist_path_name = split($distribution_name, '/')
  $file_name = $dist_path_name[-1]
  $cmd = $uncompress ? {
    'zip'    => "wget -P /tmp/ ${download_url} -O /tmp/${file_name} && mkdir -p ${dest_folder} && unzip /tmp/${file_name} -d ${dest_folder}",
    'tar.gz' => "wget -P /tmp/ ${download_url} -O /tmp/${file_name} && mkdir -p ${dest_folder} && tar xzf /tmp/${file_name} -C ${dest_folder}",
    default  => "wget -P ${dest_folder} ${download_url}",
  }

  exec { "download_uncompress_${download_url}-${dest_folder}":
    command   => $cmd,
    creates   => $creates,
    user      => $user,
    group     => $group,
    logoutput => 'on_failure',
    require   => Class['Download_uncompress::Dependencies'],
  }
}
