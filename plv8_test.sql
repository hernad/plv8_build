create or replace function plv8_test(input text) returns text as $$
  return 'x ' + input + ' x';
$$ LANGUAGE plv8 immutable strict;


select plv8_test('jedan');

CREATE OR REPLACE FUNCTION plv8_test_2(keys text[], vals text[]) RETURNS text AS 
$$ 
var o = {}; 
for(var i=0; i<keys.length; i++)
{  
   o[keys[i]] = vals[i]; 
} 

return JSON.stringify(o); 

$$ LANGUAGE plv8 IMMUTABLE STRICT;  

SELECT plv8_test_2(ARRAY['name', 'age'], ARRAY['Tom', '29']);
 