#!/bin/bash

erl -pa ebin -pa deps/*/ebin -s wc_client -sname client -setcookie demo_app

