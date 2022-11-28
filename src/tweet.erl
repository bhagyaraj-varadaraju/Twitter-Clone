%%%-------------------------------------------------------------------
%%% @author bhagyaraj
%%% @copyright (C) 2022, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 23. Nov 2022 11:37 AM
%%%-------------------------------------------------------------------
-module(tweet).
-author("bhagyaraj").

%% API
-export([create_tweet/2]).
-export([get_tweetUserId/1, get_tweetContent/1, get_tweetTime/1]).
-record (tweet, {timestamp, user_id, content}).

% Create a tweet.
create_tweet(User, Content) -> #tweet{timestamp = erlang:timestamp(), user_id = User, content = Content}.

% Get the id of the user that tweeted this tweet.
get_tweetUserId(Tweet) -> Tweet#tweet.user_id.

% Get the contents of the tweet.
get_tweetContent(Tweet) -> Tweet#tweet.content.

% Get the timestamp of the tweet.
get_tweetTime(Tweet) -> Tweet#tweet.timestamp.
