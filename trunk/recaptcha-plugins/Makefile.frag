# -*- Mode: Makefile -*-

distdir=$(PLUGINNAME)-$(VERSION)

distdir : $(FILES) $(COPYFILES) Makefile ../Makefile.frag
	mkdir  -p $(distdir)
	cp -p $(FILES) $(distdir)
	test "x$(COPYFILES)" = "x" || cp -p $(COPYFILES) $(distdir)

dist : distdir
	zip -r $(PLUGINNAME)-$(VERSION).zip $(distdir)
	rm -rf $(distdir)
