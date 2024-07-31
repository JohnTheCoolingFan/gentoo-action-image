# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

DESCRIPTION="A library script to assist in writing GitHub Actions for Gentoo Linux"
HOMEPAGE="https://github.com/JohnTheCoolingFan/gentoo-github-action-lib"
LICENSE="LGPL-3"

if [[ ${PV} = *9999* ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/JohnTheCoolingFan/gentoo-github-action-lib"
	EGIT_BRANCH="master"
else
	SRC_URI="https://github.com/JohnTheCoolingFan/gentoo-github-action-lib/archive/${PV}.tar.gz -> ${P}.tar.gz"
fi

KEYWORDS=""
IUSE="test"
SLOT="0"

RESTRICT="!test? ( test )"

RDEPEND="app-misc/jq
	app-portage/gentoolbox"
DEPEND="test? (
	${RDEPEND}
	dev-util/bats-assert
	dev-util/bats-file
)"

src_test() {
	bats --tap tests || die "Tests failed"
}

src_install() {
	einstalldocs

	insinto /usr/lib
	doins usr/lib/*
}
