# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header$

# This file contains a custom OS package to provide information on the
# installation structure on Gentoo. It is based on the Debian OS equivalent
# that is built into SqueezeCenter.

# @@DONE@@
# INC
# 	/usr/share/squeezecenter/CPAN
# :Firmware|Graphics|HTML|IR|MySQL|SQL
#  	/usr/share/squeezecenter/$dir
# Plugins
# 	/var/lib/squeezecenter/Plugins
# 	/usr/lib/" . $Config{'package'} . "/vendor_perl/" . $Config{'version'} . "/Slim/Plugin
# strings|revision
# 	/usr/share/squeezecenter
# lib
# 	/usr/lib/squeezecenter
# mysql-language
# 	/usr/share/mysql/english
# types|convert
# 	/etc/squeezecenter
# prefs
# 	/var/lib/squeezecenter/prefs
# log
# 	/var/log/squeezecenter
# cache
# 	/var/lib/squeezecenter/cache
# music|playlists
# 	''
# scanner
# 	/usr/libexec/squeezecenter-scanner
# UserPluginRoot
# 	/var/lib/squeezecenter

package Slim::Utils::OS::Custom;

use strict;
use File::Spec::Functions qw(:ALL);
use FindBin qw($Bin);
use Config;

use base qw(Slim::Utils::OS::Linux);

sub initDetails {
	my $class = shift;

	$class->{osDetails} = $class->SUPER::initDetails();

	$class->{osDetails}->{isGentoo} = 1 ;

	# Make sure we can find any CPAN modules packaged with SqueezeCenter.
	unshift @INC, '/usr/share/squeezecenter/CPAN';
	
	return $class->{osDetails};
}

=head2 dirsFor( $dir )

Return OS Specific directories.

Argument $dir is a string to indicate which of the SqueezeCenter directories we
need information for.

=cut

sub dirsFor {
	my ($class, $dir) = @_;

	my @dirs = ();
	
	if ($dir eq 'oldprefs') {

		push @dirs, $class->SUPER::dirsFor($dir);

	} elsif ($dir =~ /^(?:Firmware|Graphics|HTML|IR|MySQL|SQL|lib|Bin)$/) {

		push @dirs, "/usr/share/squeezecenter/$dir";

	} elsif ($dir eq 'Plugins') {
			
		push @dirs, $class->SUPER::dirsFor($dir);
		push @dirs, "/var/lib/squeezecenter/Plugins", "/usr/lib/" . $Config{'package'} . "/vendor_perl/" . $Config{'version'} . "/Slim/Plugin";
		
	} elsif ($dir =~ /^(?:strings|revision)$/) {

		push @dirs, "/usr/share/squeezecenter";

	} elsif ($dir eq 'libpath') {

		push @dirs, "/usr/lib/squeezecenter";

	# Because we use the system MySQL, we need to point to the right
	# directory for the errmsg. files. Default to english.
	} elsif ($dir eq 'mysql-language') {

		push @dirs, "/usr/share/mysql/english";

	} elsif ($dir =~ /^(?:types|convert)$/) {

		push @dirs, "/etc/squeezecenter";

	} elsif ($dir =~ /^(?:prefs)$/) {

		push @dirs, $::prefsdir || "/var/lib/squeezecenter/prefs";

	} elsif ($dir eq 'log') {

		push @dirs, $::logdir || "/var/log/squeezecenter";

	} elsif ($dir eq 'cache') {

		push @dirs, $::cachedir || "/var/lib/squeezecenter/cache";

	} elsif ($dir =~ /^(?:music|playlists)$/) {

		push @dirs, '';

	} else {

		warn "dirsFor: Didn't find a match request: [$dir]\n";
	}

	return wantarray() ? @dirs : $dirs[0];
}

# Bug 9488, always decode on Ubuntu/Debian
sub decodeExternalHelperPath {
	return Slim::Utils::Unicode::utf8decode_locale($_[1]);
}

sub scanner {
	return '/usr/sbin/squeezecenter-scanner';
}


1;




1;

__END__
