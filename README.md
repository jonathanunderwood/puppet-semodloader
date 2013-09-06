puppet-semodloader
==================

A puppet module for loading SELinux policy modules. 

Puppet has in-built types for handling binary SELinux module
blobs. However, it's often preferable to manage SELinux policy modules
via the textual (.te) representations of the policy. This puppet
module provides that capability.

Example usage
-------------
The example below demonstrates how to use this puppet module to load a
SELinux policy module for cobbler before the cobbler daemon is
started.


    class {'semodloader': }

    semodloader::semodule {'cobblerlocal':
        source => 'puppet:///cobbler/cobblerlocal.te',
        status => 'present',
        before => Service ['cobblerd'],
      }


Background information
----------------------
Some more info can be found on my blog:

o http://stuckinadoloop.wordpress.com/2011/06/15/puppet-managed-deployment-of-selinux-modules/

o http://stuckinadoloop.wordpress.com/2011/08/17/deploying-selinux-modules-with-puppet-reprise/

In addition, the development of this module was stimulated by this blog entry:

http://allmybase.com/2011/04/26/easily-managing-selinux-policies-with-puppet/