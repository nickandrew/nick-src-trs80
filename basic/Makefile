#	@(#) $Id$
#

PACKAGE=	trs80-basic
VERSION=	1.x

SOURCES=	appoint convert dialer keyword life lookit morserec renumber roulette wordproc

MISC=		$(PACKAGE).html Makefile

all:
	@echo "Try make VERSION=1.x package"

package:	$(PACKAGE)-$(VERSION).tar.gz

$(PACKAGE)-$(VERSION).tar.gz:	$(SOURCES) $(MISC)
	tar -z -c -v --exclude=CVS -f $(PACKAGE)-$(VERSION).tar.gz $(MISC) $(SOURCES)
