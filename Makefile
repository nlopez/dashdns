NAME=dashdns
VERSION=0.2
JAR=$(NAME).jar
PREFIX=/opt/dashdns

.PHONY: default
default: deb
package: deb

.PHONY: clean
clean:
	rm -f *.deb
	rm -f *.jar
	rm -rf ./tmp

tmp:
	mkdir ./tmp

tmp/$(JAR): tmp
	warble
	mv $(JAR) ./tmp/$(JAR)

.PHONY: deb
deb: tmp/$(JAR)
	fpm -s dir -t deb --deb-user root --deb-group root -a all \
		-v $(VERSION) -n $(NAME) --prefix $(PREFIX) -C ./tmp .



