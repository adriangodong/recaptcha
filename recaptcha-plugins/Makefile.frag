# -*- Mode: Makefile -*-

distdir=$(PLUGINNAME)-$(VERSION)

distdir : $(FILES) $(COPYFILES) Makefile ../Makefile.frag
	mkdir  -p $(distdir)
	cp -p $(FILES) $(distdir)
	test "x$(COPYFILES)" = "x" || cp -p $(COPYFILES) $(distdir)

dist : distdir
	zip -r $(PLUGINNAME)-$(VERSION).zip $(distdir)
	rm -rf $(distdir)

googleupload : dist
	../googlecode-upload.py --project recaptcha --user $(GOOGUSER) --summary $(DESCRIPTION) $(PLUGINNAME)-$(VERSION).zip
	@echo
	@echo
	@echo "$(PLUGINNAME)-$(VERSION).zip was uploaded to Google"
	@echo "***NOTE: you have to modify the tags on the upload:"
	@echo "         http://code.google.com/p/recaptcha/downloads/detail?name=$(PLUGINNAME)-$(VERSION).zip"
	@echo
	@echo "Also, go to the previous version, remove the featured tag,"
	@echo "and the foo-latest tag, then add the deprecated tag."

