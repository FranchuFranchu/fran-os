PYTHON=python3

all: ../tools/make_sysenter_vectors.py sysenter_vectors.asm sysenter_vectors.yaml

sysenter_vectors.asm: sysenter_vectors.yaml
	cd ../tools ; $(PYTHON) make_sysenter_vectors.py

../src/features/sysenter_vectors_list.asm: sysenter_vectors.yaml
	cd ../tools ; $(PYTHON) make_sysenter_vectors.py	