
sudo pacman -Scc

sudo pacman -Rns $(pacman -Qtdq)

sudo journalctl --vacuum-time=3d

