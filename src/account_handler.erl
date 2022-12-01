%%%-------------------------------------------------------------------
%%% @author bhagyaraj
%%% @copyright (C) 2022, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 23. Nov 2022 11:37 AM
%%%-------------------------------------------------------------------
-module(account_handler).
-author("bhagyaraj").
-include("record_structures.hrl").

%% API
-export([start_user/3]).
-define(MAX_TWEETS, 100).


%% Handle user process
start_user(MyIndex, UserId, _N) ->

  %% Signup the user by inserting into the ETS table in the format {ActorIndex, UserId, Following, Followers, ActorPID}
  ets:insert(userTable, {MyIndex, UserId, [], [], self()}),

  %% Send tweet and insert into tweet table
  Tweet_content = utils:generate_tweet_text(),
  server ! {post_tweet, UserId, Tweet_content},

%%  %% Subscribe to user's tweets
%%  server ! {subscribe, },
%%
%%  %% Retweet some of the received tweets
%%  server ! {retweet, },
%%
%%  %% Search for a hashtag
%%  server ! {search_hashtag, },
%%
%%  %% Search for my mentions
%%  server ! {search_mention, },

  %% Send the completed message to the server
  server ! {client_done}.
