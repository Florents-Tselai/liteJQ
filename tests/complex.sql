.load ./litejq
.echo on

select jq('{"a":2,"c":[4,5,{"f":7}]}', '.');
select jq('{"a":2,"c":[4,5,{"f":7}]}', '.a');
select jq('{"a":2,"c":[4,5,{"f":7}]}', '.c');
select jq('{"a":2,"c":[4,5,{"f":7}]}', '.c[2]');
select jq('{"a":2,"c":[4,5,{"f":7}]}', '.c[2].f');