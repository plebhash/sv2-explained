#!/bin/sh

nix run github:tweag/nix-marp -- md/00-intro.md -o html/00-intro.html --theme-set css/sv2-explained.css 
nix run github:tweag/nix-marp -- md/01-mining.md -o html/01-mining.html --theme-set css/sv2-explained.css
nix run github:tweag/nix-marp -- md/02-pools.md -o html/02-pools.html --theme-set css/sv2-explained.css
nix run github:tweag/nix-marp -- md/03-sv2.md -o html/03-sv2.html --theme-set css/sv2-explained.css
nix run github:tweag/nix-marp -- md/04-sri.md -o html/04-sri.html --theme-set css/sv2-explained.css
