#	@(#) $Id$
#

PACKAGE=	trs80-printer-utils
VERSION=	1.x

SOURCES=	driver pcopy pfilt ptrfilt spool

MISC=		$(PACKAGE).html Makefile

all:
	@echo "Try make VERSION=1.x package"

package:	$(PACKAGE)-$(VERSION).tar.gz

$(PACKAGE)-$(VERSION).tar.gz:	$(SOURCES) $(MISC)
	tar -z -c -v --exclude=CVS -f $(PACKAGE)-$(VERSION).tar.gz $(MISC) $(SOURCES)
