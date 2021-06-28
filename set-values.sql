/*
--indices
create index sensor_battle on measures(sensor asc, battle_id);
create index ship_when on measures(ship, "when");
create index magto_measure on measures(magtobossometric_value asc);
*/

create or replace function set_things(from_when integer, _length integer, sensor_number integer, ship_value varchar, measure_value integer, is_cluster boolean, for_battle_id integer) returns integer as
$$
    declare _min_id integer := (select min(id) from measures where sensor=sensor_number and battle_id=for_battle_id);
begin
    from_when := from_when - 1;
    -- si no se da un valor explicito para la nave, se deja la nave que ya esta
    if(ship_value is null) then
      update measures
        set is_in_cluster=is_cluster,
        magtobossometric_value=measure_value

      where sensor=sensor_number
        and battle_id=for_battle_id
        and id >= (_min_id + from_when) and id < (_min_id + from_when + _length);

    else
      update measures
        set is_in_cluster=is_cluster,
        ship=ship_value,
        magtobossometric_value=measure_value

      where sensor=sensor_number
        and battle_id=for_battle_id
        and id >= (_min_id + from_when) and id < (_min_id + from_when + _length);
    end if;
    return _min_id;
end;
$$ language 'plpgsql';

create or replace function set_clusters(from_when integer, how_many_clusters integer, from_sensor integer, cluster_size integer, for_battle_id integer) returns integer as
$$
  -- Clusters are by default 7 ships wide
  declare _to_sensor integer := 0;
          cluster_counter integer := 0;
begin
    cluster_size := cluster_size - 1;
    while cluster_counter < how_many_clusters loop
      _to_sensor := from_sensor+cluster_size;
      for i in from_sensor.._to_sensor loop
                                                                                -- ?????????????
        perform set_things(from_when:=from_when, _length:=30, sensor_number:=i, ship_value:='Scout vessel', measure_value:=400, is_cluster:='t', for_battle_id:=for_battle_id);
      end loop;
      cluster_counter := cluster_counter + 1;
      from_sensor := _to_sensor + 3; --espacio entre naves es de 3
    end loop;

    return null;
end;
$$ language 'plpgsql';

create or replace function set_clusters_averiados(from_when integer, how_many_clusters integer, from_sensor integer, cluster_size integer, for_battle_id integer) returns integer as
$$
  -- Clusters are by default 7 ships wide
  declare _to_sensor integer := 0;
          cluster_counter integer := 0;
begin
    cluster_size := cluster_size - 1;
    while cluster_counter < how_many_clusters loop
      _to_sensor := from_sensor+cluster_size;
      for i in from_sensor.._to_sensor loop
        perform set_things(from_when:=from_when, _length:=32, sensor_number:=i, ship_value:='-', measure_value:=0, is_cluster:='f', for_battle_id:=for_battle_id);
      end loop;
      cluster_counter := cluster_counter + 1;
      from_sensor := _to_sensor + 3; --espacio entre naves es de 3
    end loop;

    return null;
end;
$$ language 'plpgsql';


create or replace function is_a_guardian_de(_when timestamp without time zone, _battle_id bigint, _ship character varying, _magtobossometric_value integer) returns integer as
$$
  declare final_result integer := 0;
begin
with enemies as (
  select *
  from measures
  where battle_id=_battle_id
  and "when"=_when
  and ship!='-'
),
total_enemies as (
  select count(*)::float total
  from enemies
),
guards as (
  select count(*)::float total
  from enemies
  where is_bodyguard='t'
),
nonguards as (
  select count(*)::float total
  from enemies
  where is_bodyguard='f'
),
guard_and_ship as (
  select count(*)::float total
  from enemies
  where is_bodyguard='t'
  and ship=_ship
),
nonguard_and_ship as (
  select count(*)::float total
  from enemies
  where is_bodyguard='f'
  and ship=_ship
),
by_ship as (
  select count(*)::float total
  from enemies
  where is_bodyguard='t'
  and ship=_ship
),
by_nonship as (
  select count(*)::float total
  from enemies
  where is_bodyguard='f'
  and ship=_ship
),
guard_and_measure as (
  select count(*)::float total
  from enemies
  where is_bodyguard='t'
  and magtobossometric_value=1234
),
nonguard_and_measure as (
  select count(*)::float total
  from enemies
  where is_bodyguard='f'
  and magtobossometric_value=1234
),
probabilidades_parciales as (
  select total_enemies.total, guards.total, nonguards.total, guard_and_ship.total, nonguard_and_ship.total, by_ship.total,
  by_nonship.total, guard_and_measure.total, nonguard_and_measure.total,

  guards.total                 /  total_enemies.total           PEscolta,
  nonguards.total              /  total_enemies.total           PNoEscolta,

  guard_and_ship.total         /  guards.total                  PEscolta_Dado_Nave,
  nonguard_and_ship.total      /  nonguards.total               PNoEscolta_Dado_Nave,

  guard_and_measure.total      /  guards.total                  PEscolta_Dado_Medida,
  nonguard_and_measure.total   /  nonguards.total               PNoEscolta_Dado_Measure

  from total_enemies, guards, nonguards, guard_and_ship, nonguard_and_ship, by_ship, by_nonship, guard_and_measure, nonguard_and_measure
),
probabilidades_conjuntas as (
  select PEscolta_Dado_Nave*PEscolta_Dado_Medida*PEscolta PEscoltaNaveMedida,
  PNoEscolta_Dado_Nave*PNoEscolta_Dado_Measure*PNoEscolta PNEscoltaNaveMedida
  
  from probabilidades_parciales
),
bayes as (
  select (case when PEscoltaNaveMedida=0.0 then 0.0 else (PEscoltaNaveMedida/(PEscoltaNaveMedida+PNEscoltaNaveMedida)) end) p from probabilidades_conjuntas
)
select (min(bayes.p) * 1000)::integer into final_result from bayes;
return final_result;
end;
$$ language 'plpgsql';
-- ships = ['Starfighter','Bomber','Scout vessel','Gunship']
-- primera batalla tiene 3 sensores

/*
-- alerta real
select set_things(from_when:=09, _length:=30, sensor_number:=1, ship_value:='Starfighter', measure_value:=103, is_cluster:='f', for_battle_id:=1);
select set_things(from_when:=42, _length:=10, sensor_number:=1, ship_value:='Scout vessel', measure_value:=2000, is_cluster:='f', for_battle_id:=1);

select set_things(from_when:=01, _length:=30, sensor_number:=2, ship_value:='Gunship',     measure_value:=1200, is_cluster:='f', for_battle_id:=1);
select set_things(from_when:=35, _length:=30, sensor_number:=2, ship_value:='Bomber',      measure_value:=103, is_cluster:='f', for_battle_id:=1);

select set_things(from_when:=3, _length:=32, sensor_number:=3, ship_value:='-', measure_value:=0, is_cluster:='f', for_battle_id:=1);
select set_things(from_when:=39, _length:=5, sensor_number:=3, ship_value:='-', measure_value:=0, is_cluster:='f', for_battle_id:=1);
*/



/*
-- estadisticas
select count(distinct "when") total_mediciones from measures;
select count(distinct sensor) total_sensores from measures;
select count(ship) ships, count(sensor) sensores from measures where magtobossometric_value > 100 group by battle_id, "when";
*/

-- la medida para los escoltas debe ser de 1234
--select set_clusters(from_when:=1,     how_many_clusters:=600,      from_sensor:=1,     cluster_size:=7,           for_battle_id:=4);
--select set_clusters(from_when:=40,     how_many_clusters:=800,      from_sensor:=2500,  cluster_size:=9,           for_battle_id:=4);
--select set_clusters(from_when:=5,     how_many_clusters:=400,      from_sensor:=60000, cluster_size:=7,           for_battle_id:=4);
--select set_clusters(from_when:=6,     how_many_clusters:=500,      from_sensor:=80000, cluster_size:=24,          for_battle_id:=4);

--select set_things(from_when:=09, _length:=30, sensor_number:=180000, ship_value:='Starfighter', measure_value:=1234, is_cluster:='f', for_battle_id:=4);
--select set_things(from_when:=42, _length:=10, sensor_number:=130000, ship_value:='Scout vessel', measure_value:=1234, is_cluster:='f', for_battle_id:=4);

--select set_clusters_averiados(from_when:=17,     how_many_clusters:=500,      from_sensor:=13000,     cluster_size:=17,           for_battle_id:=4);
--select set_clusters_averiados(from_when:=35,     how_many_clusters:=700,      from_sensor:=23000,  cluster_size:=9,           for_battle_id:=4);


/*
  with filas as (
    select "when" cuando, string_agg('('||ship::text||','||lpad(magtobossometric_value::text,3,' ')||')'::text, ',' order by sensor) datos
    from measures
    where measures.battle_id=1
    and sensor >= 5
    and sensor <= 50
    group by "when"
    order by "when"
  )
  select '' || cuando::text || ',' || datos::text as measurements
  from filas;
*/

/*--   id    |        when         | sensor |  ship  | magtobossometric_value | is_in_cluster |     created_at      |     updated_at      | battle_id

(select count(*) total_naves                                    from measures where battle_id=1 and "when"='2021-06-26 10:49:40' and ship != '-') total,
(select count(*) total_naves_en_clusters                        from measures where battle_id=1 and "when"='2021-06-26 10:49:40' and shoy != '-' is_in_cluster='t') in_cluster,
(select magtobossometric_value, count(*) total_naves_por_medida from measures where battle_id=1 and "when"='2021-06-26 10:49:40' and ship != '-' group by magtobossometric_value; 

select ship, count(*) total_naves_por_tipo                     from measures where battle_id=1 and "when"='2021-06-26 10:49:40' and ship != '-' group by ship),


(Starfighter|103),(Gunship|1200),(-|0),(-|43)

p(E|Starfighter)=p(Starfighter|E)*p(E) / (p(Starfighter|E)*p(E)+p(Starfighter|~E)p(~E)
p(E|103)


select count(*)
from measures where 
*/

/*
select "when" cuando, string_agg(lpad(is_a_guardian_de("when", battle_id, ship, magtobossometric_value)::text, 3, ' '), ',' order by sensor) datos
from measures
where battle_id=3 and "when"='2021-06-25 21:22:33'
group by "when"
order by "when"
*/

/* Cluster para la batalle 3 con valores para identificar el fantasma

118 cluster
  7 naves por cluster
*/
--select set_clusters(from_when:=179,      how_many_clusters:=118,      from_sensor:=65000, cluster_size:=7,           for_battle_id:=4);
/*
5 naves del grupo escolta tienen la medida
*/
-- update measures set magtobossometric_value=1234 where sensor in (65009, 65011, 65013, 65014, 65015) and battle_id=4 and "when"='2021-06-26 01:55:03' and is_in_cluster='t';
-- la medida para los escoltas debe ser de 1234

/*

138 sensores que estan fuera de grupo escolta que tienen la medidia de 1234

with _138 as (select sensor from measures where battle_id=4 and "when"='2021-06-26 01:55:03' and is_in_cluster='t' and sensor
	>65030 order by sensor limit 138) select string_agg(sensor::text, ',') from _138;

select count(*) from measures
where battle_id=4 and "when"='2021-06-26 01:55:03' and is_in_cluster='t' and sensor >65030 and sensor in (
 65031,65032,65033,65036,65037,65038,65039,65040,65041,65042,65045,65046,65047,65048,65049,65050,65051,65054,65055,65056,65057,65058,65059,65060,65063,65064,65065,65066,65067,65068,65069,65072,65073,65074,65075,65076,65077,65078,65081,65082,65083,65084,65085,65086,65087,65090,65091,65092,65093,65094,65095,65096,65099,65100,65101,65102,65103,65104,65105,65108,65109,65110,65111,65112,65113,65114,65117,65118,65119,65120,65121,65122,65123,65126,65127,65128,65129,65130,65131,65132,65135,65136,65137,65138,65139,65140,65141,65144,65145,65146,65147,65148,65149,65150,65153,65154,65155,65156,65157,65158,65159,65162,65163,65164,65165,65166,65167,65168,65171,65172,65173,65174,65175,65176,65177,65180,65181,65182,65183,65184,65185,65186,65189,65190,65191,65192,65193,65194,65195,65198,65199,65200,65201,65202,65203,65204,65207,65208
)
*/
/*
update measures set magtobossometric_value=1234 where sensor in (
65031,65032,65033,65036,65037,65038,65039,65040,65041,65042,65045,65046,65047,65048,65049,65050,65051,
65054,65055,65056,65057,65058,65059,65060,65063,65064,65065,65066,65067,65068,65069,65072,65073,65074,
65075,65076,65077,65078,65081,65082,65083,65084,65085,65086,65087,65090,65091,65092,65093,65094,65095,
65096,65099,65100,65101,65102,65103,65104,65105,65108,65109,65110,65111,65112,65113,65114,65117,65118,
65119,65120,65121,65122,65123,65126,65127,65128,65129,65130,65131,65132,65135,65136,65137,65138,65139,
65140,65141,65144,65145,65146,65147,65148,65149,65150,65153,65154,65155,65156,65157,65158,65159,65162,
65163,65164,65165,65166,65167,65168,65171,65172,65173,65174,65175,65176,65177,65180,65181,65182,65183,
65184,65185,65186,65189,65190,65191,65192,65193,65194,65195,65198,65199,65200,65201,65202,65203,65204,
65207,65208
) and battle_id=4 and "when"='2021-06-26 01:55:03' and is_in_cluster='t';
*/



/*
6 naves del grupo escolta son Bomber

update measures set ship='Bomber' 
where sensor in ( 65009, 65010, 65011, 65012, 65013, 65014) and battle_id=4 and "when"='2021-06-26 01:55:03' and is_in_cluster='t';

*/
/*
234 naves del grupo que no es escolta son de tipo Bomber

para generar los sensores usando ruby
234.times{|i| print "#{65213+3*i},"}

select count(*) from measures where sensor in(
-- aqui van los numeros generados en el paso anterior
) and battle_id=3 and "when"='2021-06-26 01:55:03' and is_in_cluster='t';

update measures set ship='Bomber' where sensor in (
65213,65216,65219,65222,65225,65228,65231,65234,65237,65240,65243,65246,65249,65252,65255,65258,65261,
65264,65267,65270,65273,65276,65279,65282,65285,65288,65291,65294,65297,65300,65303,65306,65309,65312,
65315,65318,65321,65324,65327,65330,65333,65336,65339,65342,65345,65348,65351,65354,65357,65360,65363,
65366,65369,65372,65375,65378,65381,65384,65387,65390,65393,65396,65399,65402,65405,65408,65411,65414,
65417,65420,65423,65426,65429,65432,65435,65438,65441,65444,65447,65450,65453,65456,65459,65462,65465,
65468,65471,65474,65477,65480,65483,65486,65489,65492,65495,65498,65501,65504,65507,65510,65513,65516,
65519,65522,65525,65528,65531,65534,65537,65540,65543,65546,65549,65552,65555,65558,65561,65564,65567,
65570,65573,65576,65579,65582,65585,65588,65591,65594,65597,65600,65603,65606,65609,65612,65615,65618,
65621,65624,65627,65630,65633,65636,65639,65642,65645,65648,65651,65654,65657,65660,65663,65666,65669,
65672,65675,65678,65681,65684,65687,65690,65693,65696,65699,65702,65705,65708,65711,65714,65717,65720,
65723,65726,65729,65732,65735,65738,65741,65744,65747,65750,65753,65756,65759,65762,65765,65768,65771,
65774,65777,65780,65783,65786,65789,65792,65795,65798,65801,65804,65807,65810,65813,65816,65819,65822,
65825,65828,65831,65834,65837,65840,65843,65846,65849,65852,65855,65858,65861,65864,65867,65870,65873,
65876,65879,65882,65885,65888,65891,65894,65897,65900,65903,65906,65909,65912
) and battle_id=4 and "when"='2021-06-26 01:55:03' and is_in_cluster='t';
*/


/*
update measures
set ship='Bomber'
where sensor=65045
and battle_id=4 and "when"='2021-06-26 01:55:03' and is_in_cluster='t';

update measures
set ship='Gunship'
where sensor=65219
and ship='Bomber'
and battle_id=4 and "when"='2021-06-26 01:55:03' and is_in_cluster='t';
*/

/*
select count(*)
from measures
ship='Bomber'
and battle_id=3 and "when"='2021-06-25 21:22:33' and is_in_cluster='t';
*/
/*
--se me duplicaron datos de la batalla 3
with duplicados as (select battle_id, "when", sensor, count(*) total from measures where battle_id=3 group by battle_id, "when", sensor having count(*) >1)
select *
from measures m join duplicados on m.battle_id=duplicados.battle_id and m."when"=duplicados."when" and m.sensor=duplicados.sensor
order by id asc


delete from measures
where battle_id=3
and id >=61189721
and id <=61190812
*/
