#	@(#) $Id$
#

PACKAGE=	trs80-assignment
VERSION=	1.x

SOURCES=	cpx os pt sim

MISC=		Makefile $(PACKAGE).html

all:
	@echo "Try make VERSION=1.x package"

package:	$(PACKAGE)-$(VERSION).tar.gz

$(PACKAGE)-$(VERSION).tar.gz:	$(SOURCES) $(MISC)
	tar -z -c -v --exclude=CVS -f $(PACKAGE)-$(VERSION).tar.gz $(MISC) $(SOURCES)
