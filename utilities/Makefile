#	@(#) $Id$
#

PACKAGE=	trs80-utilities
VERSION=	1.x

SOURCES=	amortz anagram basic bincheck border \
		cleanup cmd copyit day directory drop \
		errors fast-format fileupd format \
		gettok granules grep ifupd large-file-editor \
		memtest merge newc newjkl newsfmt \
		pack pdir peekhash prime ptrdump \
		repc report-writer rot13 \
		save screen-dump sort split superc \
		tab4 tax textdiff tune \
		unarc uncmprs uncrc waveform wc

MISC=		$(PACKAGE).html Makefile

all:
	@echo "Try make VERSION=1.x package"

package:	$(PACKAGE)-$(VERSION).tar.gz

$(PACKAGE)-$(VERSION).tar.gz:	$(SOURCES) $(MISC)
	tar -z -c -v --exclude=CVS -f $(PACKAGE)-$(VERSION).tar.gz $(MISC) $(SOURCES)
