%%%-------------------------------------------------------------------
%%% @author bhagyaraj
%%% @copyright (C) 2022, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 22. Nov 2022 12:28 AM
%%%-------------------------------------------------------------------
-module(simulator).
-author("bhagyaraj").
-include("record_structures.hrl").

%% API
-export([main/1]).


%% Spawns the N client users and assigns them unique UserIds
spawn_clients(CurrentSpawnIndex, ClientCount) ->
  if
  % Spawn the actor based on the algorithm and update its PID in the map
    CurrentSpawnIndex =< ClientCount ->
      UserId = CurrentSpawnIndex,
      CurrentSpawnPID = spawn_link(node(), account_handler, create_account, [UserId]),

      % Insert into the ETS table in the format {ActorIndex, ActorPID}
      ets:insert(userIdTable, {UserId, CurrentSpawnPID}),
      spawn_clients(CurrentSpawnIndex + 1, ClientCount);

  % Return after all the spawns are done
    true ->
      io:format("All ~p clients have been spawned~n", [ClientCount])
  end.

%% Start the simulator, N - number of clients to spawn
main(N) ->
  %% Register current process
  register(?MODULE, self()),

  %% Create an ETS table 'userIdTable' for storing {UserId, PID}
  ets:new(userIdTable, [set, named_table, protected]),

  %% Spawn the server engine
  spawn_link(node(), server, start_engine, []),

  %% Spawn 'N' number of clients
  spawn_clients(1, N),
  utils:generate_tweet_text(),

  %% Delete the ETS table from the storage
  ets:delete(userIdTable),

  %% Unregister the current process
  erlang:unregister(?MODULE).
