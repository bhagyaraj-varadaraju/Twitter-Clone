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
-export([registerUser/0, handleTweetButton/3, handleFollowButton/3]).

%% Create user id for the new user
registerUser() ->
%%  Id = getId(),
%%  user_account:create_account(Id).
done.

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
