VM_DIR=/var/vm/squeezeboxserver
HDA_IMG=gentoo.cow
HDB_IMG=media.cow
VM_MEM=256
VMHOST=chandra
SSH=ssh root@$(VMHOST)
SCP=scp

LOCAL_PORTAGE=/usr/local/portage
EBUILD_PREFIX=squeezeboxserver
EBUILD_CATEGORY=media-sound/$(EBUILD_PREFIX)
EBUILD_DIR=$(LOCAL_PORTAGE)/$(EBUILD_CATEGORY)
PS=patch_source
PD=patch_dest

P1=squeezeboxserver-7.4.0_beta

FILES=dbdrop-gentoo.sql \
	  dbcreate-gentoo.sql \
	  squeezeboxserver.prefs \
	  squeezeboxserver.init.d \
	  squeezeboxserver.conf.d \
	  squeezeboxserver.logrotate.d \
	  avahi-squeezeboxserver.service \
	  Gentoo-plugins-README.txt \
	  gentoo-filepaths.pm

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
	$(SSH) "grep -q 'dev-perl/DBI' /etc/portage/package.keywords >/dev/null 2>&1 || echo 'dev-perl/DBI ~x86' >> /etc/portage/package.keywords"
	$(SSH) "grep -q 'dev-perl/JSON-XS' /etc/portage/package.keywords >/dev/null 2>&1 || echo 'dev-perl/JSON-XS ~x86' >> /etc/portage/package.keywords"
	$(SSH) "grep -q 'dev-perl/common-sense' /etc/portage/package.keywords >/dev/null 2>&1 || echo 'dev-perl/common-sense ~x86' >> /etc/portage/package.keywords"
	$(SSH) "grep -q 'dev-perl/SQL-Abstract' /etc/portage/package.keywords >/dev/null 2>&1 || echo 'dev-perl/SQL-Abstract ~x86' >> /etc/portage/package.keywords"
	$(SSH) "grep -q 'dev-perl/SQL-Abstract-Limit' /etc/portage/package.keywords >/dev/null 2>&1 || echo 'dev-perl/SQL-Abstract-Limit ~x86' >> /etc/portage/package.keywords"
	$(SSH) "grep -q 'dev-perl/AnyEvent' /etc/portage/package.keywords >/dev/null 2>&1 || echo 'dev-perl/AnyEvent ~x86' >> /etc/portage/package.keywords"
	$(SSH) "grep -q 'dev-perl/Sub-Name' /etc/portage/package.keywords >/dev/null 2>&1 || echo 'dev-perl/Sub-Name ~x86' >> /etc/portage/package.keywords"
	$(SSH) "grep -q 'dev-perl/GD' /etc/portage/package.keywords >/dev/null 2>&1 || echo 'dev-perl/GD ~x86' >> /etc/portage/package.keywords"
	$(SSH) "grep -q 'dev-perl/Module-Find' /etc/portage/package.keywords >/dev/null 2>&1 || echo 'dev-perl/Module-Find ~x86' >> /etc/portage/package.keywords"
	$(SSH) "grep -q 'dev-perl/Class-XSAccessor' /etc/portage/package.keywords >/dev/null 2>&1 || echo 'dev-perl/Class-XSAccessor ~x86' >> /etc/portage/package.keywords"
	$(SSH) "grep -q 'dev-perl/Class-XSAccessor-Array' /etc/portage/package.keywords >/dev/null 2>&1 || echo 'dev-perl/Class-XSAccessor-Array ~x86' >> /etc/portage/package.keywords"
	$(SSH) "grep -q 'dev-perl/AutoXS-Header' /etc/portage/package.keywords >/dev/null 2>&1 || echo 'dev-perl/AutoXS-Header ~x86' >> /etc/portage/package.keywords"
	$(SSH) "grep -q 'dev-perl/Scope-Guard ' /etc/portage/package.keywords >/dev/null 2>&1 || echo 'dev-perl/Scope-Guard ~x86' >> /etc/portage/package.keywords"
	$(SSH) "grep -q 'dev-perl/Class-C3-XS ' /etc/portage/package.keywords >/dev/null 2>&1 || echo 'dev-perl/Class-C3-XS ~x86' >> /etc/portage/package.keywords"
	$(SSH) "grep -q 'dev-perl/Class-C3 ' /etc/portage/package.keywords >/dev/null 2>&1 || echo 'dev-perl/Class-C3 ~x86' >> /etc/portage/package.keywords"
	$(SSH) "grep -q 'dev-perl/Class-C3-Componentised ' /etc/portage/package.keywords >/dev/null 2>&1 || echo 'dev-perl/Class-C3-Componentised ~x86' >> /etc/portage/package.keywords"
	$(SSH) "echo 'dev-perl/GD jpeg png' >> /etc/portage/package.use"
	$(SSH) "echo 'media-sound/squeezeboxserver flac lame aac' >> /etc/portage/package.use"
	$(SSH) "echo 'media-libs/gd jpeg png' >> /etc/portage/package.use"
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
	-$(SSH) /etc/init.d/squeezeboxserver stop
	-$(SSH) emerge --unmerge squeezeboxserver
	-$(SSH) rm -f /etc/init.d/sqeezecenter /etc/conf.d/squeezeboxserver /etc/logrotate.d/squeezeboxserver /etc/squeezeboxserver.prefs
	-$(SSH) rm -fr /var/log/squeezeboxserver /var/cache/squeezeboxserver /var/lib/squeezeboxserver/cache /var/lib/squeezeboxserver/prefs /etc/squeezeboxserver

patches: $(PD)/$(P1)-build-perl-modules-gentoo.patch

$(PD)/$(P1)-build-perl-modules-gentoo.patch: $(PS)/Slim/bootstrap.pm
	./mkpatch $@ $^
