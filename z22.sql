ALTER SESSION SET CURRENT_SCHEMA = erd;
--1  Ispisati nazive bez ponavljanja svih pravnih lica za koje postoji fizičko lice na istoj lokaciji'

select distinct p.naziv as ResNaziv
from pravno_lice p, fizicko_lice f, lokacija l
where p.lokacija_id=l.lokacija_id and f.lokacija_id=l.lokacija_id;

--provjera
--1. Rezultat: 207
SELECT Sum(Length(ResNaziv)*3) FROM
(select distinct p.naziv as ResNaziv
from pravno_lice p, fizicko_lice f, lokacija l
where p.lokacija_id=l.lokacija_id and f.lokacija_id=l.lokacija_id);

--slanje
--1. Rezultat:  483
SELECT Sum(Length(ResNaziv)*7) FROM
(select distinct p.naziv as ResNaziv
from pravno_lice p, fizicko_lice f, lokacija l
where p.lokacija_id=l.lokacija_id and f.lokacija_id=l.lokacija_id);
 

--2  Ispisati bez ponavljanja datum potpisivanja ugovora (u formatu dd.MM.yyyy) i naziv
--pravnog lica za sve ugovore kod kojih je datum potpisivanja poslije prvog datuma
--kupoprodaje faktura koje sadrže proizvod kod kojeg broj mjeseci garancije nije null.

select distinct to_char(u.datum_potpisivanja, 'dd.MM.yyyy') "Datum Potpisivanja", p.naziv as ResNaziv
from ugovor_za_pravno_lice u , pravno_lice p
where p.pravno_lice_id=u.pravno_lice_id and
u.datum_potpisivanja > (select min(f.datum_kupoprodaje)
                        from faktura f, proizvod p, narudzba_proizvoda n
                        where f.faktura_id=n.faktura_id and n.proizvod_id = p.proizvod_id and 
                        p.broj_mjeseci_garancije is  not null);


--provjera--2. Rezultat: 402 
SELECT Sum(Length(ResNaziv)*3 + Length("Datum Potpisivanja")*3) FROM
(
select distinct to_char(u.datum_potpisivanja, 'dd.MM.yyyy') "Datum Potpisivanja", p.naziv as ResNaziv
from ugovor_za_pravno_lice u , pravno_lice p
where p.pravno_lice_id=u.pravno_lice_id and
u.datum_potpisivanja > (select min(f.datum_kupoprodaje)
                        from faktura f, proizvod p, narudzba_proizvoda n
                        where f.faktura_id=n.faktura_id and n.proizvod_id = p.proizvod_id and 
                        p.broj_mjeseci_garancije is  not null)

);

--2. Rezultat:  938
SELECT Sum(Length(ResNaziv)*7 + Length("Datum Potpisivanja")*7) FROM
(select distinct to_char(u.datum_potpisivanja, 'dd.MM.yyyy') "Datum Potpisivanja", p.naziv as ResNaziv
from ugovor_za_pravno_lice u , pravno_lice p
where p.pravno_lice_id=u.pravno_lice_id and
u.datum_potpisivanja > (select min(f.datum_kupoprodaje)
                        from faktura f, proizvod p, narudzba_proizvoda n
                        where f.faktura_id=n.faktura_id and n.proizvod_id = p.proizvod_id and 
                        p.broj_mjeseci_garancije is  not null));
 
--3  Ispisati nazive proizvoda čija je kategorija jednaka bar jednoj kategoriji proizvoda čija je
--ukupna količina jednaka maksimalnoj od ukupnih količina svakog proizvoda posebno.

select p.naziv as naziv
from proizvod p
where p.kategorija_id= any( select p1.kategorija_id
                        from proizvod p1, kolicina k
                        where  p1.proizvod_id=k.proizvod_id and
                        k.kolicina_proizvoda = (select max(kolicina_proizvoda) 
                                                from kolicina));


--provjera--3. Rezultat: 51
SELECT Sum(Length(naziv)*3) FROM
(select p.naziv as naziv
from proizvod p
where p.kategorija_id= any( select p1.kategorija_id
                        from proizvod p1, kolicina k
                        where  p1.proizvod_id=k.proizvod_id and
                        k.kolicina_proizvoda = (select max(kolicina_proizvoda) 
                                                from kolicina)));



--3. Rezultat: 119
SELECT Sum(Length(naziv)*7) FROM
(select p.naziv as naziv
from proizvod p
where p.kategorija_id= any( select p1.kategorija_id
                        from proizvod p1, kolicina k
                        where  p1.proizvod_id=k.proizvod_id and
                        k.kolicina_proizvoda = (select max(kolicina_proizvoda) 
                                                from kolicina)));


--4 Ispisati nazive proizvoda i nazive proizvođača za sve proizvode za čijeg proizvođača
--postoji proizvod čija je cijena proizvoda veća od prosjeka cijena svih proizvoda.

select p.naziv as "Proizvod" , lice.naziv as "Proizvodjac"
from proizvod p , proizvodjac pr, pravno_lice lice 
where  exists(select 'a' from proizvod p2
                        where pr.proizvodjac_id=p2.proizvodjac_id and 
                        p2.cijena>(select avg(p1.cijena)
                    from proizvod p1))
and p.proizvodjac_id=pr.proizvodjac_id and lice.pravno_lice_id=pr.proizvodjac_id;

--provjera --4. Rezultat: 504  
SELECT Sum(Length("Proizvod")*3 + Length("Proizvodjac")*3) FROM
(select p.naziv as "Proizvod" , lice.naziv as "Proizvodjac"
from proizvod p , proizvodjac pr, pravno_lice lice 
where  exists(select 'a' from proizvod p2
                        where pr.proizvodjac_id=p2.proizvodjac_id and 
                        p2.cijena>(select avg(p1.cijena)
                    from proizvod p1))
and p.proizvodjac_id=pr.proizvodjac_id and lice.pravno_lice_id=pr.proizvodjac_id);


--4. Rezultat:   1176
SELECT Sum(Length("Proizvod")*7 + Length("Proizvodjac")*7) FROM
(select p.naziv as "Proizvod" , lice.naziv as "Proizvodjac"
from proizvod p , proizvodjac pr, pravno_lice lice 
where  exists(select 'a' from proizvod p2
                        where pr.proizvodjac_id=p2.proizvodjac_id and 
                        p2.cijena>(select avg(p1.cijena)
                    from proizvod p1))
and p.proizvodjac_id=pr.proizvodjac_id and lice.pravno_lice_id=pr.proizvodjac_id);

--5 Ispisati ime i prezime kupaca koji su istovremeno uposlenici i sumu potrošenog iznosa na
--fakture koje su platili za svakog od njih (grupisani po imenu PA prezimenu) čija je suma
--iznosa veća od prosjeka (zaokruženog na dvije decimale) suma iznosa faktura fizičkih lica
--(grupisanih po imenu PA prezimenu).

select f.ime|| ' ' || f.prezime as "Ime i prezime" , sum (fak.iznos) as "iznos"
from fizicko_lice f, kupac k, uposlenik u, faktura fak
where f.fizicko_lice_id=u.uposlenik_id and f.fizicko_lice_id=k.kupac_id and fak.kupac_id=k.kupac_id
having sum(fak.iznos)> (select round(avg(sum(fak1.iznos)),2)
                        from faktura fak1, fizicko_lice f1, kupac k1
                        where  f1.fizicko_lice_id=k1.kupac_id and fak1.kupac_id=k1.kupac_id
                        group by f1.ime, f1.prezime)
group by f.ime, f.prezime;


--provjera
--5. Rezultat: 6897 
SELECT Sum(Length("Ime i prezime")*3 + "iznos"*3) FROM
(select f.ime|| ' ' || f.prezime as "Ime i prezime" , sum (fak.iznos) as "iznos"
from fizicko_lice f, kupac k, uposlenik u, faktura fak
where f.fizicko_lice_id=u.uposlenik_id and f.fizicko_lice_id=k.kupac_id and fak.kupac_id=k.kupac_id
having sum(fak.iznos)> (select round(avg(sum(fak1.iznos)),2)
                        from faktura fak1, fizicko_lice f1, kupac k1
                        where  f1.fizicko_lice_id=k1.kupac_id and fak1.kupac_id=k1.kupac_id
                        group by f1.ime, f1.prezime)
group by f.ime, f.prezime); 


 
--5. Rezultat:  16093
SELECT Sum(Length("Ime i prezime")*7 + "iznos"*7) FROM
(select f.ime|| ' ' || f.prezime as "Ime i prezime" , sum (fak.iznos) as "iznos"
from fizicko_lice f, kupac k, uposlenik u, faktura fak
where f.fizicko_lice_id=u.uposlenik_id and f.fizicko_lice_id=k.kupac_id and fak.kupac_id=k.kupac_id
having sum(fak.iznos)> (select round(avg(sum(fak1.iznos)),2)
                        from faktura fak1, fizicko_lice f1, kupac k1
                        where  f1.fizicko_lice_id=k1.kupac_id and fak1.kupac_id=k1.kupac_id
                        group by f1.ime, f1.prezime)
group by f.ime, f.prezime); 



--6 Ispisati naziv kurirske službe čija je suma količine jednog proizvoda u njenim narudžbama
--gdje ima popusta jednaka maksimalnoj sumi količine jednog proizvoda u narudžbama svih
--kurirskih službi (suma grupisano po id kurirske službe) gdje ima popusta.

select li.naziv as "naziv"
from pravno_lice li, kurirska_sluzba sl,isporuka i, faktura f, narudzba_proizvoda n, popust pop
where li.pravno_lice_id=sl.kurirska_sluzba_id and  sl.kurirska_sluzba_id=i.kurirska_sluzba_id 
and i.isporuka_id=f.isporuka_id and n.faktura_id=f.faktura_id and n.popust_id=pop.popust_id and pop.postotak is not null
having sum(n.kolicina_jednog_proizvoda) in (select max(sum(n1.kolicina_jednog_proizvoda))
                                            from pravno_lice li1, kurirska_sluzba sl1,isporuka i1, faktura f1, narudzba_proizvoda n1, popust pop1
                                            where li1.pravno_lice_id=sl1.kurirska_sluzba_id and  sl1.kurirska_sluzba_id=i1.kurirska_sluzba_id 
                                            and i1.isporuka_id=f1.isporuka_id and n1.faktura_id=f1.faktura_id and n1.popust_id=pop1.popust_id
                                            and pop1.postotak is not null
                                            group by sl1.kurirska_sluzba_id)
 group by li.naziv;                           
 
 --6. Rezultat: 18
SELECT Sum(Length("naziv")*3) FROM
(select li.naziv as "naziv"
from pravno_lice li, kurirska_sluzba sl,isporuka i, faktura f, narudzba_proizvoda n, popust pop
where li.pravno_lice_id=sl.kurirska_sluzba_id and  sl.kurirska_sluzba_id=i.kurirska_sluzba_id 
and i.isporuka_id=f.isporuka_id and n.faktura_id=f.faktura_id and n.popust_id=pop.popust_id and pop.postotak is not null
having sum(n.kolicina_jednog_proizvoda) in (select max(sum(n1.kolicina_jednog_proizvoda))
                                            from pravno_lice li1, kurirska_sluzba sl1,isporuka i1, faktura f1, narudzba_proizvoda n1, popust pop1
                                            where li1.pravno_lice_id=sl1.kurirska_sluzba_id and  sl1.kurirska_sluzba_id=i1.kurirska_sluzba_id 
                                            and i1.isporuka_id=f1.isporuka_id and n1.faktura_id=f1.faktura_id and n1.popust_id=pop1.popust_id
                                            and pop1.postotak is not null
                                            group by sl1.kurirska_sluzba_id)
 group by li.naziv );            


--6. Rezultat: 42
SELECT Sum(Length("naziv")*7) FROM
(select li.naziv as "naziv"
from pravno_lice li, kurirska_sluzba sl,isporuka i, faktura f, narudzba_proizvoda n, popust pop
where li.pravno_lice_id=sl.kurirska_sluzba_id and  sl.kurirska_sluzba_id=i.kurirska_sluzba_id 
and i.isporuka_id=f.isporuka_id and n.faktura_id=f.faktura_id and n.popust_id=pop.popust_id and pop.postotak is not null
having sum(n.kolicina_jednog_proizvoda) in (select max(sum(n1.kolicina_jednog_proizvoda))
                                            from pravno_lice li1, kurirska_sluzba sl1,isporuka i1, faktura f1, narudzba_proizvoda n1, popust pop1
                                            where li1.pravno_lice_id=sl1.kurirska_sluzba_id and  sl1.kurirska_sluzba_id=i1.kurirska_sluzba_id 
                                            and i1.isporuka_id=f1.isporuka_id and n1.faktura_id=f1.faktura_id and n1.popust_id=pop1.popust_id
                                            and pop1.postotak is not null
                                            group by sl1.kurirska_sluzba_id)
 group by li.naziv);

 
 --7 Ispisati ime i prezime svakog kupca (grupisano po imenu i prezimenu zajedno) i uštedu
--ostvarenu na sve popuste u njegovim fakturama (izračunatu preko količine jednog
--proizvoda). Kao vrijednost treće kolone prikazati vaš broj indeksa. Kolone nazvati
--“Kupac”, “Usteda” i “Indeks”.

select f.ime ||' ' || f.prezime as "Kupac", sum(usteda.suma) as "Usteda", 19290 as "Indeks"
from fizicko_lice f, kupac k, faktura fak , (select n.kolicina_jednog_proizvoda* p.cijena*  pop.postotak/100 as suma , n.faktura_id as id
                                            from narudzba_proizvoda n, proizvod p, popust pop
                                            where n.popust_id=pop.popust_id and n.proizvod_id=p.proizvod_id) usteda
 where f.fizicko_lice_id=k.kupac_id and k.kupac_id=fak.kupac_id  and fak.faktura_id=usteda.id
group by f.ime || ' ' || f.prezime;



--provjera Rezultat 17709
SELECT Sum(Length("Kupac")*3 + Round("Usteda")*3) FROM
(select f.ime ||' ' || f.prezime as "Kupac", sum(usteda.suma) as "Usteda", 19290 as "Indeks"
from fizicko_lice f, kupac k, faktura fak , (select n.kolicina_jednog_proizvoda* p.cijena*  pop.postotak/100 as suma , n.faktura_id as id
                                            from narudzba_proizvoda n, proizvod p, popust pop
                                            where n.popust_id=pop.popust_id and n.proizvod_id=p.proizvod_id) usteda
 where f.fizicko_lice_id=k.kupac_id and k.kupac_id=fak.kupac_id  and fak.faktura_id=usteda.id
group by f.ime || ' ' || f.prezime);
 
 


--7. Rezultat 41321
SELECT Sum(Length("Kupac")*7 + Round("Usteda")*7) FROM
(select f.ime ||' ' || f.prezime as "Kupac", sum(usteda.suma) as "Usteda", 19290 as "Indeks"
from fizicko_lice f, kupac k, faktura fak , (select n.kolicina_jednog_proizvoda* p.cijena*  pop.postotak/100 as suma , n.faktura_id as id
                                            from narudzba_proizvoda n, proizvod p, popust pop
                                            where n.popust_id=pop.popust_id and n.proizvod_id=p.proizvod_id) usteda
 where f.fizicko_lice_id=k.kupac_id and k.kupac_id=fak.kupac_id  and fak.faktura_id=usteda.id
group by f.ime || ' ' || f.prezime);


--8 Ispisati sve isporuke bez ponavljanja isporuke čije fakture imaju popust i broj mjeseci garancije.

select distinct i.isporuka_id as idisporuke, i.kurirska_sluzba_id as idkurirske
from isporuka i, faktura f, narudzba_proizvoda n, proizvod p, popust pop
where i.isporuka_id=f.isporuka_id and f.faktura_id=n.faktura_id and pop.popust_id =n.popust_id and p.proizvod_id=n.proizvod_id
and p.broj_mjeseci_garancije>0 and pop.postotak is not null;

--8. Rezultat: 243
 SELECT Sum(idisporuke*3 + idkurirske*3) FROM
(select distinct i.isporuka_id as idisporuke, i.kurirska_sluzba_id as idkurirske
from isporuka i, faktura f, narudzba_proizvoda n, proizvod p, popust pop
where i.isporuka_id=f.isporuka_id and f.faktura_id=n.faktura_id and pop.popust_id =n.popust_id and p.proizvod_id=n.proizvod_id
and p.broj_mjeseci_garancije>0 and pop.postotak is not null);


--8. Rezultat: 567
 SELECT Sum(idisporuke*7 + idkurirske*7) FROM
(select distinct i.isporuka_id as idisporuke, i.kurirska_sluzba_id as idkurirske
from isporuka i, faktura f, narudzba_proizvoda n, proizvod p, popust pop
where i.isporuka_id=f.isporuka_id and f.faktura_id=n.faktura_id and pop.popust_id =n.popust_id and p.proizvod_id=n.proizvod_id
and p.broj_mjeseci_garancije>0 and pop.postotak is not null);
 
--9  Ispisati naziv i cijenu proizvoda čija je cijena veća od prosjeka (zaokruženog na dvije
--decimale) maksimalnih cijena proizvoda iz svake kategorije.

select p.naziv as naziv , p.cijena as cijena
from proizvod p
where p.cijena > (select round(avg(max(p1.cijena)),2)
                    from proizvod p1
                    group by p1.kategorija_id);
                    

--provjera  --9. Rezultat: 9210 
 SELECT Sum(Length(naziv)*3 + cijena*3) FROM
(
select p.naziv as naziv , p.cijena as cijena
from proizvod p
where p.cijena > (select round(avg(max(p1.cijena)),2)
                    from proizvod p1
                    group by p1.kategorija_id));



 

--9. Rezultat: 21490
SELECT Sum(Length(naziv)*7 + cijena*7) FROM
(select p.naziv as naziv , p.cijena as cijena
from proizvod p
where p.cijena > (select round(avg(max(p1.cijena)),2)
                    from proizvod p1
                    group by p1.kategorija_id));

--10 Ispisati naziv i cijenu svih proizvoda čija je cijena manja od svih prosječnih cijena svake
--kategorije koja nije podkategorija kategorije tog proizvoda

select p.naziv as naziv, p.cijena as cijena
from proizvod p
where p.cijena< all (select avg(p1.cijena)
                    from proizvod p1, kategorija k
                    where  p.kategorija_id!=k.nadkategorija_id 
                    and  p1.kategorija_id=k.kategorija_id
                    group by p1.kategorija_id);           
  
--provjera --10. Rezultat: 2448
SELECT Sum(Length(naziv)*3 + Round(cijena)*3) FROM
(select p.naziv as naziv, p.cijena as cijena
from proizvod p
where p.cijena< all (select avg(p1.cijena)
                    from proizvod p1, kategorija k
                    where  p.kategorija_id!=k.nadkategorija_id 
                    and  p1.kategorija_id=k.kategorija_id
                    group by p1.kategorija_id));
                    


--10. Rezultat: 5712 
SELECT Sum(Length(naziv)*7 + Round(cijena)*7) FROM
(select p.naziv as naziv, p.cijena as cijena
from proizvod p
where p.cijena< all (select avg(p1.cijena)
                    from proizvod p1, kategorija k
                    where  p.kategorija_id!=k.nadkategorija_id 
                    and  p1.kategorija_id=k.kategorija_id
                    group by p1.kategorija_id));
 

--Zadatak 2

create table TabelaA (
id number primary key,
naziv varchar2(30),
datum date ,
cijeliBroj number,
realniBroj number ,
constraint  chkCB check(cijeliBroj < 5 or cijeliBroj >= 15),
constraint  chkRB check (realniBroj > 5)
);

create table TabelaB(
id number primary key,
naziv varchar2(30) ,
datum date ,
cijeliBroj number unique,
realniBroj number,
FKTabelaA number not null,
constraint FKTabA foreign key (FKTabelaA) references TabelaA(id));


Create table TabelaC(
id number,
naziv varchar2(30),
datum date,
cijeliBroj number,
realniBroj number,
FKTabelaB number,
constraint FkCnst foreign key (FKTabelaB) references TabelaB(id));

 
insert into TabelaA values (1,'tekst',null,null,6.2);
insert into TabelaA values (2,null,null,3,5.26);
insert into TabelaA values (3,'tekst',null,1,null);
insert into TabelaA values (4,null,null,null,null);
insert into TabelaA values (5,'tekst',null,16,6.78);

insert into TabelaB values (1,null,null,1,null,1);
insert into TabelaB values (2,null,null,3,null,1);
insert into TabelaB values (3,null,null,6,null,2);
insert into TabelaB values (4,null,null,11,null,2);
insert into TabelaB values (5,null,null,22,null,3);

insert into TabelaC values (1,'yes',null,33,null,4);
insert into TabelaC values (2,'no',null,33,null,2);
insert into TabelaC values (3,'no',null,55,null,1);             


 INSERT INTO TabelaA (id, naziv, datum, cijeliBroj, realniBroj) VALUES (6, 'tekst', null, null,6.20);
--1 - izvrsava se
 INSERT INTO TabelaB (id, naziv, datum, cijeliBroj, realniBroj, FkTabelaA) VALUES (6, null,null, 1, null, 1);
--2 - ne moze se izvrsiti zbog unique kolone cijeliBroj
 INSERT INTO TabelaB (id, naziv, datum, cijeliBroj, realniBroj, FkTabelaA) VALUES (7, null,null, 123, null, 6);
--3 - izvrsava se
 INSERT INTO TabelaC (id, naziv, datum, cijeliBroj, realniBroj, FkTabelaB) VALUES (4, 'NO',null, 55, null, null);
--4 - izvrsava se
 UPDATE TabelaA SET naziv = 'tekst' WHERE naziv IS NULL AND cijeliBroj IS NOT NULL;
--5 - izvrsava se
 DROP TABLE TabelaB;
--7 - ne moze se izvrsiti jer je foreign key za tabeluC
 DELETE FROM TabelaA WHERE realniBroj IS NULL;
--8 - ne moze se izvrsiti jer je foreign key za tabeluB
 DELETE FROM TabelaA WHERE id = 5;
--9 - izvrsava se
 UPDATE TabelaB SET fktabelaA = 4 WHERE fktabelaA = 2;
--10 -izvrsava se
 ALTER TABLE TabelaA ADD CONSTRAINT cst CHECK (naziv LIKE 'tekst');
--11 - izvrsava se


SELECT SUM(id) FROM TabelaA; --Rezultat: 16   
SELECT SUM(id) FROM TabelaB; --Rezultat: 22
SELECT SUM(id) FROM TabelaC; --Rezultat: 10


--zadatak 3
drop table tabelaC;
drop table tabelaB;
drop table tabelaA;


create table TabelaA (
id number primary key,
naziv varchar2(30),
datum date ,
cijeliBroj number,
realniBroj number ,
constraint  chkCB check(cijeliBroj < 5 or cijeliBroj >= 15),
constraint  chkRB check (realniBroj > 5)
);

create table TabelaB(
id number primary key,
naziv varchar2(30) ,
datum date ,
cijeliBroj number unique,
realniBroj number,
FKTabelaA number not null,
constraint FKTabA foreign key (FKTabelaA) references TabelaA(id));


Create table TabelaC(
id number,
naziv varchar2(30),
datum date,
cijeliBroj number, 
realniBroj number,
FKTabelaB number,
constraint FkCnst foreign key (FKTabelaB) references TabelaB(id));

insert into TabelaA values (1,'tekst',null,null,6.2);
insert into TabelaA values (2,null,null,3,5.26);
insert into TabelaA values (3,'tekst',null,1,null);
insert into TabelaA values (4,null,null,null,null);
insert into TabelaA values (5,'tekst',null,16,6.78);

insert into TabelaB values (1,null,null,1,null,1);
insert into TabelaB values (2,null,null,3,null,1);
insert into TabelaB values (3,null,null,6,null,2);
insert into TabelaB values (4,null,null,11,null,2);
insert into TabelaB values (5,null,null,22,null,3);

insert into TabelaC values (1,'yes',null,33,null,4);
insert into TabelaC values (2,'no',null,33,null,2);
insert into TabelaC values (3,'no',null,55,null,1); 


create sequence brojacB
start with 6;


create sequence seq
start with 1
minvalue 1
maxvalue 10
cycle
cache 2;

--t1
create or replace trigger  t1 
after update or insert on tabelab
for each row
declare 
v_id int;
v_cb number;
begin
v_id := :new.fktabelaa;
v_cb := :new.cijelibroj;
if v_cb < 50 then 
    update tabelaa
    set realnibroj=realnibroj* 1.25
    where id=v_id;
else 
    update tabelaa
    set realnibroj=realnibroj* 0.75
    where id=v_id;
end if;
end;
/

--t2
create or replace trigger t2
before update or insert on TabelaC
for each row
declare
  fk number;
  novi_cb number;
 
begin
  select max(cijeliBroj)*2 into novi_cb from TabelaB;

if inserting then
      select fktabelaa into fk from tabelab where id=:new.fktabelab;
     
     else
     select fktabelaa into fk from tabelab where id=:old.fktabelab;
    end if;
insert into tabelab(id, datum, cijeliBroj, fktabelaa) values (brojacb.nextval, sysdate, novi_cb, fk);
end;
/


create table TabelaABekap(
id integer primary key,
naziv varchar2(50),
datum date,
cijeliBroj number,
realniBroj number,
cijeliBrojB integer,
sekvenca integer);

--t3
create or replace trigger t3
after insert on TabelaB
for each row
declare 
    red_flag boolean := false;
begin
     for  i in (select  id from TabelaABekap where  id = :new.FKTabelaA) loop
        red_flag := true;
        exit;
    end loop;

   if red_flag then
        update TabelaABekap
        set cijeliBrojB = cijeliBrojB + :new.cijelibroj
        where id = :new.FKTabelaA;
    else
        insert into  TabelaABekap(id, naziv, datum, cijelibroj, realnibroj, cijelibrojB, sekvenca)
        select id, naziv, datum, cijelibroj, realnibroj, :new.cijelibroj, seq.nextval
        from TabelaA
   where id = :new.FKTabelaA;
    end if;
end;
/





    

INSERT INTO TabelaB (id, naziv, datum, cijeliBroj, realniBroj, FkTabelaA) VALUES (brojacB.nextval, null,
null, 2, null, 1);
INSERT INTO TabelaB (id, naziv, datum, cijeliBroj, realniBroj, FkTabelaA) VALUES (brojacB.nextval, null,
null, 4, null, 2);
INSERT INTO TabelaB (id, naziv, datum, cijeliBroj, realniBroj, FkTabelaA) VALUES (brojacB.nextval, null,
null, 8, null, 1);
INSERT INTO TabelaC (id, naziv, datum, cijeliBroj, realniBroj, FkTabelaB) VALUES (4, 'NO', null, 5, null, 3);
INSERT INTO TabelaC (id, naziv, datum, cijeliBroj, realniBroj, FkTabelaB) VALUES (5, 'YES', null, 7, null,
3);
INSERT INTO TabelaC (id, naziv, datum, cijeliBroj, realniBroj, FkTabelaB) VALUES (6, 'NO', null, 9, null, 2);
UPDATE TabelaC SET cijeliBroj = 10 WHERE id = 2;
DELETE FROM TabelaB WHERE id NOT IN (SELECT FkTabelaB FROM TabelaC);
DELETE FROM TabelaA WHERE id IN (3, 4, 6);

SELECT SUM(id*3 + cijeliBrojB*3) FROM TabelaABekap; --Rezultat: 2031
SELECT SUM(id*3 + cijeliBroj*3) FROM TabelaC; --Rezultat: 420
SELECT SUM(MOD(id,10)*3) FROM TabelaB; --Rezultat: 30
SELECT SUM(id + realniBroj)*10 FROM TabelaA; --Rezultat: 264

 SELECT SUM(id*7 + cijeliBrojB*7) FROM TabelaABekap; --4739
 SELECT SUM(id*7 + cijeliBroj*7) FROM TabelaC; --980
 SELECT SUM(MOD(id,10)*7) FROM TabelaB; --70
 SELECT SUM(id*5 + realniBroj)*10 FROM TabelaA; --584






                    
