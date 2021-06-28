\f','
\a
\o './batalla3.csv'
with filas as (
  select "when" cuando, string_agg('('||ship::text||'|'||magtobossometric_value::text||')'::text, ',' order by sensor) datos
  from measures
  where battle_id=3
  group by "when"
  order by "when"
)
select '' || cuando::text || ',' || datos::text
from filas

