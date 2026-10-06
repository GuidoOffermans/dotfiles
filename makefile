# Packages linked straight into ~
HOME_PACKAGES := bash bin ohmyposh zsh
# Every other top-level dir is an app config, linked into ~/.config/<name>.
# windows/ is its own stow dir; see windows/install.sh
CONFIG_PACKAGES := $(filter-out $(HOME_PACKAGES) windows,$(patsubst %/,%,$(wildcard */)))

# $(1): stow mode (--restow, --delete or --adopt)
define stow_all
	stow --verbose --target=$$HOME $(1) $(HOME_PACKAGES)
	for p in $(CONFIG_PACKAGES); do \
		mkdir -p "$$HOME/.config/$$p" && stow --verbose --target="$$HOME/.config/$$p" $(1) "$$p" || exit 1; \
	done
endef

all:
	$(call stow_all,--restow)

delete:
	$(call stow_all,--delete)

adopt:
	$(call stow_all,--adopt)
