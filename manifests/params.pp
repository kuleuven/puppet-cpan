# == Class: cpan::params
#
# Parameters for cpan class
#
class cpan::params {

  $manage_config     = true
  $installdirs       = 'site'
  $local_lib         = false
  $config_template   = 'cpan/cpan.conf.erb'
  $config_hash = {
    'applypatch'                    => '',
    'auto_commit'                   => '0',
    'build_cache'                   => '100',
    'build_dir'                     => '/root/.cpan/build',
    'build_dir_reuse'               => '0',
    'build_requires_install_policy' => 'no',
    'bzip2'                         => '/bin/bzip2',
    'cache_metadata'                => '1',
    'check_sigs'                    => '0',
    'colorize_output'               => '0',
    'commandnumber_in_prompt'       => '1',
    'connect_to_internet_ok'        => '1',
    'cpan_home'                     => '/root/.cpan',
    'curl'                          => '/usr/bin/curl',
    'ftp'                           => '/usr/bin/ftp',
    'ftp_passive'                   => '1',
    'getcwd'                        => 'cwd',
    'gpg'                           => '/usr/bin/gpg',
    'gzip'                          => '/bin/gzip',
    'halt_on_failure'               => '0',
    'histfile'                      => '/root/.cpan/histfile',
    'histsize'                      => '100',
    'inactivity_timeout'            => '0',
    'index_expire'                  => '1',
    'inhibit_startup_message'       => '0',
    'keep_source_where'             => '/root/.cpan/sources',
    'load_module_verbosity'         => 'v',
    'lynx'                          => '',
    'make'                          => '/usr/bin/make',
    'make_arg'                      => '',
    'make_install_arg'              => '',
    'make_install_make_command'     => '',
    'makepl_arg'                    => 'INSTALLDIRS=site',
    'mbuild_arg'                    => '',
    'mbuild_install_arg'            => '',
    'mbuild_install_build_command'  => './Build',
    'ncftp'                         => '',
    'ncftpget'                      => '',
    'no_proxy'                      => '',
    'pager'                         => '/usr/bin/less',
    'patch'                         => '/usr/bin/patch',
    'perl5lib_verbosity'            => 'v',
    'prefer_installer'              => 'MB',
    'prefs_dir'                     => '/root/.cpan/prefs',
    'prerequisites_policy'          => 'follow',
    'scan_cache'                    => 'atstart',
    'shell'                         => '/bin/bash',
    'show_unparsable_versions'      => '0',
    'show_upload_date'              => '0',
    'show_zero_versions'            => '0',
    'tar'                           => '/bin/tar',
    'tar_verbosity'                 => 'v',
    'term_is_latin'                 => '1',
    'term_ornaments'                => '1',
    'test_report'                   => '0',
    'trust_test_report_history'     => '0',
    'unzip'                         => '',
    'use_sqlite'                    => '0',
    'wget'                          => '/usr/bin/wget',
    'yaml_load_code'                => '0',
    'yaml_module'                   => 'YAML',
  }
  $package_ensure    = 'present'
  $common_package    = ['gcc','make']
  $ftp_proxy         = undef
  $http_proxy        = undef
  $urllist           = []

  $manage_package = $::osfamily ? {
    'Debian' => true,
    'Redhat' => true,
    default  => false,
  }
  case $::osfamily {
    'Debian': {
      $common_os_package = ['perl']
      if $local_lib {
        $local_lib_package  = ['liblocal-lib-perl']
      } else {
        $local_lib_package  = []
      }
    }
    'RedHat': {
      $common_os_package = ['perl-CPAN']

      if $local_lib {
        if ($::operatingsystem == 'RedHat' and versioncmp($::operatingsystemmajrelease, '6') >= 0) {
          $local_lib_package  = ['perl-local-lib']
        } elsif  ($::operatingsystem == 'Fedora' and versioncmp($::operatingsystemmajrelease, '16') >=0) {
          $local_lib_package  = ['perl-local-lib']
        }
      } else {
        $local_lib_package  = []
      }
    }
    default: {
      fail("Module ${module_name} is not supported on ${::osfamily}")
    }
  }
  $package_name =  concat($common_package,$common_os_package,$local_lib_package )
}
