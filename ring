#!/usr/bin/env bash
# -*- sh -*-

erl -pa deps/*/ebin -sname extremeforge -s extremeforge start src test
