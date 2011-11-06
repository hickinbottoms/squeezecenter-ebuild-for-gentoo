VM_DIR=/var/vm/squeezeboxserver
HDA_IMG=gentoo.cow
HDB_IMG=media.cow
VM_MEM=256
VMHOST=chandra
#VMHOST=192.168.100.17
IDENT_HOST=chandra
SSH=ssh root@$(VMHOST) -i ~/.ssh/$(IDENT_HOST)
SCP=scp -i ~/.ssh/$(IDENT_HOST)

LOCAL_PORTAGE=/usr/local/portage
EBUILD_PREFIX=squeezeboxserver
EBUILD_CATEGORY=media-sound/$(EBUILD_PREFIX)
EBUILD_DIR=$(LOCAL_PORTAGE)/$(EBUILD_CATEGORY)
PS=patch_source
PD=patch_dest

PV=7.6.1
P1=squeezeboxserver-$(PV)

FILES=dbdrop-gentoo.sql \
	  dbcreate-gentoo.sql \
	  squeezeboxserver.prefs \
	  squeezeboxserver.init.d \
	  squeezeboxserver.conf.d \
	  squeezeboxserver.logrotate.d \
	  Gentoo-plugins-README.txt \
	  gentoo-filepaths.pm \
	  build-modules-$(PV).sh \
	  Gentoo-detailed-changelog.txt

all: inject

stage: patches
	-rm -r stage/*
	mkdir stage/files
	cp metadata.xml *.ebuild stage
	cp files/* stage/files
	cp patch_dest/* stage/files
	A=`grep '$$Id' stage/files/*.patch | wc -l`; [ $$A -eq 0 ]

inject: stage
	echo Injecting vendor source...
	./inject-vendor-src vendor-src $(VMHOST) $(IDENT_HOST)
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
	$(SSH) "grep -q 'dev-perl/MRO-Compat ' /etc/portage/package.keywords >/dev/null 2>&1 || echo 'dev-perl/MRO-Compat ~x86' >> /etc/portage/package.keywords"
	$(SSH) "grep -q 'dev-perl/DBIx-Class ' /etc/portage/package.keywords >/dev/null 2>&1 || echo 'dev-perl/DBIx-Class ~x86' >> /etc/portage/package.keywords"
	$(SSH) "grep -q 'dev-perl/Class-Inspector ' /etc/portage/package.keywords >/dev/null 2>&1 || echo 'dev-perl/Class-Inspector ~x86' >> /etc/portage/package.keywords"
	$(SSH) "grep -q 'dev-perl/DBD-SQLite ' /etc/portage/package.keywords >/dev/null 2>&1 || echo 'dev-perl/DBD-SQLite ~x86' >> /etc/portage/package.keywords"
	$(SSH) "grep -q 'dev-perl/Class-DBI-Plugin-DeepAbstractSearch ' /etc/portage/package.keywords >/dev/null 2>&1 || echo 'dev-perl/Class-DBI-Plugin-DeepAbstractSearch ~x86' >> /etc/portage/package.keywords"
	$(SSH) "grep -q 'dev-perl/Class-Accessor-Grouped ' /etc/portage/package.keywords >/dev/null 2>&1 || echo 'dev-perl/Class-Accessor-Grouped ~x86' >> /etc/portage/package.keywords"
	$(SSH) "grep -q 'dev-perl/Hash-Merge ' /etc/portage/package.keywords >/dev/null 2>&1 || echo 'dev-perl/Hash-Merge ~x86' >> /etc/portage/package.keywords"
	$(SSH) "grep -q 'dev-perl/Carp-Clan ' /etc/portage/package.keywords >/dev/null 2>&1 || echo 'dev-perl/Carp-Clan ~x86' >> /etc/portage/package.keywords"
	$(SSH) "grep -q 'dev-perl/Date-Simple ' /etc/portage/package.keywords >/dev/null 2>&1 || echo 'dev-perl/Date-Simple ~x86' >> /etc/portage/package.keywords"
	$(SSH) "grep -q 'dev-perl/DateTime-Format-SQLite ' /etc/portage/package.keywords >/dev/null 2>&1 || echo 'dev-perl/DateTime-Format-SQLite ~x86' >> /etc/portage/package.keywords"
	$(SSH) "grep -q 'dev-perl/Data-Dumper-Concise ' /etc/portage/package.keywords >/dev/null 2>&1 || echo 'dev-perl/Data-Dumper-Concise ~x86' >> /etc/portage/package.keywords"
	$(SSH) "grep -q 'dev-perl/JSON-Any ' /etc/portage/package.keywords >/dev/null 2>&1 || echo 'dev-perl/JSON-Any ~x86' >> /etc/portage/package.keywords"
	$(SSH) "grep -q 'dev-perl/SQL-Translator ' /etc/portage/package.keywords >/dev/null 2>&1 || echo 'dev-perl/SQL-Translator ~x86' >> /etc/portage/package.keywords"
	$(SSH) "grep -q 'dev-perl/Data-Page ' /etc/portage/package.keywords >/dev/null 2>&1 || echo 'dev-perl/Data-Page ~x86' >> /etc/portage/package.keywords"
	$(SSH) "grep -q 'dev-perl/Time-Piece-MySQL ' /etc/portage/package.keywords >/dev/null 2>&1 || echo 'dev-perl/Time-Piece-MySQL ~x86' >> /etc/portage/package.keywords"
	$(SSH) "grep -q 'dev-perl/Class-Accessor-Chained ' /etc/portage/package.keywords >/dev/null 2>&1 || echo 'dev-perl/Class-Accessor-Chained ~x86' >> /etc/portage/package.keywords"
	$(SSH) "grep -q 'dev-perl/Parse-RecDescent ' /etc/portage/package.keywords >/dev/null 2>&1 || echo 'dev-perl/Parse-RecDescent ~x86' >> /etc/portage/package.keywords"
	$(SSH) "grep -q 'dev-perl/Digest-SHA1 ' /etc/portage/package.keywords >/dev/null 2>&1 || echo 'dev-perl/Digest-SHA1 ~x86' >> /etc/portage/package.keywords"
	$(SSH) "grep -q 'dev-perl/Class-Base ' /etc/portage/package.keywords >/dev/null 2>&1 || echo 'dev-perl/Class-Base ~x86' >> /etc/portage/package.keywords"
	$(SSH) "grep -q 'dev-perl/File-ShareDir ' /etc/portage/package.keywords >/dev/null 2>&1 || echo 'dev-perl/File-ShareDir ~x86' >> /etc/portage/package.keywords"
	$(SSH) "grep -q 'dev-perl/JSON ' /etc/portage/package.keywords >/dev/null 2>&1 || echo 'dev-perl/JSON ~x86' >> /etc/portage/package.keywords"
	$(SSH) "grep -q 'dev-perl/DateTime ' /etc/portage/package.keywords >/dev/null 2>&1 || echo 'dev-perl/DateTime ~x86' >> /etc/portage/package.keywords"
	$(SSH) "grep -q 'dev-perl/DateTime-Format-Builder ' /etc/portage/package.keywords >/dev/null 2>&1 || echo 'dev-perl/DateTime-Format-Builder ~x86' >> /etc/portage/package.keywords"
	$(SSH) "grep -q 'dev-perl/DateTime-Format-Strptime ' /etc/portage/package.keywords >/dev/null 2>&1 || echo 'dev-perl/DateTime-Format-Strptime ~x86' >> /etc/portage/package.keywords"
	$(SSH) "grep -q 'dev-perl/Params-Validate ' /etc/portage/package.keywords >/dev/null 2>&1 || echo 'dev-perl/Params-Validate ~x86' >> /etc/portage/package.keywords"
	$(SSH) "grep -q 'virtual/perl-Module-Build ' /etc/portage/package.keywords >/dev/null 2>&1 || echo 'virtual/perl-Module-Build ~x86' >> /etc/portage/package.keywords"
	$(SSH) "grep -q 'virtual/perl-ExtUtils-CBuilder ' /etc/portage/package.keywords >/dev/null 2>&1 || echo 'virtual/perl-ExtUtils-CBuilder ~x86' >> /etc/portage/package.keywords"
	$(SSH) "grep -q 'perl-core/ExtUtils-CBuilder ' /etc/portage/package.keywords >/dev/null 2>&1 || echo 'perl-core/ExtUtils-CBuilder ~x86' >> /etc/portage/package.keywords"
	$(SSH) "grep -q 'dev-perl/YAML-Tiny ' /etc/portage/package.keywords >/dev/null 2>&1 || echo 'dev-perl/YAML-Tiny ~x86' >> /etc/portage/package.keywords"
	$(SSH) "grep -q 'virtual/perl-ExtUtils-ParseXS ' /etc/portage/package.keywords >/dev/null 2>&1 || echo 'virtual/perl-ExtUtils-ParseXS ~x86' >> /etc/portage/package.keywords"
	$(SSH) "grep -q 'perl-core/ExtUtils-ParseXS ' /etc/portage/package.keywords >/dev/null 2>&1 || echo 'perl-core/ExtUtils-ParseXS ~x86' >> /etc/portage/package.keywords"
	$(SSH) "grep -q 'virtual/perl-Attribute-Handlers ' /etc/portage/package.keywords >/dev/null 2>&1 || echo 'virtual/perl-Attribute-Handlers ~x86' >> /etc/portage/package.keywords"
	$(SSH) "grep -q 'perl-core/Attribute-Handlers ' /etc/portage/package.keywords >/dev/null 2>&1 || echo 'perl-core/Attribute-Handlers ~x86' >> /etc/portage/package.keywords"
	$(SSH) "grep -q 'dev-perl/JSON-XS-VersionOneAndTwo ' /etc/portage/package.keywords >/dev/null 2>&1 || echo 'dev-perl/JSON-XS-VersionOneAndTwo ~x86' >> /etc/portage/package.keywords"
	$(SSH) "grep -q 'dev-perl/DateTime-TimeZone ' /etc/portage/package.keywords >/dev/null 2>&1 || echo 'dev-perl/DateTime-TimeZone ~x86' >> /etc/portage/package.keywords"
	$(SSH) "grep -q 'dev-perl/Class-DBI-Plugin ' /etc/portage/package.keywords >/dev/null 2>&1 || echo 'dev-perl/Class-DBI-Plugin ~x86' >> /etc/portage/package.keywords"
	$(SSH) "grep -q 'perl-core/Module-Build ' /etc/portage/package.keywords >/dev/null 2>&1 || echo 'perl-core/Module-Build ~x86' >> /etc/portage/package.keywords"
	$(SSH) "grep -q 'dev-perl/Class-C3-Componentised ' /etc/portage/package.keywords >/dev/null 2>&1 || echo 'dev-perl/Class-C3-Componentised ~x86' >> /etc/portage/package.keywords"
	$(SSH) "grep -q 'dev-perl/Audio-Scan ' /etc/portage/package.keywords >/dev/null 2>&1 || echo 'dev-perl/Audio-Scan ~x86' >> /etc/portage/package.keywords"
	$(SSH) "grep -q 'dev-perl/Context-Preserve ' /etc/portage/package.keywords >/dev/null 2>&1 || echo 'dev-perl/Context-Preserve ~x86' >> /etc/portage/package.keywords"
	$(SSH) "grep -q 'dev-perl/Path-Class ' /etc/portage/package.keywords >/dev/null 2>&1 || echo 'dev-perl/Path-Class ~x86' >> /etc/portage/package.keywords"
	$(SSH) "grep -q 'dev-perl/PAR ' /etc/portage/package.keywords >/dev/null 2>&1 || echo 'dev-perl/PAR ~x86' >> /etc/portage/package.keywords"
	$(SSH) "grep -q 'virtual/perl-AutoLoader ' /etc/portage/package.keywords >/dev/null 2>&1 || echo 'virtual/perl-AutoLoader ~x86' >> /etc/portage/package.keywords"
	$(SSH) "grep -q 'perl-core/AutoLoader ' /etc/portage/package.keywords >/dev/null 2>&1 || echo 'perl-core/AutoLoader ~x86' >> /etc/portage/package.keywords"
	$(SSH) "grep -q 'dev-perl/URI-Find ' /etc/portage/package.keywords >/dev/null 2>&1 || echo 'dev-perl/URI-Find ~x86' >> /etc/portage/package.keywords"
	$(SSH) "grep -q 'dev-perl/Algorithm-C3 ' /etc/portage/package.keywords >/dev/null 2>&1 || echo 'dev-perl/Algorithm-C3 ~x86' >> /etc/portage/package.keywords"
	$(SSH) "grep -q 'dev-perl/Text-Unidecode ' /etc/portage/package.keywords >/dev/null 2>&1 || echo 'dev-perl/Text-Unidecode ~x86' >> /etc/portage/package.keywords"
	$(SSH) "grep -q 'dev-perl/Net-UPnP ' /etc/portage/package.keywords >/dev/null 2>&1 || echo 'dev-perl/Net-UPnP ~x86' >> /etc/portage/package.keywords"
	$(SSH) "grep -q 'dev-perl/File-BOM ' /etc/portage/package.keywords >/dev/null 2>&1 || echo 'dev-perl/File-BOM ~x86' >> /etc/portage/package.keywords"
	$(SSH) "grep -q 'dev-perl/Proc-Background ' /etc/portage/package.keywords >/dev/null 2>&1 || echo 'dev-perl/Proc-Background ~x86' >> /etc/portage/package.keywords"
	$(SSH) "grep -q 'dev-perl/Tie-Cache-LRU ' /etc/portage/package.keywords >/dev/null 2>&1 || echo 'dev-perl/Tie-Cache-LRU ~x86' >> /etc/portage/package.keywords"
	$(SSH) "grep -q 'dev-perl/Tie-Cache-LRU-Expires ' /etc/portage/package.keywords >/dev/null 2>&1 || echo 'dev-perl/Tie-Cache-LRU-Expires ~x86' >> /etc/portage/package.keywords"
	$(SSH) "grep -q 'dev-perl/Data-Dump ' /etc/portage/package.keywords >/dev/null 2>&1 || echo 'dev-perl/Data-Dump ~x86' >> /etc/portage/package.keywords"
	$(SSH) "grep -q 'dev-perl/Data-Page ' /etc/portage/package.keywords >/dev/null 2>&1 || echo 'dev-perl/Data-Page ~x86' >> /etc/portage/package.keywords"
	$(SSH) "grep -q 'dev-perl/Data-URIEncode ' /etc/portage/package.keywords >/dev/null 2>&1 || echo 'dev-perl/Data-URIEncode ~x86' >> /etc/portage/package.keywords"
	$(SSH) "grep -q 'dev-db/sqlite ' /etc/portage/package.keywords >/dev/null 2>&1 || echo 'dev-db/sqlite ~x86' >> /etc/portage/package.keywords"
	$(SSH) "grep -q 'dev-perl/enum ' /etc/portage/package.keywords >/dev/null 2>&1 || echo 'dev-perl/enum ~x86' >> /etc/portage/package.keywords"
	$(SSH) "grep -q 'dev-perl/Tie-LLHash ' /etc/portage/package.keywords >/dev/null 2>&1 || echo 'dev-perl/Tie-LLHash ~x86' >> /etc/portage/package.keywords"
	$(SSH) "grep -q 'dev-perl/Tie-RegexpHash ' /etc/portage/package.keywords >/dev/null 2>&1 || echo 'dev-perl/Tie-RegexpHash ~x86' >> /etc/portage/package.keywords"
	$(SSH) "grep -q 'dev-perl/Class-Load ' /etc/portage/package.keywords >/dev/null 2>&1 || echo 'dev-perl/Class-Load ~x86' >> /etc/portage/package.keywords"
	$(SSH) "grep -q 'dev-perl/Getopt-Long-Descriptive ' /etc/portage/package.keywords >/dev/null 2>&1 || echo 'dev-perl/Getopt-Long-Descriptive ~x86' >> /etc/portage/package.keywords"
	$(SSH) "grep -q 'dev-perl/Math-Round ' /etc/portage/package.keywords >/dev/null 2>&1 || echo 'dev-perl/Math-Round ~x86' >> /etc/portage/package.keywords"
	$(SSH) "grep -q 'dev-perl/strictures ' /etc/portage/package.keywords >/dev/null 2>&1 || echo 'dev-perl/strictures ~x86' >> /etc/portage/package.keywords"
	$(SSH) "grep -q 'dev-perl/Class-Method-Modifiers ' /etc/portage/package.keywords >/dev/null 2>&1 || echo 'dev-perl/Class-Method-Modifiers ~x86' >> /etc/portage/package.keywords"
	$(SSH) "grep -q 'dev-perl/Moo ' /etc/portage/package.keywords >/dev/null 2>&1 || echo 'dev-perl/Moo ~x86' >> /etc/portage/package.keywords"
	$(SSH) "echo 'dev-perl/GD jpeg png' >> /etc/portage/package.use"
	$(SSH) "echo 'media-sound/squeezeboxserver flac lame aac' >> /etc/portage/package.use"
	$(SSH) "echo 'media-libs/gd jpeg png' >> /etc/portage/package.use"
	$(SSH) "echo 'media-sound/sox flac' >> /etc/portage/package.use"
	$(SSH) "echo 'dev-db/sqlite extensions' >> /etc/portage/package.use"

vmreset: vmstop
	echo Resetting VM...
	-rm $(VM_DIR)/$(HDA_IMG) 2>/dev/null
	pv $(VM_DIR)/$(HDA_IMG).orig.xz | xzcat > $(VM_DIR)/$(HDA_IMG)

vmstart:
	sudo echo Starting VM...
	-ping $(VMHOST) -w1 -q && exit 1
	sudo nohup kvm -boot c -m $(VM_MEM) -localtime \
		-hda $(VM_DIR)/$(HDA_IMG) -hdb $(VM_DIR)/$(HDB_IMG) \
		-net nic,model=e1000 -net tap -vnc localhost:1 &
	sleep 1
	sudo rm nohup.out
	while ! ping -w1 -q $(VMHOST); do echo Waiting for host to come up...; sleep 1; done
	echo Host up... Waiting for SSH server to start
	sleep 10
	ssh root@chandra

vmstop:
	echo Stopping VM...
	-ping $(VMHOST) -w1 -q && $(SSH) poweroff

vmkill:
	echo Killing VM...
	-sudo pkill kvm

vmsq:
	ssh -i ~/.ssh/chandra root@chandra "/etc/init.d/squeezeboxserver stop; /etc/init.d/squeezeboxserver zap; rm /var/log/squeezeboxserver/server.log; rm /var/log/squeezeboxserver/scanner.log; touch /var/log/squeezeboxserver/server.log /var/log/squeezeboxserver/scanner.log; chown squeezeboxserver:squeezeboxserver /var/log/squeezeboxserver/scanner.log /var/log/squeezeboxserver/server.log; /etc/init.d/squeezeboxserver start; sleep 5; tail -F /var/log/squeezeboxserver/server.log"

uninstall:
	-$(SSH) /etc/init.d/squeezeboxserver stop
	-$(SSH) emerge --unmerge squeezeboxserver
	-$(SSH) rm -f /etc/init.d/sqeezecenter /etc/conf.d/squeezeboxserver /etc/logrotate.d/squeezeboxserver /etc/squeezeboxserver.prefs
	-$(SSH) rm -fr /var/log/squeezeboxserver /var/cache/squeezeboxserver /var/lib/squeezeboxserver/cache /var/lib/squeezeboxserver/prefs /etc/squeezeboxserver

patches: $(PD)/$(P1)-build-perl-modules-gentoo.patch $(PD)/$(P1)-uuid-gentoo.patch

$(PD)/$(P1)-build-perl-modules-gentoo.patch: $(PS)/Slim/bootstrap.pm
	./mkpatch $@ $^

$(PD)/$(P1)-uuid-gentoo.patch: $(PS)/slimserver.pl
	./mkpatch $@ $^
