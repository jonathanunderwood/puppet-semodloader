class semodloader ($moddir = '/usr/local/share/selinux') {

  package { ['policycoreutils',
             'checkpolicy',
             ]: ensure => latest}
  
  file {$moddir:
    ensure  => directory,
    owner   => 'root',
    group   => 'root',
    mode    => 755,
    require => [ Package['policycoreutils'],
                 Package['checkpolicy'],
                 ],
  }


  define semodule ($source, $status = 'present') {
  # Set some resource defaults for simplification below.
    File {
      owner => 'root',
      group => 'root',
      mode => '0644',
    }

    Exec {
      path => '/sbin:/usr/sbin:/bin:/usr/bin',
      refreshonly => true,
      cwd => $semodloader::moddir,
    }
    
    file {"${semodloader::moddir}/${name}.te":
      ensure  => $status,
      source  => $source,
      require => File ["${semodloader::moddir}"],
    }
    
    file { "${semodloader::moddir}/${name}.mod":
      tag => ['selinux-module-build', 'selinux-module'],
    }

    file { "${semodloader::moddir}/${name}.pp":
      tag => ['selinux-module-build', 'selinux-module'],
    }
    
    case $status {
      present: {
        exec { "${name}-buildmod":
          command => "checkmodule -M -m -o ${name}.mod ${name}.te",
        }
        
        exec { "${name}-buildpp":
          command => "semodule_package -m ${name}.mod -o ${name}.pp",
        }

        exec { "${name}-install":
          command => "semodule -i ${name}.pp",
        }

        # This sorts out the correct ordering of execs
        File["${semodloader::moddir}/${name}.te"]
        ~> Exec["${name}-buildmod"]
        ~> Exec["${name}-buildpp"]
        ~> Exec["${name}-install"]
        -> File<| tag == 'selinux-module-build' |>
      }

      absent: {
        exec { "${name}-remove":
          command => "semodule -r ${name}.pp > /dev/null 2>&1",
        }
        
        Exec["${name}-remove"]-> File<| tag == 'selinux-module' |>
      }
      
      default: {
        fail("status variable not recognized")
      }
    }
  }
}

