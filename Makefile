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
PS=patch_source
PD=patch_dest

P=squeezecenter-7.3.3
P1=squeezecenter-7.3.3-r2

FILES=dbdrop-gentoo.sql \
	  dbcreate-gentoo.sql \
	  squeezecenter.prefs \
	  squeezecenter.init.d \
	  squeezecenter.conf.d \
	  squeezecenter.logrotate.d \
	  avahi-squeezecenter.service \
	  Gentoo-plugins-README.txt \
	  gentoo-filepaths.pm \
	  $(P)-squeezeslave.patch \
	  $(P)-squeezeslave-2.patch \
	  $(P)-squeezeslave-3.patch

all: inject

stage: patches
	-rm -r stage/*
	mkdir stage/files
	cp metadata.xml *.ebuild stage
	cp files/* stage/files
	cp patch_dest/* stage/files
	A=`grep '$$Id' stage/files/*.patch | wc -l`; [ $$A -eq 0 ]

inject: stage
	[ -f $(PIDFILE) ] || echo error: VM not running
	[ -f $(PIDFILE) ] && echo Injecting ebuilds...
	$(SSH) "rm -r $(EBUILD_DIR)/* >/dev/null 2>&1 || true"
	$(SSH) mkdir -p $(EBUILD_DIR) $(EBUILD_DIR)/files
	$(SCP) metadata.xml *.ebuild root@$(VMHOST):$(EBUILD_DIR)
	(cd files; $(SCP) $(FILES) root@$(VMHOST):$(EBUILD_DIR)/files)
	(cd patch_dest; $(SCP) *.patch root@$(VMHOST):$(EBUILD_DIR)/files)
	$(SSH) 'cd $(EBUILD_DIR); ebuild `ls *.ebuild | head -n 1` manifest'
	echo Unmasking ebuild...
	$(SSH) mkdir -p /etc/portage
	$(SSH) "grep -q '$(EBUILD_CATEGORY)' /etc/portage/package.keywords >/dev/null 2>&1 || echo '$(EBUILD_CATEGORY) ~x86' >> /etc/portage/package.keywords"
	$(SSH) "grep -q 'dev-perl/YAML-Syck' /etc/portage/package.keywords >/dev/null 2>&1 || echo 'dev-perl/YAML-Syck ~x86' >> /etc/portage/package.keywords"
	$(SSH) "grep -q 'dev-perl/Encode-Detect' /etc/portage/package.keywords >/dev/null 2>&1 || echo 'dev-perl/Encode-Detect ~x86' >> /etc/portage/package.keywords"
	$(SSH) "grep -q 'dev-perl/DBI' /etc/portage/package.keywords >/dev/null 2>&1 || echo 'dev-perl/DBI ~x86' >> /etc/portage/package.keywords"
	$(SSH) "grep -q 'dev-perl/JSON-XS' /etc/portage/package.keywords >/dev/null 2>&1 || echo 'dev-perl/JSON-XS ~x86' >> /etc/portage/package.keywords"
	$(SSH) "grep -q 'dev-perl/SQL-Abstract-Limit' /etc/portage/package.keywords >/dev/null 2>&1 || echo 'dev-perl/SQL-Abstract-Limit' >> /etc/portage/package.keywords"
	$(SSH) "grep -q 'dev-perl/Class-Accessor-Chained' /etc/portage/package.keywords >/dev/null 2>&1 || echo 'dev-perl/Class-Accessor-Chained' >> /etc/portage/package.keywords"
	$(SSH) "grep -q 'dev-perl/POE-XS-Queue-Array' /etc/portage/package.keywords >/dev/null 2>&1 || echo 'dev-perl/POE-XS-Queue-Array' >> /etc/portage/package.keywords"
	$(SSH) "grep -q 'dev-perl/Class-C3' /etc/portage/package.keywords >/dev/null 2>&1 || echo 'dev-perl/Class-C3' >> /etc/portage/package.keywords"
	$(SSH) "grep -q 'dev-perl/Algorithm-C3' /etc/portage/package.keywords >/dev/null 2>&1 || echo 'dev-perl/Algorithm-C3' >> /etc/portage/package.keywords"
	$(SSH) "grep -q 'dev-perl/Class-C3-XS' /etc/portage/package.keywords >/dev/null 2>&1 || echo 'dev-perl/Class-C3-XS' >> /etc/portage/package.keywords"
	$(SSH) "grep -q 'dev-perl/JSON-XS-VersionOneAndTwo' /etc/portage/package.keywords >/dev/null 2>&1 || echo 'dev-perl/JSON-XS-VersionOneAndTwo' >> /etc/portage/package.keywords"
	$(SSH) "grep -q 'dev-perl/Class-XSAccessor-Array' /etc/portage/package.keywords >/dev/null 2>&1 || echo 'dev-perl/Class-XSAccessor-Array' >> /etc/portage/package.keywords"
	$(SSH) "grep -q 'dev-perl/AutoXS-Header' /etc/portage/package.keywords >/dev/null 2>&1 || echo 'dev-perl/AutoXS-Header' >> /etc/portage/package.keywords"
	$(SSH) "grep -q 'dev-perl/File-BOM' /etc/portage/package.keywords >/dev/null 2>&1 || echo 'dev-perl/File-BOM' >> /etc/portage/package.keywords"
	$(SSH) "grep -q 'dev-perl/Class-Data-Accessor' /etc/portage/package.keywords >/dev/null 2>&1 || echo 'dev-perl/Class-Data-Accessor' >> /etc/portage/package.keywords"
	$(SSH) "grep -q 'dev-perl/Data-Page' /etc/portage/package.keywords >/dev/null 2>&1 || echo 'dev-perl/Data-Page' >> /etc/portage/package.keywords"
	$(SSH) "grep -q 'dev-perl/Data-Dump' /etc/portage/package.keywords >/dev/null 2>&1 || echo 'dev-perl/Data-Dump' >> /etc/portage/package.keywords"
	$(SSH) "grep -q 'dev-perl/enum' /etc/portage/package.keywords >/dev/null 2>&1 || echo 'dev-perl/enum' >> /etc/portage/package.keywords"
	$(SSH) "grep -q 'dev-perl/URI-Find' /etc/portage/package.keywords >/dev/null 2>&1 || echo 'dev-perl/URI-Find' >> /etc/portage/package.keywords"
	$(SSH) "grep -q 'dev-perl/Net-UPnP' /etc/portage/package.keywords >/dev/null 2>&1 || echo 'dev-perl/Net-UPnP **' >> /etc/portage/package.keywords"
	$(SSH) "grep -q 'virtual/perl-Module-Build' /etc/portage/package.keywords >/dev/null 2>&1 || echo 'virtual/perl-Module-Build' >> /etc/portage/package.keywords"
	$(SSH) "grep -q 'perl-core/Module-Build' /etc/portage/package.keywords >/dev/null 2>&1 || echo 'perl-core/Module-Build' >> /etc/portage/package.keywords"
	$(SSH) "grep -q 'virtual/perl-Test-Harness' /etc/portage/package.keywords >/dev/null 2>&1 || echo 'virtual/perl-Test-Harness' >> /etc/portage/package.keywords"
	$(SSH) "grep -q 'perl-core/Test-Harness' /etc/portage/package.keywords >/dev/null 2>&1 || echo 'perl-core/Test-Harness' >> /etc/portage/package.keywords"
	$(SSH) "grep -q 'dev-perl/Tie-Cache-LRU' /etc/portage/package.keywords >/dev/null 2>&1 || echo 'dev-perl/Tie-Cache-LRU' >> /etc/portage/package.keywords"
	$(SSH) "grep -q 'dev-perl/Tie-LLHash' /etc/portage/package.keywords >/dev/null 2>&1 || echo 'dev-perl/Tie-LLHash' >> /etc/portage/package.keywords"
	$(SSH) "grep -q 'dev-perl/Tie-RegexpHash' /etc/portage/package.keywords >/dev/null 2>&1 || echo 'dev-perl/Tie-RegexpHash' >> /etc/portage/package.keywords"
	$(SSH) "grep -q 'dev-perl/Proc-Background' /etc/portage/package.keywords >/dev/null 2>&1 || echo 'dev-perl/Proc-Background' >> /etc/portage/package.keywords"
	$(SSH) "grep -q 'dev-perl/PAR' /etc/portage/package.keywords >/dev/null 2>&1 || echo 'dev-perl/PAR' >> /etc/portage/package.keywords"
	$(SSH) "grep -q 'virtual/perl-AutoLoader' /etc/portage/package.keywords >/dev/null 2>&1 || echo 'virtual/perl-AutoLoader' >> /etc/portage/package.keywords"
	$(SSH) "grep -q 'perl-core/AutoLoader' /etc/portage/package.keywords >/dev/null 2>&1 || echo 'perl-core/AutoLoader' >> /etc/portage/package.keywords"
	$(SSH) "grep -q 'dev-perl/PAR-Dist' /etc/portage/package.keywords >/dev/null 2>&1 || echo 'dev-perl/PAR-Dist' >> /etc/portage/package.keywords"
	$(SSH) "grep -q 'dev-perl/Text-Unidecode' /etc/portage/package.keywords >/dev/null 2>&1 || echo 'dev-perl/Text-Unidecode' >> /etc/portage/package.keywords"
	$(SSH) "echo 'dev-perl/GD jpeg png' >> /etc/portage/package.use"
	$(SSH) "echo 'media-libs/gd jpeg png' >> /etc/portage/package.use"
	$(SSH) "echo 'media-sound/squeezecenter flac lame aac' >> /etc/portage/package.use"
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

patches: $(PD)/$(P)-mDNSResponder-gentoo.patch $(PD)/$(P)-build-perl-modules-gentoo.patch $(PD)/$(P1)-aac-transcode-gentoo.patch $(PD)/$(P)-json-xs-gentoo.patch $(PD)/$(P)-xsaccessor-gentoo.patch

$(PD)/$(P)-mDNSResponder-gentoo.patch: $(PS)/Slim/Networking/mDNS.pm
	./mkpatch $(PD)/$(P)-mDNSResponder-gentoo.patch $(PS)/Slim/Networking/mDNS.pm

$(PD)/$(P)-build-perl-modules-gentoo.patch: $(PS)/Slim/bootstrap.pm
	./mkpatch $(PD)/$(P)-build-perl-modules-gentoo.patch $(PS)/Slim/bootstrap.pm

$(PD)/$(P1)-aac-transcode-gentoo.patch: $(PS)/convert.conf
	./mkpatch $(PD)/$(P1)-aac-transcode-gentoo.patch $(PS)/convert.conf

$(PD)/$(P)-json-xs-gentoo.patch: $(PS)/Slim/Formats/XML.pm $(PS)/Slim/Plugin/LastFM/ProtocolHandler.pm $(PS)/Slim/Plugin/Sirius/ProtocolHandler.pm
	./mkpatch $(PD)/$(P)-json-xs-gentoo.patch $(PS)/Slim/Formats/XML.pm $(PS)/Slim/Plugin/LastFM/ProtocolHandler.pm $(PS)/Slim/Plugin/Sirius/ProtocolHandler.pm

$(PD)/$(P)-xsaccessor-gentoo.patch: $(PS)/Slim/Utils/Accessor.pm
	./mkpatch $(PD)/$(P)-xsaccessor-gentoo.patch $(PS)/Slim/Utils/Accessor.pm
