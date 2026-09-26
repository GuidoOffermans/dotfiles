# windows/ is its own stow dir; see windows/install.sh
PACKAGES := $(filter-out windows/,$(wildcard */))

all:
	stow --verbose --target=$$HOME --restow $(PACKAGES)

delete:
	stow --verbose --target=$$HOME --delete $(PACKAGES)

adopt:
	stow --verbose --target=$$HOME --adopt $(PACKAGES)
