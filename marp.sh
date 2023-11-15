#!/bin/sh

npx @marp-team/marp-cli@latest md/00-intro.md -o html/00-intro.html --theme-set css/sv2-explained.css
npx @marp-team/marp-cli@latest md/01-mining.md -o html/01-mining.html --theme-set css/sv2-explained.css
