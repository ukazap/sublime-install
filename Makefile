# Dynamic version fetching
SUBLIME_TEXT_BUILD := $(shell curl -s https://www.sublimetext.com/download | grep 'class="latest"' | grep -o 'Build [0-9]*' | sed 's/Build //')
SUBLIME_MERGE_BUILD := $(shell curl -s https://www.sublimemerge.com/download | grep 'class="latest"' | grep -o 'Build [0-9]*' | sed 's/Build //')

SUBLIME_TEXT_FILE = temp/sublime_text_build_$(SUBLIME_TEXT_BUILD)_arm64.tar.xz
SUBLIME_TEXT_SIGNATURE = $(SUBLIME_TEXT_FILE).asc

SUBLIME_MERGE_FILE = temp/sublime_merge_build_$(SUBLIME_MERGE_BUILD)_arm64.tar.xz
SUBLIME_MERGE_SIGNATURE = $(SUBLIME_MERGE_FILE).asc

PUBKEY_FILE = temp/sublimehq-pub.gpg

.PHONY: all clean verify-sublime-text verify-sublime-merge install-sublime-text install-sublime-merge install uninstall-sublime-text uninstall-sublime-merge uninstall versions

versions:
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
	@sudo cp -r temp/sublime_text /opt/
	@sudo cp /opt/sublime_text/sublime_text.desktop /usr/share/applications/
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
	@sudo cp -r temp/sublime_merge /opt/
	@sudo cp /opt/sublime_merge/sublime_merge.desktop /usr/share/applications/
	@echo "Sublime Merge installed."

# Shared targets
$(PUBKEY_FILE):
	@mkdir -p temp
	@curl -o $(PUBKEY_FILE) https://download.sublimetext.com/$(notdir $(PUBKEY_FILE))

install: install-sublime-text install-sublime-merge

uninstall-sublime-text:
	@sudo rm -rf /opt/sublime_text
	@sudo rm -f /usr/local/bin/subl
	@sudo rm -f /usr/share/applications/sublime_text.desktop
	@echo "Sublime Text uninstalled"

uninstall-sublime-merge:
	@sudo rm -rf /opt/sublime_merge
	@sudo rm -f /usr/local/bin/smerge
	@sudo rm -f /usr/share/applications/sublime_merge.desktop
	@echo "Sublime Merge uninstalled"

uninstall: uninstall-sublime-text uninstall-sublime-merge

clean:
	@rm -rf temp