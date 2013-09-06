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
    case $status {
      present: {
        file {"${semodloader::moddir}/${name}.te":
          owner    => 'root',
          group    => 'root',
          mode     => 644,
          source   => $source,
          require => File ["${semodloader::moddir}"],
        }
        
        file {"${semodloader::moddir}/${name}.mod":
          owner    => 'root',
          group    => 'root',
          mode     => 644,
          require => File ["${semodloader::moddir}"],
        }
        
        file {"${semodloader::moddir}/${name}.pp":
          owner    => 'root',
          group    => 'root',
          mode     => 644,
          require => File ["${semodloader::moddir}"],
        }

        exec {"${name}-buildpp":
          command     => "checkmodule -M -m -o ${name}.mod ${name}.te ; semodule_package -m ${name}.mod -o ${name}.pp",
          path        => ['/sbin', '/usr/sbin', '/bin', '/usr/bin'],
          cwd         => "${semodloader::moddir}", 
          subscribe   => File ["${semodloader::moddir}/${name}.te"],
          require     => File ["${semodloader::moddir}/${name}.te"],
          refreshonly => true,
        }
        
        selmodule {$name:
          ensure => present,
          syncversion => true,
          selmodulepath => "${semodloader::moddir}/${name}.pp",
          require => Exec ["${name}-buildpp"],
        }

      }
      
      absent: {
        file {"${semodloader::moddir}/${name}.te":
          ensure => absent,
        }
        
        file {"${semodloader::moddir}/${name}.mod":
          ensure => absent,
        }
        file {"${semodloader::moddir}/${name}.pp":
          ensure => absent,
        }

        exec {"${name}-remove":
          command     => "semodule -r ${name} > /dev/null 2>&1",
          path        => ['/sbin', '/usr/sbin', '/bin', '/usr/bin'],
        }
      }
      
      default: {
        fail("status variable not recognized")
      }
         
    }
  }
}

