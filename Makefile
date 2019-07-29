.PHONY: all
all: sbcl quicklisp add-quicklisp-to-sbcl-file slime-helper

sbcl: .sbcl-installed

.sbcl-installed:
	brew install sbcl
	touch .sbcl-installed

quicklisp.lisp:
	curl -s -o quicklisp.lisp http://beta.quicklisp.org/quicklisp.lisp

quicklisp: $(HOME)/quicklisp/setup.lisp

CMD = '(quicklisp-quickstart:install :path "$(HOME)/quicklisp")'

$(HOME)/quicklisp/setup.lisp: .sbcl-installed quicklisp.lisp
	[ -f $(HOME)/quicklisp/setup.lisp ] || sbcl --no-sysinit --no-userinit --load quicklisp.lisp \
       --eval $(CMD) \
       --quit

slime-helper: $(HOME)/quicklisp/slime-helper.el

$(HOME)/quicklisp/slime-helper.el:
	sbcl --load ~/quicklisp/setup.lisp --eval '(ql:quickload :quicklisp-slime-helper)' --quit

add-quicklisp-to-sbcl-file:
	grep add-to-init-file $(HOME)/.sbclrc || sbcl --load ~/quicklisp/setup.lisp --eval '(ql:add-to-init-file)' --quit

clean:
	brew uninstall sbcl || echo "wasn't installed"
	rm -f .sbcl-installed
	rm -f quicklisp.lisp
	rm -rf ~/quicklisp
