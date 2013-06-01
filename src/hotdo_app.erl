-module(hotdo_app).

-behaviour(application).

%% Application callbacks
-export([start/2, stop/1]).

%% ===================================================================
%% Application callbacks
%% ===================================================================

start(_StartType, _StartArgs) ->
    Static = {"/[...]", cowboy_static, [
					{directory, {priv_dir, hotdo, []}},
					{mimetypes, {fun mimetypes:path_to_mimes/2, default}}
				       ]},

    Ws = {"/websocket", hotdo_ws, []},

    Dispatch = cowboy_router:compile([
				      {'_', [Ws, Static]}
				     ]),

    {ok, _} = cowboy:start_http(http, 100, 
				[{port, 7070}], 
				[{env, [{dispatch, Dispatch}]}]),

    io:format("Starting server on ~p port~n", [7070]),

    folsom_metrics:new_counter(hotdo_users),
    io:format("Registered new counter~n", []),

    hotdo_sup:start_link().

stop(_State) ->
    ok.
