#	@(#) $Id$
#

PACKAGE=	trs80-lang
VERSION=	1.x

SOURCES=	alcor asmclean asmup ceval cpack cpu-6502 decode delabel \
		execute flow fortran l2 lcopt listbas \
		nedas nedasref noffs nonops notabs \
		pasconv pp ret86 sptotab strip toupper \
		trail unline

MISC=		$(PACKAGE).html Makefile

all:
	@echo "Try make VERSION=1.x package"

package:	$(PACKAGE)-$(VERSION).tar.gz

$(PACKAGE)-$(VERSION).tar.gz:	$(SOURCES) $(MISC)
	tar -z -c -v --exclude=CVS -f $(PACKAGE)-$(VERSION).tar.gz $(MISC) $(SOURCES)
