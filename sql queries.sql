use irctc;
/*
-- update using case
update tickets 
set fare = case  
	when fare <= 1223 
	then fare*1.1
	else fare *1.05
	end
    where fare < 5000;

-- diff b/w max and min capacity trains and there avg
select max(totalseats ) from trains - select min(total seats) from trains;
*/

/*1 find 2nd highest ticket fare*/
select distinct fare 
	from tickets t1 
	where 2 = (select count(distinct fare) 
	from tickets t2 
    where t1.fare <= t2.fare);

/*2 max fares of trains grouped by sources*/
select source, max(fare) from tickets group by source having max(fare) > (select avg(fare) from tickets);

-- 3 free seats in a train
select trainno,totalseats , 
	(totalseats - (select count(trainno) from tickets ti where ti.trainno = t.trainno)) as free_seats 
    from trains t where t.trainno = "11084";

-- 4 total capacity of a station
select sum(totalseats) as total_capacity from trains where source = 2 or destination = 3; 


-- 5 details of the passenger having highest fare
select * from passengers where pnr=(
select pnr from tickets where fare=(
select max(fare) from tickets));

-- 6 avg fare of persons having age > 18 and fare < 1000
select avg(fare)
from tickets where pnr in (
select pnr from passengers where age >18 and fare <1000);

-- 7 passengers having age > avg(age)
select * 
from passengers where age >(
select avg(age) from passengers);

-- 8
create view ticketinfo as 
	select t.pnr , p.name as passengers_name , u.name as user_name, u.userid 
    from tickets t, passengers p , user u 
    where u.userid= p.userid and p.pnr = t.pnr;
    
-- 9
Select ti.pnr,ti.fare,ti.trainno,ti.departuredatetime,
	t.totalseats,t.source,t.destination
	from tickets as ti ,trains as t 
    where ti.trainno = t.trainno and t.departuredateandtime 
	between '6992-01-19 19:16:46' and '9276-10-20 07:53:08' 
    order by pnr;/* trains available between two dates*/

-- 10
Select t.source,s.stationname,count(*) as "NoOfTrainsLeaving" 
	from trains as t , stations as s where t.source = s.stationcode 
    group by source;/*no of trains leaving a source station*/
    
-- 11
Select p.userid,sum(fare),count(p.pnr) as 'tickets booked' 
	from tickets as t,passengers as p where t.pnr = p.pnr group by p.userid;/*no of tickets booked by a user and total fare*/
    
-- 12
Select t.pnr,p.name,p.age,t.trainno, t.departuredatetime as "Departure Date And Time"
	from tickets as t,passengers as p where t.pnr = p.pnr and userid = 11;/* */
    
-- Indexing

create index pnr_index on tickets(pnr);
create index fare_index on tickets(fare);
create index user_index on user(userid);
create index trainno_index on trains(trainno);
create index pass_pnr_index on passengers(pnr);
create index station_index on stations(stationcode);

-- QUERY OPTIMIZATION
-- 1
select sum(totalseats) as total_capacity 
	from trains where source = 2 
    union 
    select sum(totalseats) as total_capacity 
    from trains where destination = 3;  
    
-- 2
select trainno,totalseats , 
	(totalseats - (select count(trainno) from tickets ti where ti.trainno = t.trainno)) as free_seats 
    from trains t where t.trainno = "11084";
    
-- 3
select passengers.pnr, passengers.name from passengers where passengers.name like 'J%';

-- 4
select * 
from passengers where age >18 limit 10;

