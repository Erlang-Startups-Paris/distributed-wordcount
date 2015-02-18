#!/bin/bash

NODENAME=${1:-client} 

erl -pa ebin -pa deps/*/ebin -s wc_client -sname $NODENAME -setcookie demo_app

