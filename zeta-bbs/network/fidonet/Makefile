#	@(#) $Id$
#

PACKAGE=	fidonet-packet-handlers
VERSION=	0.x

SOURCES=	$(BBASS) $(MAILASS) $(MSGASS) $(PACKCTL) \
		$(PACKDIS) $(PKTASS) $(PKTDIS) $(PKTSPLIT) \
		$(BUNFUNC) $(ZETA_H)
BBASS=		bbass.asm bbass.h bbass1.c bbass2.c
MAILASS=	mailass.asm mailass.h mailass1.c mailass2.c
MSGASS=		msgass.asm msgass1.asm
PACKCTL=	packctl.c packctl.h
PACKDIS=	packdis.asm packdis.h packdis1.c packdis2.c packdis3.c packdis4.c packdis.ctl
PKTASS=		pktass.asm pktass1.asm
PKTDIS=		pktdis.asm pktdis1.asm
PKTSPLIT=	pktsplit.asm
BUNFUNC=	bunfunc.c
ZETA_H=		zeta.h

MISC=		Makefile $(PACKAGE).html

all:
	@echo "Try make VERSION=0.x package"

package:	$(PACKAGE)-$(VERSION).tar.gz

$(PACKAGE)-$(VERSION).tar.gz:	$(SOURCES) $(MISC)
	tar zcvf $(PACKAGE)-$(VERSION).tar.gz $(SOURCES) $(MISC)
