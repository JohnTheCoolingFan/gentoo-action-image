FROM gentoo/portage:latest as portage

FROM gentoo/stage3:latest

COPY --from=portage /var/db/repos/gentoo /var/db/repos/gentoo

RUN mv /etc/portage/make.conf /make.conf
RUN mkdir -p /etc/portage/make.conf
RUN mv /make.conf /etc/portage/make.conf/00-gentoo-defaults

COPY make.extra /etc/portage/make.conf/01-portage-defaults
COPY make.binpkg /etc/portage/make.conf/02-binpkg

RUN mkdir -p /etc/portage/repos.conf
COPY test-repo.conf /etc/portage/repos.conf/test-repo.conf
RUN mkdir -p /var/db/repos/
COPY test-repo/ /var/db/repos/test-repo/

RUN emerge --sync
RUN emerge -uDU world
RUN etc-update --automode -5
RUN emerge app-portage/eix app-portage/flaggie app-portage/gentoolkit dev-vcs/git
RUN emerge --autounmask y --autounmask-write y --autounmask-only y acct-group/docker app-misc/jq dev-util/pkgdev
RUN etc-update --automode -5
RUN emerge acct-group/docker app-misc/jq dev-util/pkgdev
RUN emerge --depclean
RUN eclean-pkg --deep
RUN eclean-dist --deep
RUN revdep-rebuild
RUN eix-update

RUN rm /etc/portage/make.conf/02-binpkg

RUN useradd -m -G users,portage,wheel,docker -s /bin/bash testrunner
RUN usermod --append --groups docker portage


CMD ["/bin/bash"]
