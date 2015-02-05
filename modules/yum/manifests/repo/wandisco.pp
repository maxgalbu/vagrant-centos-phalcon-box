# = Class: yum::repo::rpmforge
#
# This class installs the rpmforce repo
#
class yum::repo::wandisco {

  yum::managed_yumrepo { 'wandisco':
    descr    => 'WANdisco SVN Repo 1.8',
    baseurl  => 'http://opensource.wandisco.com/rhel/$releasever/svn-1.8/RPMS/$basearch/',
    enabled  => 1,
    gpgcheck => 1,
    gpgkey   => 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-WANdisco',
    gpgkey_source  => 'puppet:///modules/yum/rpm-gpg/RPM-GPG-KEY-WANdisco',
    priority => 1,
  }

}
