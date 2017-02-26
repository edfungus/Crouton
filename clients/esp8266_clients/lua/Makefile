all: upload

format:
	nodemcu-uploader file format

build: clean
	mkdir build/
	bash .build/rename_files build/

clean:
	rm -rf build

do_upload:
	bash .build/upload

upload: build do_upload
