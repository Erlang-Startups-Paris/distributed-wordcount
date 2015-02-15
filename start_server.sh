#!/bin/bash

erl -pa ebin -pa deps/*/ebin -s wc_server -sname server -setcookie demo_app

