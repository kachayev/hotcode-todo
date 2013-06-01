
-module(hotdo).
-export([start/0]).

start() ->
    lists:foreach(fun(App) ->
			  ok = application:start(App) 
		  end,
		  [crypto, ranch, cowboy, folsom, gproc, hotdo]).
