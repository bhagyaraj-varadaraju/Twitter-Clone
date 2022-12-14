%%%-------------------------------------------------------------------
%%% @author bhagyaraj
%%% @copyright (C) 2022, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 23. Nov 2022 11:43 AM.
%%%-------------------------------------------------------------------
-module(utils).
-author("bhagyaraj").

%% API
-export([populate_hashtag_table/0, generate_tweet_text/0, get_random_element/1]).


populate_hashtag_table() ->
  ets:insert(hashtagTable, {"UFL"}),
  ets:insert(hashtagTable, {"DOSP"}),
  ets:insert(hashtagTable, {"COP5615"}),
  ets:insert(hashtagTable, {"GoGators"}),
  ets:insert(hashtagTable, {"Herbert"}),
  ets:insert(hashtagTable, {"Erlang"}).

keys(TableName) ->
  FirstKey = ets:first(TableName),
  keys(TableName, FirstKey, [FirstKey]).

keys(_TableName, '$end_of_table', ['$end_of_table'|Acc]) ->
  Acc;
keys(TableName, CurrentKey, Acc) ->
  NextKey = ets:next(TableName, CurrentKey),
  keys(TableName, NextKey, [NextKey|Acc]).

generate_random_string(Count, Characters) ->
  lists:foldl(fun(_, Acc) -> [lists:nth(rand:uniform(length(Characters)), Characters)] ++ Acc end, [], lists:seq(1, Count)).

get_random_string(L) -> generate_random_string(L, "abcdefghijklmnopqrstuvwxyz1234567890 ABCDEFGHIJKLMNOPQRSTUVWXYZ").

%% This generates 4 kinds of tweet texts including or excluding the hashtags and mentions
generate_tweet_text() ->
  Temp = rand:uniform(4),
  Hashtags = ets:select(hashtagTable, [{{'$1'}, [], ['$1']}]),
  Keys = keys(userTable),
  case Keys of
    [] -> get_random_string(80);
    _ ->
      TweetText = case Temp of
                    1 -> get_random_string(80);
                    2-> lists:concat([get_random_string(80), " ", "@", lists:nth(rand:uniform(length(Keys)), Keys)]);
                    3-> lists:concat([get_random_string(80), " ", "#", lists:nth(rand:uniform(length(Hashtags)), Hashtags)]);
                    4-> lists:concat([get_random_string(80), " ", "@", lists:nth(rand:uniform(length(Keys)), Keys),
                      " #", lists:nth(rand:uniform(length(Hashtags)), Hashtags)])
                  end,
      TweetText
  end.

get_random_element(Array) ->
  ArrayLen = length(Array),
  if
    ArrayLen /= 0 ->
      RandomElement = lists:nth(rand:uniform(ArrayLen), Array),
      RandomElement;
    true ->
      empty_array
  end.
