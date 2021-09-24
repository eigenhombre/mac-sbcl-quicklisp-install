.PHONY: all
all: sbcl quicklisp add-quicklisp-to-sbcl-file slime-helper quicklisp-local-packages-symlink

CL_DIR = $(HOME)/Programming/Lisp/common-lisp
QL_DIR = $(HOME)/quicklisp

quicklisp-local-packages-symlink: quicklisp
	rm -f $(QL_DIR)/local-projects
	mkdir -p $(CL_DIR)/local-projects
	ln -s $(CL_DIR)/local-projects $(QL_DIR)
	touch $(QL_DIR)/local-projects/system-index.txt

sbcl: .sbcl-installed

.sbcl-installed:
	brew install sbcl
	touch .sbcl-installed

quicklisp.lisp:
	curl -s -o quicklisp.lisp http://beta.quicklisp.org/quicklisp.lisp

quicklisp: $(QL_DIR)/setup.lisp

CMD = '(quicklisp-quickstart:install :path "$(HOME)/quicklisp")'

$(QL_DIR)/setup.lisp: .sbcl-installed quicklisp.lisp
	[ -f $(QL_DIR)/setup.lisp ] || sbcl --no-sysinit --no-userinit --load quicklisp.lisp \
       --eval $(CMD) \
       --quit

slime-helper: $(QL_DIR)/slime-helper.el

$(QL_DIR)/slime-helper.el:
	sbcl --load $(QL_DIR)/setup.lisp --eval '(ql:quickload :quicklisp-slime-helper)' --quit

add-quicklisp-to-sbcl-file:
	grep add-to-init-file $(HOME)/.sbclrc || sbcl --load $(QL_DIR)/setup.lisp --eval '(ql:add-to-init-file)' --quit

clean:
	brew uninstall sbcl || echo "wasn't installed"
	rm -f .sbcl-installed
	rm -f quicklisp.lisp
	rm -rf ~/quicklisp
