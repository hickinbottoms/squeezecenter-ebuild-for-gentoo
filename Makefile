VM_DIR=/var/vm/squeezecenter
HDA_IMG=gentoo.cow
HDB_IMG=media.cow
VM_MEM=256
PIDFILE=qemu.pid
VMHOST=chandra
SSH=ssh root@$(VMHOST)
SCP=scp

LOCAL_PORTAGE=/usr/local/portage
EBUILD_PREFIX=squeezecenter
EBUILD_CATEGORY=media-sound/$(EBUILD_PREFIX)
EBUILD_DIR=$(LOCAL_PORTAGE)/$(EBUILD_CATEGORY)

P=squeezecenter-7.3.2

PATCHES= mDNSResponder-gentoo.patch \
		$(P)-build-perl-modules-gentoo.patch \
		$(P)-aac-transcode-gentoo.patch \
		$(P)-json-xs-gentoo.patch

FILES=dbdrop-gentoo.sql \
	  dbcreate-gentoo.sql \
	  squeezecenter.prefs \
	  squeezecenter.init.d \
	  squeezecenter.conf.d \
	  squeezecenter.logrotate.d \
	  avahi-squeezecenter.service \
	  Gentoo-plugins-README.txt \
	  gentoo-filepaths.pm

all: inject

inject: patches
	[ -f $(PIDFILE) ] || echo error: VM not running
	[ -f $(PIDFILE) ] && echo Injecting ebuilds...
	$(SSH) "rm -r $(EBUILD_DIR)/* >/dev/null 2>&1 || true"
	$(SSH) mkdir -p $(EBUILD_DIR) $(EBUILD_DIR)/files
	$(SCP) metadata.xml *.ebuild root@$(VMHOST):$(EBUILD_DIR)
	(cd files; $(SCP) $(FILES) root@$(VMHOST):$(EBUILD_DIR)/files)
	(cd patch_dest; $(SCP) $(PATCHES) root@$(VMHOST):$(EBUILD_DIR)/files)
	./inject-vendor-src vendor-src $(VMHOST)
	$(SSH) 'cd $(EBUILD_DIR); ebuild `ls *.ebuild | head -n 1` manifest'
	echo Unmasking ebuild...
	$(SSH) mkdir -p /etc/portage
	$(SSH) "grep -q '$(EBUILD_CATEGORY)' /etc/portage/package.keywords >/dev/null 2>&1 || echo '$(EBUILD_CATEGORY) ~x86' >> /etc/portage/package.keywords"
	$(SSH) "grep -q 'dev-perl/YAML-Syck' /etc/portage/package.keywords >/dev/null 2>&1 || echo 'dev-perl/YAML-Syck ~x86' >> /etc/portage/package.keywords"
	$(SSH) "grep -q 'dev-perl/Encode-Detect' /etc/portage/package.keywords >/dev/null 2>&1 || echo 'dev-perl/Encode-Detect ~x86' >> /etc/portage/package.keywords"
	$(SSH) "grep -q 'dev-perl/DBI' /etc/portage/package.keywords >/dev/null 2>&1 || echo 'dev-perl/DBI ~x86' >> /etc/portage/package.keywords"
	$(SSH) "grep -q 'dev-perl/JSON-XS' /etc/portage/package.keywords >/dev/null 2>&1 || echo 'dev-perl/JSON-XS ~x86' >> /etc/portage/package.keywords"
	$(SSH) "grep -q 'dev-perl/SQL-Abstract-Limit' /etc/portage/package.keywords >/dev/null 2>&1 || echo 'dev-perl/SQL-Abstract-Limit' >> /etc/portage/package.keywords"
	$(SSH) "echo 'dev-perl/GD jpeg png' >> /etc/portage/package.use"
	$(SSH) "echo 'media-libs/gd jpeg png' >> /etc/portage/package.use"
	$(SSH) "echo 'media-sound/squeezecenter flac lame' >> /etc/portage/package.use"
	$(SSH) "echo 'media-sound/sox flac' >> /etc/portage/package.use"

vmreset: vmstop
	sudo ls >/dev/null
	echo Resetting VM...
	-sudo rm $(VM_DIR)/$(HDA_IMG) 2>/dev/null
	sudo sh -c "pv $(VM_DIR)/$(HDA_IMG).orig.gz | gunzip > $(VM_DIR)/$(HDA_IMG)"

vmstart:
	sudo ls >/dev/null
	echo Starting VM...
	-[ -f $(PIDFILE) ] && sudo rm $(PIDFILE)
	sudo qemu -boot c -m $(VM_MEM) -vnc :0 -kernel-kqemu -localtime -k en-gb \
		-hda $(VM_DIR)/$(HDA_IMG) -hdb $(VM_DIR)/$(HDB_IMG) \
		-pidfile $(PIDFILE) \
		-net nic -net tap&
	sleep 5
	sudo chown stuarth:users $(PIDFILE)

vmstop:
	sudo ls >/dev/null
	echo Stopping VM...
	-[ -f $(PIDFILE) ] && $(SSH) poweroff
	-[ -f $(PIDFILE) ] && export QPID=`cat $(PIDFILE)`; [ -f $(PIDFILE) ] && while [ -d /proc/$$QPID ]; do sleep 1; done

vmkill:
	sudo ls >/dev/null
	echo Killing VM...
	-[ -f $(PIDFILE) ] && xargs sudo pkill < $(PIDFILE)
	-[ -f $(PIDFILE) ] && sudo rm $(PIDFILE)

uninstall:
	[ -f $(PIDFILE) ] || echo error: VM not running
	-$(SSH) /etc/init.d/squeezecenter stop
	-$(SSH) emerge --unmerge squeezecenter
	-$(SSH) rm -f /etc/init.d/sqeezecenter /etc/conf.d/squeezecenter /etc/logrotate.d/squeezecenter /etc/squeezecenter.prefs
	-$(SSH) rm -fr /var/log/squeezecenter /var/cache/squeezecenter /var/lib/squeezecenter/cache /var/lib/squeezecenter/prefs /etc/squeezecenter

patches:
	./mkpatch mDNSResponder-gentoo.patch Slim/Networking/mDNS.pm
	./mkpatch $(P)-build-perl-modules-gentoo.patch Bin/build-perl-modules.pl Slim/bootstrap.pm
	./mkpatch $(P)-aac-transcode-gentoo.patch convert.conf
	./mkpatch $(P)-json-xs-gentoo.patch Slim/Formats/XML.pm Slim/Plugin/LastFM/ProtocolHandler.pm Slim/Plugin/Sirius/ProtocolHandler.pm
