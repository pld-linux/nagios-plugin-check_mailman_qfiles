%define		plugin	check_mailman_qfiles
%include	/usr/lib/rpm/macros.perl
Summary:	Nagios plugin to check Mailman qfiles
Name:		nagios-plugin-%{plugin}
Version:	0.1
Release:	1
License:	GPL
Group:		Networking
# Source0Download: http://exchange.nagios.org/components/com_mtree/attachment.php?link_id=1347&cf_id=24
Source0:	%{plugin}.pl
URL:		http://exchange.nagios.org/directory/Plugins/Email-and-Groupware/Mailman/check_mailman_qfiles/details
BuildRequires:	rpm-perlprov >= 4.1-13
Requires:	nagios-core
Requires:	nagios-plugins-libs
BuildArch:	noarch
BuildRoot:	%{tmpdir}/%{name}-%{version}-root-%(id -u -n)

%define		_sysconfdir	/etc/nagios/plugins
%define		plugindir	%{_prefix}/lib/nagios/plugins

%description
Checks age and number of mailman qfiles to keep the mailing lists
flowing and responsive.

Simple Perl script to check the various Mailman qfiles directories for
old, unprocessed items and report on freshness.

%prep
%setup -qcT
cat > nagios.cfg <<'EOF'
define command {
	command_name    %{plugin}
	command_line    %{plugindir}/%{plugin} -w 5 -c 20
}
EOF

%install
rm -rf $RPM_BUILD_ROOT
install -d $RPM_BUILD_ROOT{%{_sysconfdir},%{plugindir}}
install %{SOURCE0} $RPM_BUILD_ROOT%{plugindir}/%{plugin}
cp -a nagios.cfg $RPM_BUILD_ROOT%{_sysconfdir}/%{plugin}.cfg

%clean
rm -rf $RPM_BUILD_ROOT

%files
%defattr(644,root,root,755)
%config(noreplace) %verify(not md5 mtime size) %{_sysconfdir}/%{plugin}.cfg
%attr(755,root,root) %{plugindir}/%{plugin}
