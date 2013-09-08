-module(reviews).
-compile(export_all).
-include_lib("n2o/include/wf.hrl").
-include_lib("kvs/include/products.hrl").
-include_lib("kvs/include/users.hrl").
-include_lib("kvs/include/groups.hrl").
-include_lib("kvs/include/feeds.hrl").
-include_lib("feed_server/include/records.hrl").
-include("records.hrl").

main()-> #dtl{file="prod", bindings=[{title,<<"reviews">>},{body, body()}]}.

body()->
    wf:wire(#api{name=tabshow}),
    wf:wire("$('a[data-toggle=\"tab\"]').on('shown', function(e){"
        "id=$(e.target).attr('href');"
        "if(id!='#all')$('a[href=\"#all\"').removeClass('text-warning');"
        "else $(e.target).parent().find('.text-warning').removeClass('text-warning');"
        "$(e.target).addClass('text-warning').siblings().removeClass('text-warning');"
        "tabshow(id);});"),
    Tab = case wf:qs(<<"id">>) of undefined -> "all"; T ->  T end,
    wf:wire(io_lib:format("$(document).ready(function(){$('a[href=\"#~s\"]').addClass('text-warning').tab('show');});",[Tab])),

    index:header() ++ [
    #section{class=[section], body=[#panel{class=[container], body=[
        #panel{class=["page-header"], body=[
          #h2{body= [
            #link{url="#all", body=[#span{class=["icon-home"]}], data_fields=[{<<"data-toggle">>, <<"tab">>}]},
            #small{body=[
                [<<" / ">>, #link{url="#"++Id, data_fields=[{<<"data-toggle">>, <<"tab">>}], body=[#span{class=["icon-asterisk"]},Name]}]
                || #group{id=Id, name=Name, scope=Scope} <- kvs:all(group), Scope==public ]} ]}
      ]},
      #panel{class=["row-fluid"], body=[
        #panel{class=[span9, "tab-content"], body=[
          #panel{id=all, class=["tab-pane"]},
          [#panel{id=Id, class=["tab-pane"]} || #group{id=Id, scope=Scope} <- kvs:all(group), Scope==public]
        ]},
        #panel{class=[span3], body=[<<"">>]} ]}
  ]}]}
  ] ++ index:footer().

feed("all") ->
    #feed2{title= <<"">>, icon="icon-tags", entry_type=entry, container=feed, container_id=?FEED(entry), selection=false, entry_view=review, table_mode=false};
feed(Group) ->
    case kvs:get(group, Group) of {error,_}->[];
    {ok, G}->
        {_, Id} = lists:keyfind(feed, 1, element(#iterator.feeds, G)),
        #feed2{title= <<"">>, icon="icon-tags", entry_type=entry, container=feed, container_id=Id, selection=false, entry_view=review, table_mode=false} end.

api_event(tabshow,Args,_) ->
    [Id|_] = string:tokens(Args,"\"#"),
    wf:update(list_to_atom(Id), feed(Id)),
    wf:wire("Holder.run();").

event(init) -> wf:reg(?MAIN_CH),[];
event({delivery, [_|Route], Msg}) -> process_delivery(Route, Msg);
event({read, _, {Id,_}})-> wf:redirect("/review?id="++Id);
event({read, _, Id})-> wf:redirect("/review?id="++Id);
event(Event) -> error_logger:info_msg("[reviews]Page event: ~p", [Event]), ok.

process_delivery(R,M) -> feed:process_delivery(R,M).
