use copyworld_db;
show tables;
select * from city;
select * from countrylanguage;
select * from country;

-- Triggers

alter table city
add column last_update timestamp;


-- Creating a trigger that automatically updates the last_update column of the city table whenever a city's details are updated.
delimiter //
create trigger updateCitylastUpdate 
before update on city 
for each row
begin
   set new.last_update = NOW();
end //
delimiter ;

update  city set population = 593395 where id = 6;

-- Developing a trigger to log any deletions of rows from the countrylanguage table into a separate log table with the details of the updated row.
create table countryupdate_log (
   LogID int auto_increment primary key,
    CountryCode char(3),
    Language varchar(52),
    IsOfficial enum('T', 'F'),
    Percentage varchar(26),
    updatedOn timestamp default current_timestamp
);
describe countrylanguage;
delimiter //
create trigger Logcountrylanguageupdate 
after update on countrylanguage
for each row
begin
    insert into countryupdate_log (CountryCode, Language, IsOfficial, Percentage) 
    values (OLD.CountryCode, OLD.Language, OLD.IsOfficial, OLD.Percentage);
end //
delimiter ;
update countrylanguage set isofficial = 'T' where language = "tamil" and countrycode = "Ind" ;
select * from countryupdate_log;
-- Query for trigger to prevent any insertions into the countrylanguage table if the language is not one of the official languages listed in a predefined set.
delimiter //
create trigger PreventInvalidLanguageInsertion 
before insert on countrylanguage 
for each row
begin
   if new.language not in ('tamil', 'English', 'French', 'Spanish', 'Chinese') then
        signal sqlstate '45000' set message_text = 'Invalid language.';
    end if;
end //
delimiter ;
insert into countrylanguage ( countrycode, language, isofficial, percentage) values("IND", "baduga", "F", 0.9)
-- 14:07:32	insert into countrylanguage ( countrycode, language, isofficial, percentage) values("IND", "baduga", "F", 0.9)	Error Code: 1644. Invalid language.	0.015 sec

-- stored Procedures
-- GetCountriesByPopulation
-- This stored procedure retrieves the names of countries with a population greater than a specified minimum value.
delimiter //
create procedure GetCountriesByPopulation(IN minPopulation INT)
begin
   select name
    from country 
    where Population > minPopulation;
end //
delimiter ;
call GetCountriesByPopulation(9207326);
-- This stored procedure takes a country name as input and returns the names and populations of cities in that country.
delimiter //
create procedure GetCitiesByCountry(in countryName varchar(50))
begin
    select city.name, city.Population 
    from city 
    join country on city.CountryCode = country.Code 
    where country.name = countryName;
end //
delimiter ;
call GetCitiesByCountry('Benin');
-- This stored procedure calculates the average population of cities within a given country based on the country code.
delimiter //
create procedure GetAvgCityPopulation(in countryCode char(3))
begin
    select avg(Population) as AvgPopulation 
    from city 
    where CountryCode = countryCode;
end //
delimiter ;
call GetAvgCityPopulation("IND");