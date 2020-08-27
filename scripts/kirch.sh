#!/bin/sh

mkdir -p /tmp \
    && git -C /tmp clone https://github.com/JKirchartz/fortunes.git kirch \
    && cd /tmp/kirch && rm -r README.md LICENSE Makefile bin \
    && cp -r /tmp/kirch/* $HOME/fortunes/
