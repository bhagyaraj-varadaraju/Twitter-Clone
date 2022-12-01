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
-include("record_structures.hrl").
-define(MAX_TWEET_ID_NUMBER, 500000).

%% API
-export([start_engine/1]).


listen_for_requests(CurrentIndex, TotalClients, Stats) ->
  if
    CurrentIndex > TotalClients ->
      io:format("All requests have been served~n"),
      Stats;
    true ->
      receive
        {post_tweet, UserId, TweetContent} ->
          %% Create a tweet record and insert it into tweetTable
          TweetId = "tweet" ++ integer_to_list(trunc(rand:uniform(?MAX_TWEET_ID_NUMBER))),
          ets:insert(tweetTable, {TweetId, UserId, TweetContent}),
          io:format("New Tweet [~p] ~n", [TweetContent]),

          %% Send the tweet to all the followers of the user
          Followers = ets:lookup_element(userTable, UserId, 4),
          %io:format("Followers ~p ~n", [Followers]),
          lists:foreach(
            fun(SubUserId) ->
              SubUserPID = ets:lookup_element(userTable, SubUserId, 5),
              SubUserPID ! {receive_tweet,TweetId, UserId, TweetContent}
            end,
            Followers
          ),


          %% Keep listening to the incoming requests
          listen_for_requests(CurrentIndex, TotalClients, Stats#perf_stats{total_tweets = Stats#perf_stats.total_tweets + 1});

%%        {subscribe} ->
%%      %% Add follower(who is subscribed to a user's tweets) to the user when someone subscribes.
%%        addFollower(User, Follower) ->
%%          Current_list = get_followers(User),
%%          Updated_list  = [Follower] ++ Current_list,
%%          User#user{followers = Updated_list}.

%%          done;

        {retweet} ->
          done;

        {search_hashtag} ->
          done;

        {search_mention} ->
          done;

        {client_done} ->
          listen_for_requests(CurrentIndex + 1, TotalClients, Stats)

      after 5000 ->
        io:format("No request has been received in the last 5000 ms. Exiting server"),
        Stats
      end
  end.

start_engine(N) ->
  %% Register current process
  register(?MODULE, self()),

  %% Start the timer before serving requests
  Stats = #perf_stats{},
  Start = os:system_time(millisecond),

  %% Listen to the users for distributing tweets and handling queries
  UpdatedStats = listen_for_requests(1, N, Stats),

  %% End the timer after all the requests are served
  End = os:system_time(millisecond),

  io:format("Server Teminated with Stats [ ~p ] ~n", [UpdatedStats#perf_stats{time = End - Start}]),

  simulator ! {server_done},

  %% Unregister the current process
  erlang:unregister(?MODULE).
