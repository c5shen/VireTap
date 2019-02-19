install_dir = $(shell pwd)
script_dir = VireTap-scripts
INSTALL_PATH = /usr/local

.SILENT:

all: ask_for_install

viretap: $(script_dir)/run.sh
	shc -f $(script_dir)/run.sh
	rm $(script_dir)/run.sh.x.c
	mv $(script_dir)/run.sh.x viretap	
	@echo $(install_dir)
	@echo "Finished building executable: viretap"
	@echo -e

ask_for_install:
	@echo "Do you want to install VireTap?"
	@echo "If so... try make install (may need sudo permission)"

install:
	@echo '*** Installing viretap on '$(INSTALL_PATH)
	@echo -n '***	Do you want to continue? (y/n)'; read ANS; case "$$ANS" in y|Y|yes|Yes|YES) ;; *) exit 1;; esac;
	install -c -s viretap $(INSTALL_PATH)/bin/
	cp VireTap-scripts $(INSTALL_PATH)/etc/

clean:
	echo "Removing executable..."
	rm viretap

