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
        {post_tweet, UserId, TweetContent, CallerPID} ->
          %% Create a tweet record and insert it into tweetTable
          TweetId = "tweet" ++ integer_to_list(trunc(rand:uniform(?MAX_TWEET_ID_NUMBER))),
          ets:insert(tweetTable, {TweetId, UserId, TweetContent}),
          %% io:format("New Tweet [~p] ~n", [TweetContent]),

          %% Send the tweet to all the followers of the user
          Followers = ets:lookup_element(userTable, UserId, 4),
          %io:format("Followers ~p ~n", [Followers]),
          lists:foreach(
            fun(SubUserId) ->
              SubUserPID = ets:lookup_element(userTable, SubUserId, 5),
              SubUserPID ! {receive_tweet, TweetId, UserId, TweetContent}
            end,
            Followers
          ),

          %% Send acknowledgement and keep listening to the incoming requests
          CallerPID ! {tweet_success},
          listen_for_requests(CurrentIndex, TotalClients, Stats#perf_stats{total_tweets = Stats#perf_stats.total_tweets + 1});

        {subscribe, UserId, UserIdToSub, CallerPID} ->
          %% Add the "user to subscribe" to the following list of the user subscribing
          Following = ets:lookup_element(userTable, UserId, 3),
          NewFollowingList = [UserIdToSub] ++ Following,
          ets:update_element(userTable, UserId, {3, NewFollowingList}),

          %% Add the "user following" to the follower list of the user getting subscribed
          Followers = ets:lookup_element(userTable, UserIdToSub, 4),
          NewFollowersList = [UserId] ++ Followers,
          ets:update_element(userTable, UserIdToSub, {4, NewFollowersList}),

          %% Send acknowledgement and keep listening to the incoming requests
          CallerPID ! {subscribe_success},
          listen_for_requests(CurrentIndex, TotalClients, Stats#perf_stats{total_subscriptions = Stats#perf_stats.total_subscriptions + 1});

        {retweet, UserId, TweetContent, CallerPID} ->
          %% Send the tweet to all the followers of the user
          Followers = ets:lookup_element(userTable, UserId, 4),
          %io:format("Followers ~p ~n", [Followers]),
          lists:foreach(
            fun(SubUserId) ->
              SubUserPID = ets:lookup_element(userTable, SubUserId, 5),
              %% TweetId = ets:lookup_element(tweetTable, TweetContent, 1),
              SubUserPID ! {receive_tweet, UserId, TweetContent}
            end,
            Followers
          ),

          %% Send acknowledgement and keep listening to the incoming requests
          CallerPID ! {retweet_success},
          listen_for_requests(CurrentIndex, TotalClients, Stats#perf_stats{total_retweets = Stats#perf_stats.total_retweets + 1});

        {search_hashtag, HashTagToSearch, CallerPID} ->
          %% Search for the tweets with the hashtag sent
          TweetsWithHashtag = query_handler:search_hashtag(HashTagToSearch),

          %% Send acknowledgement and keep listening to the incoming requests
          CallerPID ! {hashtag_search_success, TweetsWithHashtag},
          listen_for_requests(CurrentIndex, TotalClients, Stats#perf_stats{hashtag_query_count = Stats#perf_stats.hashtag_query_count + 1});

        {search_mention, UserId, CallerPID} ->
          %% Search for the mentions of the called user
          TweetsReturned = query_handler:search_mention(UserId),

          %% Send acknowledgement and keep listening to the incoming requests
          CallerPID ! {mention_search_success, TweetsReturned},
          listen_for_requests(CurrentIndex, TotalClients, Stats#perf_stats{mention_query_count = Stats#perf_stats.mention_query_count + 1});

        {client_done} ->
          listen_for_requests(CurrentIndex + 1, TotalClients, Stats)

      after 5000 ->
        io:format("No request has been received in the last 5000 ms. Exiting server~n"),
        Stats
      end
  end.

start_engine(N) ->
  %% Register current process
  register(?MODULE, self()),

  %% Start the timer before serving requests
  Stats = #perf_stats{
    time = 0,
    total_tweets = 0,
    total_subscriptions = 0,
    total_retweets = 0,
    hashtag_query_count = 0,
    mention_query_count = 0
  },
  Start = os:system_time(millisecond),

  %% Listen to the users for distributing tweets and handling queries
  UpdatedStats = listen_for_requests(1, N, Stats),

  %% End the timer after all the requests are served
  End = os:system_time(millisecond),

  %% Display the stats
  StatsAtExit = UpdatedStats#perf_stats{time = End - Start},

  simulator ! {server_done, StatsAtExit},

  %% Unregister the current process
  erlang:unregister(?MODULE).
