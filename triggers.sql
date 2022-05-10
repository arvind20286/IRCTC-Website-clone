delimiter $$
create trigger for_passenger1 before insert on passengers
for each row
begin
 if new.name = '' then
 signal sqlstate '45000' set message_text = 'Name should not be null';
 end if;
end$$
delimiter ;



delimiter $$
create trigger for_tickets1 before insert on tickets
for each row
begin
 if new.source = new.destination then
 signal sqlstate '45000' set message_text = 'Source and destination should be different.';
 end if;
end$$
delimiter ;

delimiter $$
CREATE TRIGGER before_update_dare
BEFORE UPDATE ON tickets
FOR EACH ROW
BEGIN
   IF NEW.fare <> OLD.fare THEN
	INSERT INTO fare_changes(pnr,old_fare,new_fare)
        VALUES(NEW.pnr,OLD.fare,NEW.fare);
    END IF;
END$$
delimiter ;


delimiter //
create trigger age_verify
before insert on passengers 
for each row 
if new.age<0 then set new.age=20;
end if; //

delimiter //
create trigger check_null_depdate 
after insert 
on tickets
for each row
begin
if new.departuredatetime is null then
insert into message(messageID,message)
values (new.pnr, concat('hi',new.pnr,',please update your departure date and time'));
end if ;
end //
delimiter ;

delimiter $$
DROP TRIGGER IF EXISTS t_passenger_delete;
GO
CREATE TRIGGER t_passenger_delete ON passenger INSTEAD OF DELETE
AS BEGIN
    DECLARE @id INT;
    DECLARE @count INT;
    SELECT @id = id FROM DELETED;
    SELECT @count = COUNT(*) FROM tickets WHERE pnr = @id;
    IF @count = 0
        DELETE FROM passengers WHERE id = @id;
    ELSE
        THROW 51000, 'can not delete - passenger is referenced in other tables', 1;
END $$
delimiter ;






