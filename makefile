all:
	stow --verbose --target=$$HOME --restow */

delete:
	stow --verbose --target=$$HOME --delete */

adopt:
	stow --verbose --target=$$HOME --adopt */
