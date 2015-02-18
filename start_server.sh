#!/bin/bash

erl -pa ebin -pa deps/*/ebin  -sname server -setcookie demo_app

