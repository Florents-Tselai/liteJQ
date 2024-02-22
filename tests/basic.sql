.load ./litejq
.echo on

select jq('{"a": "xyz"}', '.a') = 'xyz';
select jq('{"a": 100}', '.a') = 100;
select jq('{"a": 100.0001}', '.a') = 100.0001;
select jq('{"a": "sdfgdfg"}', '.b') ISNULL;
select jq('{"a": 1}', '.a') = 1;
select jq('{"a": true}', '.a') = 1;
select jq('{"a": false}', '.a') = 0;