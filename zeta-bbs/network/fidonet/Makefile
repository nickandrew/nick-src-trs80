#	@(#) Makefile
#	$Id$
#

PACKAGE=	fidonet-packet-handlers

SOURCES=	$(BBASS) $(MAILASS) $(MSGASS) $(PACKCTL) $(PACKDIS) $(PKTASS) $(PKTDIS)
BBASS=		bbass.asm bbass.h bbass1.c bbass2.c
MAILASS=	mailass.asm mailass.h mailass1.c mailass2.c
MSGASS=		msgass.asm msgass1.asm
PACKCTL=	packctl.c packctl.h
PACKDIS=	packdis.asm packdis.h packdis1.c packdis2.c packdis3.c packdis4.c
PKTASS=		pktass.asm pktass1.asm
PKTDIS=		pktdis.asm pktdis1.asm

MISC=		Makefile $(PACKAGE).html

VERSION=	0.x

all:
	@echo "Try make VERSION=0.x distribution"

distribution:	$(PACKAGE)-$(VERSION).tar.gz

$(PACKAGE)-$(VERSION).tar.gz:	$(SOURCES) $(MISC)
	tar zcvf $(PACKAGE)-$(VERSION).tar.gz $(SOURCES) $(MISC)
