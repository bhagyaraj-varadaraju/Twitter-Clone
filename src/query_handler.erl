%%%-------------------------------------------------------------------
%%% @author bhagyaraj
%%% @copyright (C) 2022, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 23. Nov 2022 11:37 AM
%%%-------------------------------------------------------------------
-module(query_handler).
-author("bhagyaraj").

%% API
-export([search_mention/1, search_hashtag/1]).


%%If user id is given as a number returns the tweets in which this user is mentioned
search_mention(Userid) ->
  Temp = string:concat("@", Userid),
  AllTweets = ets:select(tweetTable, [{{'$1','$2','$3'}, [], ['$3']}]),
  RequiredTweets = lists:filtermap(fun(X) -> case string:str(X, Temp) of 0 -> false; _ ->{true,X} end end, AllTweets),
  RequiredTweets.

%%If hashtag is given this function queries the required tweets
search_hashtag(Hashtag) ->
  Temp = string:concat("#", Hashtag),
  AllTweets = ets:select(tweetTable, [{{'$1','$2','$3'}, [], ['$3']}]),
  RequiredTweets = lists:filtermap(fun(X) -> case string:str(X, Temp) of 0 -> false; _ ->{true,X} end end, AllTweets),
  RequiredTweets.

