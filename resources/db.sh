#!/bin/sh -e

export SHELL_DEBUG=all

printf "\033[1m Journal filtered (last 5 minutes)\033[0m\n"
journalctl /usr/bin/gnome-shell --since "5 minutes ago" | grep "pdt@kaivanmaurik.com\|POS Device Toolkit\|PDT\|JS ERROR\|pdt"

printf "\033[1m Extension status \033[0m\n"
gnome-extensions info pdt@kaivanmaurik.com

printf "\033[1m Monitoring Gnome Shell... \033[0m\n"
journalctl /usr/bin/gnome-shell -f --since "0 minutes ago"
