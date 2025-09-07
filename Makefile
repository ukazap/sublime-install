# Architecture detection
ARCH := $(shell uname -m)
ifeq ($(ARCH),x86_64)
    SUBLIME_ARCH = x64
else ifeq ($(ARCH),aarch64)
    SUBLIME_ARCH = arm64
else
    $(error Unsupported architecture: $(ARCH))
endif

# Dynamic version fetching
SUBLIME_TEXT_BUILD := $(shell curl -s https://www.sublimetext.com/download | grep 'class="latest"' | grep -o 'Build [0-9]*' | sed 's/Build //')
SUBLIME_MERGE_BUILD := $(shell curl -s https://www.sublimemerge.com/download | grep 'class="latest"' | grep -o 'Build [0-9]*' | sed 's/Build //')

SUBLIME_TEXT_FILE = temp/sublime_text_build_$(SUBLIME_TEXT_BUILD)_$(SUBLIME_ARCH).tar.xz
SUBLIME_TEXT_SIGNATURE = $(SUBLIME_TEXT_FILE).asc

SUBLIME_MERGE_FILE = temp/sublime_merge_build_$(SUBLIME_MERGE_BUILD)_$(SUBLIME_ARCH).tar.xz
SUBLIME_MERGE_SIGNATURE = $(SUBLIME_MERGE_FILE).asc

PUBKEY_FILE = temp/sublimehq-pub.gpg

.PHONY: all clean verify-sublime-text verify-sublime-merge install-sublime-text install-sublime-merge install uninstall-sublime-text uninstall-sublime-merge uninstall versions

versions:
	@echo "Architecture: $(ARCH) -> $(SUBLIME_ARCH)"
	@echo "Sublime Text build: $(SUBLIME_TEXT_BUILD)"
	@echo "Sublime Merge build: $(SUBLIME_MERGE_BUILD)"

all: sublime_text sublime_merge

# Sublime Text targets
sublime_text: $(SUBLIME_TEXT_FILE) verify-sublime-text
	@cd temp && tar -xf $(notdir $(SUBLIME_TEXT_FILE))

$(SUBLIME_TEXT_FILE):
	@mkdir -p temp
	@curl -o $(SUBLIME_TEXT_FILE) https://download.sublimetext.com/$(notdir $(SUBLIME_TEXT_FILE))

$(SUBLIME_TEXT_SIGNATURE):
	@mkdir -p temp
	@curl -o $(SUBLIME_TEXT_SIGNATURE) https://download.sublimetext.com/$(notdir $(SUBLIME_TEXT_SIGNATURE))

verify-sublime-text: $(PUBKEY_FILE) $(SUBLIME_TEXT_SIGNATURE) $(SUBLIME_TEXT_FILE)
	@gpg --import $(PUBKEY_FILE) 2>/dev/null || true
	@gpg --verify $(SUBLIME_TEXT_SIGNATURE) $(SUBLIME_TEXT_FILE)

install-sublime-text: sublime_text
	@mkdir -p ~/.local ~/.local/bin
	@cp -r temp/sublime_text ~/.local/
	@mkdir -p ~/.local/share/applications
	@sed 's|/opt/sublime_text/sublime_text|$(HOME)/.local/sublime_text/sublime_text|g' temp/sublime_text/sublime_text.desktop > ~/.local/share/applications/sublime_text.desktop
	@echo '#!/bin/bash' > ~/.local/bin/subl
	@echo 'exec ~/.local/sublime_text/sublime_text "$$@"' >> ~/.local/bin/subl
	@chmod +x ~/.local/bin/subl
	@echo "Sublime Text installed."

# Sublime Merge targets
sublime_merge: $(SUBLIME_MERGE_FILE) verify-sublime-merge
	@cd temp && tar -xf $(notdir $(SUBLIME_MERGE_FILE))

$(SUBLIME_MERGE_FILE):
	@mkdir -p temp
	@curl -o $(SUBLIME_MERGE_FILE) https://download.sublimetext.com/$(notdir $(SUBLIME_MERGE_FILE))

$(SUBLIME_MERGE_SIGNATURE):
	@mkdir -p temp
	@curl -o $(SUBLIME_MERGE_SIGNATURE) https://download.sublimetext.com/$(notdir $(SUBLIME_MERGE_SIGNATURE))

verify-sublime-merge: $(PUBKEY_FILE) $(SUBLIME_MERGE_SIGNATURE) $(SUBLIME_MERGE_FILE)
	@gpg --import $(PUBKEY_FILE) 2>/dev/null || true
	@gpg --verify $(SUBLIME_MERGE_SIGNATURE) $(SUBLIME_MERGE_FILE)

install-sublime-merge: sublime_merge
	@mkdir -p ~/.local ~/.local/bin
	@cp -r temp/sublime_merge ~/.local/
	@mkdir -p ~/.local/share/applications
	@sed 's|/opt/sublime_merge/sublime_merge|$(HOME)/.local/sublime_merge/sublime_merge|g' temp/sublime_merge/sublime_merge.desktop > ~/.local/share/applications/sublime_merge.desktop
	@echo '#!/bin/bash' > ~/.local/bin/smerge
	@echo 'exec ~/.local/sublime_merge/sublime_merge "$$@"' >> ~/.local/bin/smerge
	@chmod +x ~/.local/bin/smerge
	@echo "Sublime Merge installed."

# Shared targets
$(PUBKEY_FILE):
	@mkdir -p temp
	@curl -o $(PUBKEY_FILE) https://download.sublimetext.com/$(notdir $(PUBKEY_FILE))

install: install-sublime-text install-sublime-merge

uninstall-sublime-text:
	@rm -rf ~/.local/sublime_text
	@rm -f ~/.local/share/applications/sublime_text.desktop
	@rm -f ~/.local/bin/subl
	@echo "Sublime Text uninstalled"

uninstall-sublime-merge:
	@rm -rf ~/.local/sublime_merge
	@rm -f ~/.local/share/applications/sublime_merge.desktop
	@rm -f ~/.local/bin/smerge
	@echo "Sublime Merge uninstalled"

uninstall: uninstall-sublime-text uninstall-sublime-merge

clean:
	@rm -rf temp