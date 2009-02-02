# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header$

/var/log/squeezecenter/scanner.log /var/log/squeezecenter/server.log /var/log/squeezecenter/perfmon.log {
	missingok
	notifempty
	copytruncate
	rotate 5
	size 100k
}
