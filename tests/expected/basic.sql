
select jq('{"a": "xyz"}', '.a') = 'xyz';
1
select jq('{"a": 100}', '.a') = 100;
1
select jq('{"a": 100.0001}', '.a') = 100.0001;
1
select jq('{"a": "sdfgdfg"}', '.b') ISNULL;
1
select jq('{"a": 1}', '.a') = 1;
1
select jq('{"a": true}', '.a') = 1;
1
select jq('{"a": false}', '.a') = 0;
1
