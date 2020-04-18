#!/bin/sh

find static/css src/ -name "*.scss" -or -name "*.elm" | entr ./compile-all.sh
