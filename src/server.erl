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

%% API
-export([start_engine/0]).
-export([handleTweetButton/3, handleFollowButton/3]).

%% Send tweet to the user's followers upon clicking tweet button
handleTweetButton(CallerPid, UserId, Text) ->
  Tweet = tweet:create_tweet(UserId, Text),
  CallerPid ! {tweeted_successfully, tweet:get_tweetTime(Tweet)},

  %% Send to followers
  % Followers = user_account:get_followers(UserId),

  done.


%% Update following list to the user upon clicking the follow button and update followers list of the user being followed
handleFollowButton(CallerPid, UserId, SubId) ->
  user_account:addFollowing(UserId, SubId),
  user_account:addFollower(SubId, UserId),
  CallerPid ! {followed_successfully, UserId, SubId}.

listen_for_events() ->

  done.

start_engine() ->
  %% Register current process
  register(?MODULE, self()),

  %% Listen to the users for distributing tweets and handling queries
  listen_for_events(),

  %% Unregister the current process
  erlang:unregister(?MODULE).
