#!/bin/sh

rm -f Makefile
find . -iwholename '*cmake*' -not -name CMakeLists.txt -delete
