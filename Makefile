SHELL = bash

all: format

IN_ENV = if [ -e env/bin/activate ]; then . env/bin/activate; fi; source utils/environment.python.sh;
env:
	git submodule update --init --recursive
	virtualenv --python=python3 env
	# Install fasm from third_party
	$(IN_ENV) pip install --upgrade -e third_party/fasm
	# Install edalize from third_party
	$(IN_ENV) pip install --upgrade -e third_party/edalize
	# Install requirements
	$(IN_ENV) pip install -r requirements.txt

build-tools:
	git submodule update --init --recursive
	# Build VtR
	+cd third_party/vtr && $(MAKE)
	# Build Yosys
	+cd third_party/yosys && $(MAKE)
	# Build Yosys plugins
	+cd third_party/yosys-plugins && export PATH=$(shell pwd)/third_party/yosys:${PATH} $(MAKE)

run-all:
	${IN_ENV} ./exhaust.py

PYTHON_SRCS=$(shell find . -name "*py" -not -path "./third_party/*" -not -path "./env/*")

format: ${PYTHON_SRCS}
	yapf -i $?

.PHONY: all env format run-all
