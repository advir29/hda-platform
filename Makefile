VERSION=6.2.1
ARCH=`uname -m`
RPMBASE=$(HOME)/rpmbuild

all: rpm

rpm: update-header dist
	(cd release && rpmbuild -ta hda-platform-$(VERSION).tar.gz)
	mv $(RPMBASE)/RPMS/$(ARCH)/hda-platform-$(VERSION)-*.$(ARCH).rpm release/
	mv $(RPMBASE)/SRPMS/hda-platform-$(VERSION)-*.src.rpm release/

deb: update-header dist
	(cd release && ln -sf hda-platform-$(VERSION).tar.gz hda-platform_$(VERSION).orig.tar.gz)
	(cd release && tar -zxf hda-platform_$(VERSION).orig.tar.gz)
	(cd release/hda-platform-$(VERSION)/debian && debuild -us -uc && debuild -S -us -uc)

dist: clean
	(cd html/tmp/cache/ && rm -rf *)
	(mkdir -p release && cd release && mkdir -p hda-platform-$(VERSION))
	(cd html/log && echo -n > production.log && echo -n > development.log && echo -n > test.log)
	rsync -a debian pdc hda-usermap hda-gems-install hda-platform.spec hda-create-db-and-user html fonts \
		hda-refresh-shares hda-update-webapps webapps hda-diskmount amahi-download \
		hda-add-apache-sudoers release/hda-platform-$(VERSION)/
	(cd release && tar -czvf hda-platform-$(VERSION).tar.gz hda-platform-$(VERSION))
	(cd release && rm -rf hda-platform-$(VERSION))

update-header:
	sed -i -e 's/^Version:\s*[0-9.]*\s*$$/Version: $(VERSION)/' hda-platform.spec

install: rpm
	(cd release && sudo rpm -Uvh hda-platform-$(VERSION)-*.$(ARCH).rpm)

clean:
	find . -name '._*' -exec rm '{}' \;
	(cd html/vendor/bundle/ruby/1.9.1/gems/unicorn-* && \
	find . -type f -exec grep -l '/this/will/be/overwritten/or/wrapped/anyways/do/not/worry/ruby' {} \; | \
	xargs sed -i -e 's|/this/will/be/overwritten/or/wrapped/anyways/do/not/worry/ruby|/usr/bin/ruby|') || true

