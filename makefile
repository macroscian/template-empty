.DEFAULT_GOAL=help
ENV_PREFIX=BABS_
include secrets

pkg_dirs = data R
pkg_files = DESCRIPTION
other_dirs = extdata results templates logs scripts
pkg_exlude = logs makefile .git* .~

all: $(pkg_dirs) $(other_dirs)

$(pkg_dirs) $(other_dirs):
	mkdir -p $@

package:
	rm -f ${SCRATCH_DIR}/.pkg
	mkdir -p ${SCRATCH_DIR}/.pkg/inst
	rsync -a $(patsubst %,--include %,${pkg_dirs} ${pkg_files}) --exclude "*" . ${SCRATCH_DIR}/.pkg
	rsync -a $(patsubst %,--exclude %,${pkg_dirs} renv ${pkg_files} ${pkg_exclude}) . ${SCRATCH_DIR}/.pkg/inst
	cd ${SCRATCH_DIR}/.pkg && R -e 'library(devtools);document()' && R CMD BUILD
	mv ${SCRATCH_DIR}/.pkg/*.tar.gz .

GIT=git
make_rwx = setfacl -m u::rwx

TAG := _$(shell $(GIT) describe --tags --dirty=_altered --always --long 2>/dev/null || echo "uncontrolled")# e.g. v1.0.2-2-ace1729a
VERSION := $(shell $(GIT) describe --tags --abbrev=0 2>/dev/null || echo "vX.Y.Z")#e.g. v1.0.2

#Standard makefile hacks
comma:= ,
space:= $() $()
empty:= $()
define newline

$(empty)
endef

# $(call log,test,-a) will append stderr+out to log.test and report to stdout
ifndef SILENT
log=2>&1 | tee $2 $(log_dir)/$1.log
else
log=2>&1 | tee $2 $(log_dir)/$1.log > /dev/null
endif


################################################################
## Standard Goals
################################################################
.PHONY: print-%
print-%: ## `make print-varname` will show varname's value
	@echo "$*"="$($*)"

$(V).SILENT: 

.PHONY: help
help: ## Show help message
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m\033[0m\n"} /^[$$()% 0-9a-zA-Z_-]+:.*?##/ { printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)

