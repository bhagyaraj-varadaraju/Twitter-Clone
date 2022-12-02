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
-define(MAX_REQ, 50).


send_requests(UserId, RequestList, CurrentRequest, MaxRequests, N) ->
  if
    CurrentRequest > MaxRequests ->
      io:format("User ~p successfully completed ~p operations~n", [UserId, MaxRequests]);
    true ->
      receive
        {receive_tweet, _TweetId, _SenderUserId, _TweetContent} ->
          done;
        {receive_tweet, _SenderUserId, _TweetContent} ->
          done

      after 0 ->
        case utils:get_random_element(RequestList) of
          %% Post tweet to followers
          post_tweet ->
            Tweet_content = utils:generate_tweet_text(),
            server ! {post_tweet, UserId, Tweet_content, self()},
            receive
              {tweet_success} -> send_requests(UserId, RequestList, CurrentRequest + 1, MaxRequests, N)
            end;

          %% Subscribe to user's tweets
          subscribe ->
            ChosenUserIndex = rand:uniform(trunc(0.25 * N)),
            UserIdToSub = "usr" ++ integer_to_list(ChosenUserIndex),
            server ! {subscribe, UserId, UserIdToSub, self()},
            receive
              {subscribe_success} -> send_requests(UserId, RequestList, CurrentRequest + 1, MaxRequests, N)
            end;

          %% Retweet some of the received tweets
          retweet ->
            %% Select a hashtag for retweeting tweets containing it
            Hashtags = ets:select(hashtagTable, [{{'$1'}, [], ['$1']}]),
            HashTagSelected = lists:nth(rand:uniform(length(Hashtags)), Hashtags),
            server ! {search_hashtag, HashTagSelected, self()},

            receive
              {hashtag_search_success, TweetsWithHashtag} ->
                case utils:get_random_element(TweetsWithHashtag) of
                  empty_array -> send_requests(UserId, RequestList, CurrentRequest, MaxRequests, N);

                  TweetContent ->
                    server ! {retweet, UserId, TweetContent, self()},
                    receive
                      {retweet_success} -> send_requests(UserId, RequestList, CurrentRequest + 1, MaxRequests, N)
                    end
                end
            end;

          %% Search for a specific hashtag
          search_hashtag ->
            Hashtags = ets:select(hashtagTable, [{{'$1'}, [], ['$1']}]),
            HashTagToSearch = lists:nth(rand:uniform(length(Hashtags)), Hashtags),
            server ! {search_hashtag, HashTagToSearch, self()},

            receive
              {hashtag_search_success, _TweetsWithHashtag} ->
                %% lists:foreach(fun(X) -> io:format("[~p] - ~p ~n", [UserId, X]) end, TweetsWithHashtag),
                send_requests(UserId, RequestList, CurrentRequest + 1, MaxRequests, N)
            end;

          %% Search for my mentions
          search_mention ->
            server ! {search_mention, UserId, self()},
            receive
              {mention_search_success, _TweetsWithMyMention} ->
                %% lists:foreach(fun(X) -> io:format("[~p] - ~p ~n", [UserId, X]) end, TweetsWithMyMention),
                send_requests(UserId, RequestList, CurrentRequest + 1, MaxRequests, N)
            end
        end
      end
    end.


%% Handle user process
start_user(MyIndex, UserId, N) ->
  %% Signup the user by inserting into the ETS table in the format {ActorIndex, UserId, Following, Followers, ActorPID}
  ets:insert(userTable, {MyIndex, UserId, [], [], self()}),

  %% Create a list of requests to be performed
  RequestList = lists:append(lists:duplicate(rand:uniform(?MAX_REQ), post_tweet),
    lists:append(lists:duplicate(rand:uniform(?MAX_REQ), subscribe),
      lists:append(lists:duplicate(rand:uniform(?MAX_REQ), retweet),
        lists:append(lists:duplicate(rand:uniform(?MAX_REQ), search_hashtag), lists:duplicate(rand:uniform(?MAX_REQ), search_mention))))),

  %% send the requests to the server by selecting from the list
  send_requests(UserId, RequestList, 1, length(RequestList), N),

  %% Send the completed message to the server
  server ! {client_done}.
