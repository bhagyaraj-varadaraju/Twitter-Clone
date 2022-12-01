%%%-------------------------------------------------------------------
%%% @author bhagyaraj
%%% @copyright (C) 2022, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 29. Nov 2022 12:13 PM
%%%-------------------------------------------------------------------
-author("bhagyaraj").


%% Performance stats data structure
-record (perf_stats, {
  time = 0,
  total_tweets = 0,
  total_subscriptions = 0,
  total_retweets = 0,
  hashtag_query_count = 0,
  mention_query_count = 0
}).
