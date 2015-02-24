demo-erlang
===========

The aim of this code is to test distribution computation in Erlang, using map-reduce.

The computation used in this example is counting the number of occurrences of each word in a big file.

Checkout latest version of the code and make sure you have compiled the code using :
```
rebar co
```
Simple Test with one client and a server
----------------------------------------
Open two shells, one client and another server and launch the following commands


On server  | On client
------------- | -------------
```./start_server.sh``` | ```...```
```(server@localhost)1> wc_server:register().``` | ```...```
```server registered``` | ```./start_client.sh```
```(server@localhost)2> wc_server:test().``` | ```Client client@localhost waiting for request```
```Waiting computation results```| ```Receiving requests```
```Results```| ```Results sent to server```

Test with multiple clients and a server
----------------------------------------
Open three shells, two clients and one server. (This can be done on any number of nodes)

On the server node, update the file clients.txt with the clients names
```
client1@host1
client2@host2
```

Then launch the following commands :

On server  | On client1 | On client2
------------- | ------------- | -------------
```./start_server.sh``` | ```...``` | ```...```
```(server@localhost)1> wc_server:register().``` | ```...``` | ```...```
```server registered``` | ```erl -pa ebin -pa deps/*/ebin -s wc_client -sname client1@host1 -setcookie demo_app ``` | ```erl -pa ebin -pa deps/*/ebin -s wc_client -sname client2@host2 -setcookie demo_app ``` 
```(server@localhost)2> wc_server:test().``` | ```Client client1@host1 waiting for request``` | ```Client client2@host2 waiting for request```
```Waiting computation results```| ```Receiving requests``` | ```Receiving requests```
```Global results```| ```Results sent to server``` | ```Results sent to server``` 
