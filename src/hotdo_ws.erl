
-module(hotdo_ws).
-behavior(cowboy_websocket_handler).

-export([init/3, 
	 websocket_init/3, 
	 websocket_handle/3,
	 websocket_info/3,
	 websocket_terminate/3]).

init(_, _, _) ->
    {upgrade, protocol, cowboy_websocket}.

update_counter(Op) ->
    folsom_metrics:notify({hotdo_users, {Op, 1}}),
    gproc:send({p, l, hotdo}, 
	       {count, folsom_metrics:get_metric_value(hotdo_users)}).    

websocket_init(_Transport, Req, _Opt) ->
    gproc:reg({p, l, hotdo}),
    update_counter(inc),
    {ok, Req, undefined}.

websocket_handle({text, Msg}, Req, State) ->
    gproc:send({p, l, hotdo}, {text, Msg}),
    {ok, Req, State}.				

websocket_info({count, Num}, Req, State) ->
    {reply, {text, jiffy:encode([<<"count">>, [Num]])}, Req, State};
websocket_info({text, Msg}, Req, State) ->
    {reply, {text, Msg}, Req, State}.

websocket_terminate(_Reason, _Req, _State) ->
    update_counter(dec),
    ok.
