%%%-------------------------------------------------------------------
%%% @author bhagyaraj
%%% @copyright (C) 2022, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 24. Nov 2022 5:43 AM
%%%-------------------------------------------------------------------
-module(server).
-author("bhagyaraj").

%% API
-export([start_engine/0]).


listen_for_events() ->
  done.

start_engine() ->
  %% Register current process
  register(?MODULE, self()),

  %% Listen to the users for distributing tweets and handling queries
  listen_for_events(),

  %% Unregister the current process
  erlang:unregister(?MODULE).
