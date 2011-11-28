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
	$(SCP) package.keywords package.use package.unmask root@$(VMHOST):/etc/portage

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
