install_dir = $(shell pwd)

viretap: run.sh
	shc -f run.sh
	rm run.sh.x.c
	mv run.sh.x viretap	
	@echo $(install_dir)

clean:
	echo "Removing executable..."
	rm viretap

