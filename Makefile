install_dir = $(shell pwd)
script_dir = VireTap-scripts
INSTALL_PATH = /usr/local

.SILENT:

all: viretap ask_for_install

viretap: $(script_dir)/run.sh
	$(script_dir)/shc-3.8.7/shc -v -r -T -f $(script_dir)/run.sh
	cp $(script_dir)/run.sh.x viretap	
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
	mkdir $(INSTALL_PATH)/etc/VireTap-scripts
	cp VireTap-scripts/* $(INSTALL_PATH)/etc/VireTap-scripts/

clean:
	echo "Removing executable..."
	rm viretap

