#!/bin/bash

ca65 src/main.asm -I src -l listing.txt -o main.o
ld65 -C config.cfg -o jam.nes -m map.txt -vm main.o

