VM_DIR=/var/vm/squeezecenter
HDA_IMG=gentoo.cow
HDB_IMG=media.cow
VM_MEM=256
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
	echo Injecting ebuilds...
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
	$(SSH) "grep -q 'dev-perl/JSON' /etc/portage/package.keywords >/dev/null 2>&1 || echo 'dev-perl/JSON' >> /etc/portage/package.keywords"
	$(SSH) "grep -q 'dev-perl/DBI' /etc/portage/package.keywords >/dev/null 2>&1 || echo 'dev-perl/DBI ~x86' >> /etc/portage/package.keywords"
	$(SSH) "grep -q 'dev-perl/JSON-XS' /etc/portage/package.keywords >/dev/null 2>&1 || echo 'dev-perl/JSON-XS ~x86' >> /etc/portage/package.keywords"
	$(SSH) "grep -q 'dev-perl/SQL-Abstract' /etc/portage/package.keywords >/dev/null 2>&1 || echo 'dev-perl/SQL-Abstract' >> /etc/portage/package.keywords"
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
	$(SSH) "grep -q 'dev-perl/DBIx-Class' /etc/portage/package.keywords >/dev/null 2>&1 || echo 'dev-perl/DBIx-Class' >> /etc/portage/package.keywords"
	$(SSH) "grep -q 'dev-perl/JSON-Any' /etc/portage/package.keywords >/dev/null 2>&1 || echo 'dev-perl/JSON-Any' >> /etc/portage/package.keywords"
	$(SSH) "grep -q 'dev-perl/DBD-SQLite' /etc/portage/package.keywords >/dev/null 2>&1 || echo 'dev-perl/DBD-SQLite' >> /etc/portage/package.keywords"
	$(SSH) "grep -q 'dev-perl/MRO-Compat' /etc/portage/package.keywords >/dev/null 2>&1 || echo 'dev-perl/MRO-Compat' >> /etc/portage/package.keywords"
	$(SSH) "grep -q 'dev-perl/Class-C3-Componentised' /etc/portage/package.keywords >/dev/null 2>&1 || echo 'dev-perl/Class-C3-Componentised' >> /etc/portage/package.keywords"
	$(SSH) "grep -q 'dev-perl/Class-Accessor-Grouped' /etc/portage/package.keywords >/dev/null 2>&1 || echo 'dev-perl/Class-Accessor-Grouped' >> /etc/portage/package.keywords"
	$(SSH) "grep -q 'dev-perl/Module-Find' /etc/portage/package.keywords >/dev/null 2>&1 || echo 'dev-perl/Module-Find' >> /etc/portage/package.keywords"
	$(SSH) "grep -q 'dev-perl/Scope-Guard' /etc/portage/package.keywords >/dev/null 2>&1 || echo 'dev-perl/Scope-Guard' >> /etc/portage/package.keywords"
	$(SSH) "grep -q 'dev-perl/Sub-Name' /etc/portage/package.keywords >/dev/null 2>&1 || echo 'dev-perl/Sub-Name' >> /etc/portage/package.keywords"
	$(SSH) "echo 'dev-perl/GD jpeg png' >> /etc/portage/package.use"
	$(SSH) "echo 'media-libs/gd jpeg png' >> /etc/portage/package.use"
	$(SSH) "echo 'media-sound/squeezecenter flac lame aac' >> /etc/portage/package.use"
	$(SSH) "echo 'media-sound/sox flac' >> /etc/portage/package.use"

vmreset: vmstop
	echo Resetting VM...
	-rm $(VM_DIR)/$(HDA_IMG) 2>/dev/null
	pv $(VM_DIR)/$(HDA_IMG).orig.bz2 | bzcat > $(VM_DIR)/$(HDA_IMG)

vmstart:
	echo Starting VM...
	sudo kvm -curses -boot c -m $(VM_MEM) -localtime \
		-hda $(VM_DIR)/$(HDA_IMG) -hdb $(VM_DIR)/$(HDB_IMG) \
		-net nic,model=e1000 -net tap

vmstop:
	echo Stopping VM...
	-ping $(VMHOST) -w1 -q && $(SSH) poweroff

vmkill:
	echo Killing VM...
	-sudo pkill kvm

uninstall:
	-$(SSH) /etc/init.d/squeezecenter stop
	-$(SSH) emerge --unmerge squeezecenter
	-$(SSH) rm -f /etc/init.d/sqeezecenter /etc/conf.d/squeezecenter /etc/logrotate.d/squeezecenter /etc/squeezecenter.prefs
	-$(SSH) rm -fr /var/log/squeezecenter /var/cache/squeezecenter /var/lib/squeezecenter/cache /var/lib/squeezecenter/prefs /etc/squeezecenter

patches: $(PD)/$(P)-mDNSResponder-gentoo.patch $(PD)/$(P1)-build-perl-modules-gentoo.patch $(PD)/$(P1)-aac-transcode-gentoo.patch $(PD)/$(P)-json-xs-gentoo.patch $(PD)/$(P1)-xsaccessor-gentoo.patch

$(PD)/$(P)-mDNSResponder-gentoo.patch: $(PS)/Slim/Networking/mDNS.pm
	./mkpatch $@ $^

$(PD)/$(P1)-build-perl-modules-gentoo.patch: $(PS)/Slim/bootstrap.pm
	./mkpatch $@ $^

$(PD)/$(P1)-aac-transcode-gentoo.patch: $(PS)/convert.conf
	./mkpatch $@ $^

$(PD)/$(P)-json-xs-gentoo.patch: $(PS)/Slim/Formats/XML.pm $(PS)/Slim/Plugin/LastFM/ProtocolHandler.pm $(PS)/Slim/Plugin/Sirius/ProtocolHandler.pm
	./mkpatch $@ $^

$(PD)/$(P1)-xsaccessor-gentoo.patch: $(PS)/Slim/Utils/Accessor.pm
	./mkpatch $@ $^
