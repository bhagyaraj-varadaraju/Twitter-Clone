%%%-------------------------------------------------------------------
%%% @author bhagyaraj
%%% @copyright (C) 2022, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 23. Nov 2022 11:37 AM
%%%-------------------------------------------------------------------
-module(tweet_handler).
-author("bhagyaraj").
-include("record_structures.hrl").
-define(MAX_TWEET_ID_NUMBER, 500000).

%% API
-export([create_tweet/2]).
-export([get_tweetUserId/1, get_tweetContent/1, get_tweetTime/1]).


%% Create a tweet.
create_tweet(User, Content) ->
  %%  Generate a random number for tweet ID
  TweetId = "tweet" ++ integer_to_list(trunc(rand:uniform(?MAX_TWEET_ID_NUMBER))),
  #tweet{id = TweetId, timestamp = erlang:timestamp(), user_id = User, content = Content}.

%% Get the id of the user that tweeted this tweet.
get_tweetUserId(Tweet) -> Tweet#tweet.user_id.

%% Get the contents of the tweet.
get_tweetContent(Tweet) -> Tweet#tweet.content.

%% Get the timestamp of the tweet.
get_tweetTime(Tweet) -> Tweet#tweet.timestamp.
