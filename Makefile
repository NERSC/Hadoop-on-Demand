SUBDIRS=src

all: subdirs


install-subdirs:
	for dir in $(SUBDIRS); do \
		$(MAKE) PREFIX=$(PREFIX) -C $$dir install; \
	done

subdirs:
	for dir in $(SUBDIRS); do \
		$(MAKE) -C $$dir; \
	done

install: install-scripts install-subdirs install-conf

install-scripts:
	cp ./scripts/start_hadoop $(PREFIX)/bin/
	cp ./scripts/run_tracker $(PREFIX)/bin/

install-conf:
	cp -a ./conf $(PREFIX)/conf
