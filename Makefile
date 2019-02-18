install_dir = $(shell pwd)
script_dir = VireTap-scripts

viretap: $(script_dir)/run.sh
	shc -f $(script_dir)/run.sh
	rm $(script_dir)/run.sh.x.c
	mv $(script_dir)/run.sh.x viretap	
	@echo $(install_dir)
	@echo "Finished building executable: viretap"

clean:
	echo "Removing executable..."
	rm viretap

