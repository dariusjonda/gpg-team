SYS_INSTALL = /usr/bin
INSTALL = $${HOME}/.local/bin

install:
	cp gpg-team ${INSTALL}/gpg-team

clean:
	rm ${INSTALL}/gpg-team

sinstall:
	cp gpg-team ${SYS_INSTALL}/gpg-team

sclean:
	rm ${SYS_INSTALL}/gpg-team
