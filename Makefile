SRC_DIR=./src
OUT_DIR=./out

FIND=find $(SRC_DIR) -path $(NLFFI_DIR) -prune -o
SOURCES=$(shell $(FIND) -name '*.sml')
FFI_HEADERS=$(shell $(FIND) -name '*.h')

CM_FILE=$(SRC_DIR)/notes.cm
IMAGE=$(OUT_DIR)/notes-image
IMAGE_ENTRY=Application.main

# NLFFI Options
NLFFI_DIR=$(SRC_DIR)/NLFFI-Generated
NLFFI_HANDLE=CursesH.libh
NLFFI_HINC=../curses.h.sml
NLFFIGEN_ARGS=-include $(NLFFI_HINC) -libhandle $(NLFFI_HANDLE)

$(IMAGE): $(OUT_DIR) $(SOURCES) $(NLFFI_DIR)
	ml-build $(CM_FILE) $(IMAGE_ENTRY) $(IMAGE)

$(NLFFI_DIR): $(FFI_HEADERS)
	ml-nlffigen -dir $(NLFFI_DIR) $(NLFFIGEN_ARGS) $(FFI_HEADERS)

run: $(IMAGE)
	sml @SMLload $(IMAGE).x86-linux

$(SRC_DIR):
	mkdir -p $(SRC_DIR)

$(OUT_DIR):
	mkdir -p $(OUT_DIR)

.PHONY: clean
clean:
	rm -rf $(OUT_DIR)
	rm -rf ./.cm
	rm -rf $(SRC_DIR)/.cm
	rm -rf $(NLFFI_DIR)