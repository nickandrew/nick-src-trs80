#	@(#) $Id$
#

NAME=		trs80-zeta-bbs
VERSION=	1.x

SOURCES=	catalogs comm file-transfer games \
		high-memory include internal mail-system \
		maintain network treeboard utilities

all:
	@echo "Try make VERSION=1.x packages"

packages:
	for i in $(SOURCES) ; do \
		$(MAKE) VERSION=$(VERSION) NAME=$(NAME) DIR=$$i package ; \
	done

package:	$(NAME)-$(DIR)-$(VERSION).tar.gz

$(NAME)-$(DIR)-$(VERSION).tar.gz:
	tar -z -c -v --exclude=CVS -f $(NAME)-$(DIR)-$(VERSION).tar.gz $(DIR)
