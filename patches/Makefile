#	@(#) $Id$
#

PACKAGE=	trs80-patches
VERSION=	1.x

SOURCES=	asylum edtasm edtasm-plus eliminator fortran-80 fs1 \
		microsoft-adventure nedas scripsit

MISC=		$(PACKAGE).html Makefile

all:
	@echo "Try make VERSION=1.x package"

package:	$(PACKAGE)-$(VERSION).tar.gz

$(PACKAGE)-$(VERSION).tar.gz:	$(SOURCES) $(MISC)
	tar -z -c -v --exclude=CVS -f $(PACKAGE)-$(VERSION).tar.gz $(MISC) $(SOURCES)
