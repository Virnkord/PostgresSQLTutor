---- db: -h localhost -p 5433 -U postgres newdase
--Creating a new table
           CREATE TABLE listofphones(
                  username VARCHAR(20),
                  home VARCHAR(30),
                  mobile VARCHAR(30),
                  worknum VARCHAR(30)
                  );

----
--adding a new line to the table
INSERT INTO listofphones VALUES('Pit', '555-67-12', '+79214704747', '88122003040');

----
  --Viewing a table
  \dt listofphones
--\dt encounter
----
  --Viewing table content
  SELECT * FROM listofphones
----
  --Update table info
  UPDATE listofphones
         SET home = '888-95-95'
         WHERE username = 'Pit';
----
  --Viewing table info
  SELECT * FROM patient;
----
  --Table cleaning
  DELETE FROM listofphones;
----
  --SELECT resource#>>'{activestatus}'
  --FROM patient
  --WHERE resource#>>'{name,0,given,0}' > 'A'
  --LIMIT 5
----
  --Updating "patient" table info
  UPDATE patient
         SET resource = resource || '{"activestatus": true}'::jsonb
         WHERE resource#>>'{birthDate}' = '1913-01-22';
----
  --Name and surname of active patients
    SELECT resource#>>'{name,0,given,0}', resource#>>'{name,0,family}'
    FROM patient
    WHERE (resource#>>'{activestatus}')::boolean = true;
----
    --Surnames of patients born after 2017
    SELECT resource#>>'{name,0,family}'
    FROM patient
    WHERE resource#>>'{birthDate}'>'2017-01-01';
----
    --All patients born after
    SELECT resource#>>'{name,0,family}' firstt, resource#>>'{birthDate}' secondd
    FROM patient
    WHERE resource#>>'{birthDate}' like '1913%';
----
    --Least 10 birth dates >2000-01-01
    SELECT resource#>>'{birthDate}' 
    FROM patient
    WHERE resource#>>'{birthDate}'>'2000-01-01'
    ORDER BY resource#>>'{birthDate}' 
    LIMIT 10;
----
    --Top 10 most sick
    SELECT p.resource#>>'{name,0,given,0}' AS patient_name, enc.cnt AS num from patient p
    join(
    select e.resource#>>'{subject,id}' as pt_id,
    count(*) as cnt
    from encounter e
    group by e.resource#>>'{subject,id}'
    )as enc
    on p.id = enc.pt_id
    order by enc.cnt desc
    limit 10
----
\dt condition

----
  --Convenient resource view
SELECT jsonb_pretty(resource) from condition

----
    --Amount of hits with a particular disease
    select c.resource#>>'{code,text}' AS disease, count(*) as num
    from condition c
    group by c.resource#>>'{code,text}'
    order by num desc 

----
    --Most popular disease
    select c.resource#>>'{code, text}' AS disease, count(distinct c.resource#>>'{subject,id}') as num
    from condition c
    group by disease
    order by num desc
----
--List of number of visits due to illness
          select p.resource#>>'{name,0,given,0}' as patient_name, p.resource#>>'{name,0,family}' AS patient_family, con.disease, con.num as list from patient p
          join(select c.resource#>>'{code, text}' AS disease,  c.resource#>>'{subject,id}' AS patient_id, count(*) as num
          from condition c
          group by disease, c.resource#>>'{subject,id}'
          order by num desc) as con
          on con.patient_id = p.id and con.num > 4
          --order by list desc
----
