#	@(#) Makefile
#	$Id$
#

PACKAGE=	fidonet-packet-handlers

SOURCES=	bbass.asm bbass.h bbass1.c bbass2.c mailass.asm mailass.h mailass1.c mailass2.c packctl.c packctl.h packdis.asm packdis.h packdis1.c packdis2.c packdis3.c packdis4.c

MISC=		Makefile $(PACKAGE).html

VERSION=	0.x

all:
	@echo "Try make VERSION=0.x distribution"

distribution:	$(PACKAGE)-$(VERSION).tar.gz

$(PACKAGE)-$(VERSION).tar.gz:	$(SOURCES) $(MISC)
	tar zcvf $(PACKAGE)-$(VERSION).tar.gz $(SOURCES) $(MISC)
