%%%-------------------------------------------------------------------
%%% @author bhagyaraj
%%% @copyright (C) 2022, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 23. Nov 2022 11:37 AM
%%%-------------------------------------------------------------------
-module(user_account).
-author("bhagyaraj").

%% API
-export([create_account/1]).
-export([get_id/1, get_subscriptions/1, get_followers/1]).
-export([addSubscription/2, addFollower/2]).


%% User account data structure.
-record (user, {id, subscriptions = [], followers = []}).

%% Create a new account
create_account(UserId) -> #user{id = UserId}.

%% Get the user's id
get_id(User) -> User#user.id.

%% Get all the user's subscriptions
get_subscriptions(User) -> User#user.subscriptions.

%% Get all the user's followers
get_followers(User) -> User#user.followers.

% Add subscription of another user's tweets to the requested user.
addSubscription(User, Subscription) ->
  Current_list = get_subscriptions(User),
  Updated_list  = [Subscription] ++ Current_list,
  User#user{subscriptions = Updated_list}.

% Add follower(who is subscribed to a user's tweets) to the user when someone subscribes.
addFollower(User, Follower) ->
  Current_list = get_followers(User),
  Updated_list  = [Follower] ++ Current_list,
  User#user{followers = Updated_list}.
