#!/bin/bash

sudo apt autoremove -y
sudo apt autoclean -y
sudo apt update
sudo apt upgrade -y
sudo apt autoremove -y
sudo apt autoclean -y

sudo snap refresh

sudo flatpak update -y
