VM_DIR=/var/vm/squeezecenter
HDA_IMG=gentoo.cow
HDB_IMG=media.cow
VM_MEM=256
PIDFILE=qemu.pid
VMHOST=chandra

LOCAL_PORTAGE=/usr/local/portage
EBUILD_PREFIX=squeezecenter
EBUILD_CATEGORY=media-sound/$(EBUILD_PREFIX)
EBUILD_DIR=$(LOCAL_PORTAGE)/$(EBUILD_CATEGORY)

PATCHES= mDNSResponder-gentoo.patch \
		filepaths-gentoo.patch \build-perl-modules-gentoo.patch

FILES=dbdrop-gentoo.sql \
	  dbcreate-gentoo.sql \
	  squeezecenter.prefs \
	  squeezecenter.init.d \
	  squeezecenter.conf.d \
	  squeezecenter.logrotate.d \
	  avahi-squeezecenter.service \
	  Gentoo-plugins-README.txt

all: inject

inject: patches
	[ -f $(PIDFILE) ] || echo error: VM not running
	[ -f $(PIDFILE) ] && echo Injecting ebuilds...
	ssh root@$(VMHOST) "rm -r $(EBUILD_DIR)/* >/dev/null 2>&1 || true"
	ssh root@$(VMHOST) mkdir -p $(EBUILD_DIR) $(EBUILD_DIR)/files
	scp metadata.xml *.ebuild root@$(VMHOST):$(EBUILD_DIR)
	(cd files; scp $(FILES) root@$(VMHOST):$(EBUILD_DIR)/files)
	(cd patch_dest; scp $(PATCHES) root@$(VMHOST):$(EBUILD_DIR)/files)
	./inject-vendor-src vendor-src $(VMHOST)
	ssh root@$(VMHOST) 'cd $(EBUILD_DIR); ebuild `ls *.ebuild | head -n 1` manifest'
	echo Unmasking ebuild...
	ssh root@$(VMHOST) mkdir -p /etc/portage
	ssh root@$(VMHOST) "grep -q '$(EBUILD_CATEGORY)' /etc/portage/package.keywords >/dev/null 2>&1 || echo '$(EBUILD_CATEGORY) ~x86' >> /etc/portage/package.keywords"
	ssh root@$(VMHOST) "echo 'dev-perl/GD jpeg png' >> /etc/portage/package.use"
	ssh root@$(VMHOST) "echo 'media-libs/gd jpeg png' >> /etc/portage/package.use"
	ssh root@$(VMHOST) "echo 'media-sound/squeezecenter flac lame' >> /etc/portage/package.use"

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
	-[ -f $(PIDFILE) ] && ssh root@$(VMHOST) poweroff
	-[ -f $(PIDFILE) ] && export QPID=`cat $(PIDFILE)`; [ -f $(PIDFILE) ] && while [ -d /proc/$$QPID ]; do sleep 1; done

vmkill:
	sudo ls >/dev/null
	echo Killing VM...
	-[ -f $(PIDFILE) ] && xargs sudo pkill < $(PIDFILE)
	-[ -f $(PIDFILE) ] && sudo rm $(PIDFILE)

uninstall:
	[ -f $(PIDFILE) ] || echo error: VM not running
	-ssh root@$(VMHOST) /etc/init.d/squeezecenter stop
	-ssh root@$(VMHOST) emerge --unmerge squeezecenter
	-ssh root@$(VMHOST) rm -f /etc/init.d/sqeezecenter /etc/conf.d/squeezecenter /etc/logrotate.d/squeezecenter /etc/squeezecenter.prefs
	-ssh root@$(VMHOST) rm -fr /var/log/squeezecenter /var/cache/squeezecenter /var/lib/squeezecenter/cache /var/lib/squeezecenter/prefs /etc/squeezecenter

patches:
	./mkpatch mDNSResponder-gentoo.patch Slim/Networking/mDNS.pm
	./mkpatch filepaths-gentoo.patch Slim/Utils/OSDetect.pm Slim/Music/Import.pm Slim/bootstrap.pm Slim/Utils/MySQLHelper.pm
	./mkpatch build-perl-modules-gentoo.patch Bin/build-perl-modules.pl
