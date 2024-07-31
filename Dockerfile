FROM gentoo/portage:latest as portage

FROM gentoo/stage3:latest

# Copy over gentoo repo
COPY --from=portage /var/db/repos/gentoo /var/db/repos/gentoo

# Make.conf layout adjustments
RUN mv /etc/portage/make.conf /make.conf
RUN mkdir -p /etc/portage/make.conf
RUN mv /make.conf /etc/portage/make.conf/00-gentoo-defaults

# Custom options
COPY make.extra /etc/portage/make.conf/01-portage-defaults
COPY make.binpkg /etc/portage/make.conf/02-binpkg

# Add the test repo
RUN mkdir -p /etc/portage/repos.conf
COPY test-repo.conf /etc/portage/repos.conf/test-repo.conf
RUN mkdir -p /var/db/repos/
COPY test-repo/ /var/db/repos/test-repo/

# Update local repos
RUN emerge --sync
RUN emerge -uDU world
RUN etc-update --automode -5

# Install necessary tools
RUN emerge app-portage/eix app-portage/flaggie app-portage/gentoolkit dev-vcs/git
# Adjust configuration to install further tools
RUN emerge --autounmask y --autounmask-write y --autounmask-only y acct-group/docker app-misc/jq dev-util/pkgdev app-portage/gentoolbox dev-libs/github-action-lib
RUN etc-update --automode -5
# Install the tools
RUN emerge acct-group/docker app-misc/jq dev-util/pkgdev app-portage/gentoolbox dev-libs/github-action-lib

# Clean and update cache
RUN emerge --depclean
RUN eclean-pkg --deep
RUN eclean-dist --deep
RUN revdep-rebuild
RUN eix-update

# Remove binary package requirement
RUN rm /etc/portage/make.conf/02-binpkg

# Add a testrunner user and add portage to docker group
RUN useradd -m -G users,portage,wheel,docker -s /bin/bash testrunner
RUN usermod --append --groups docker portage

# Copy additional script tools
COPY tools/sed-or-die /usr/local/sbin/sed-or-die
COPY tools/unstable_keywords /usr/local/sbin/unstable_keywords
RUN chmod +x /usr/local/sbin/*

CMD ["/bin/bash"]
