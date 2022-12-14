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
  %% Spawn the actors
    CurrentSpawnIndex =< ClientCount ->
      %% Generate the UserId for the current user
      UserId = "usr" ++ integer_to_list(CurrentSpawnIndex),

      spawn_link(node(), account_handler, start_user, [CurrentSpawnIndex, UserId, ClientCount]),
      spawn_clients(CurrentSpawnIndex + 1, ClientCount);

  %% Return after all the spawns are done
    true ->
      io:format("All ~p clients have been spawned~n", [ClientCount])
  end.

%% Start the simulator, N - number of clients to spawn
main(N) ->
  %% Register current process
  register(?MODULE, self()),

  %% Create an ETS table 'userTable' for storing user accounts
  ets:new(userTable, [set, named_table, public, {keypos, 2}]),

  %% Create an ETS table 'tweetTable' for storing tweets
  ets:new(tweetTable, [set, named_table, public]),

  %% Create an ETS table 'hashtagTable' for allowed hashtags
  ets:new(hashtagTable,[set, named_table, public]),
  utils:populate_hashtag_table(),

  %% Spawn the server engine
  spawn_link(node(), server, start_engine, [N]),

  %% Spawn 'N' number of clients
  spawn_clients(1, N),

  %% Wait for the server to complete listening
  receive
    {server_done, StatsAtExit} ->
      io:format("Server Teminated with Stats,
       Time = ~p ms,
       Tweets made = ~p,
       Subscriptions handled = ~p,
       Retweets done = ~p,
       Hashtag searches  = ~p,
       My mention searches = ~p~n",
            [StatsAtExit#perf_stats.time,
              StatsAtExit#perf_stats.total_tweets,
              StatsAtExit#perf_stats.total_subscriptions,
              StatsAtExit#perf_stats.total_retweets,
              StatsAtExit#perf_stats.hashtag_query_count,
              StatsAtExit#perf_stats.mention_query_count])
  end,

  %% Delete the ETS tables from the storage
  ets:delete(userTable),
  ets:delete(tweetTable),
  ets:delete(hashtagTable),

  %% Unregister the current process
  erlang:unregister(?MODULE).
