DESCRIPTION = CS50 Library for C
MAINTAINER = CS50
NAME = library50-c
VERSION = 7.0.0

.PHONY: bash
bash:
	docker run -i --rm -v "$(PWD)":/root -t cs50/fpm
	#ID=$(docker build -q .) docker run -i -t $(ID)

.PHONY: build
build: clean Makefile src/cs50.c src/cs50.h
	mkdir -p build/usr/include
	mkdir -p build/usr/lib
	gcc -c -std=c99 -Wall -Werror -o build/cs50.o src/cs50.c
	ar rcs build/usr/lib/libcs50.a build/cs50.o
	rm -f build/cs50.o
	cp src/cs50.h build/usr/include

.PHONY: clean
clean:
	rm -rf build

.PHONY: deb
deb: build
	fpm \
	-m "$(MAINTAINER)" \
	-n "$(NAME)" \
	-p build \
	-s dir \
	-t deb \
	-v $(VERSION) \
	--deb-no-default-config-files \
	--depends libc-dev \
	--description "$(DESCRIPTION)" \
	build/usr

# TODO: add dependencies
.PHONY: pacman
pacman: build
	rm -f $(NAME)-$(VERSION)-*.pkg.tar.xz
	fpm \
	-m "$(MAINTAINER)" \
	-n "$(NAME)" \
	-p build \
	-s dir \
	-t pacman \
	-v $(VERSION) \
	--deb-no-default-config-files \
	--description "$(DESCRIPTION)" \
	build/usr

# TODO: add dependencies
.PHONY: rpm
rpm: build
	rm -f $(NAME)-$(VERSION)-*.rpm
	fpm \
	-m "$(MAINTAINER)" \
	-n "$(NAME)" \
	-p build \
	-s dir \
	-t rpm \
	-v $(VERSION) \
	--deb-no-default-config-files \
	--description "$(DESCRIPTION)" \
	build/usr

# TODO: improve test suite
.PHONY: test
test: build
	gcc -ggdb3 -Ibuild/usr/include -O0 -std=c99 -Wall -Werror -Wno-deprecated-declarations tests/test.c -Lbuild/usr/lib -lcs50 -o build/test