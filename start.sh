#!/bin/bash

erl -pa ebin -pa deps/*/ebin -s demo_app -sname demo_app -setcookie demo_app

