NAME=dashdns
VERSION=0.1
JAR=tmp/$(NAME).jar
PREFIX=/opt/dashdns

.PHONY: default
default: deb
package: deb

.PHONY: clean
clean:
	rm -f *.deb
	rm -f *.jar
	rm -rf ./tmp


.PHONY: jar
jar:
	warble
	mkdir ./tmp
	mv $(JAR) ./tmp/$(JAR)

.PHONY: deb
deb: $(JAR)
	fpm -s dir -t deb --deb-user root --deb-group root -a all \
		-v $(VERSION) -n $(NAME) --prefix $(PREFIX) -C ./tmp .



