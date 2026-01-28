.PHONY: test

test:
	nix-shell --run 'busted -m composite/?.lua'
