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
-export([get_id/1, get_following/1, get_followers/1]).
-export([addFollowing/2, addFollower/2]).

-define(MAX_TWEETS, 100).


%% Get the user's id
get_id(User) -> User#user.id.

%% Get all the user's subscriptions
get_following(User) -> User#user.following.

%% Get all the user's followers
get_followers(User) -> User#user.followers.

% Add subscription of another user's tweets to the requested user.
addFollowing(User, Subscription) ->
  Current_list = get_following(User),
  Updated_list  = [Subscription] ++ Current_list,
  User#user{following = Updated_list}.

% Add follower(who is subscribed to a user's tweets) to the user when someone subscribes.
addFollower(User, Follower) ->
  Current_list = get_followers(User),
  Updated_list  = [Follower] ++ Current_list,
  User#user{followers = Updated_list}.

%% Handle user process
start_user(MyIndex, UserId, _N) ->
  %% Sign up the client using UserID
  MyUserRecord = #user{id = UserId},

  %% Create a stats data structure
  _ClientStats = #perf_stats{},

  %% Insert into the ETS table in the format {ActorIndex, UserId, ActorPID}
  ets:insert(userTable, {MyIndex, MyUserRecord, self()}),

  %% Send tweet and insert into tweet table
  Tweet_content = utils:generate_tweet_text(),
  NewTweetRecord = tweet_handler:create_tweet(MyUserRecord#user.id, Tweet_content),
  ets:insert(tweetTable, {NewTweetRecord}),
  io:format("New Tweet [~p] ~n", [Tweet_content]),

  server ! {client_done}.


