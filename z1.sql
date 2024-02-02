ALTER SESSION SET CURRENT_SCHEMA = erd;

--KONTINENT, DRZAVA, GRAD, LOKACIJA, FIZICKO_LICE, PRAVNO_LICE, PROIZVODJAC,
--KURIRSKA_SLUZBA, UGOVOR_ZA_PRAVNO_LICE, KUPAC, UPOSLENIK, ODJEL,
--UGOVOR_ZA_UPOSLENIKA, SKLADISTE, KATEGORIJA, POPUST, PROIZVOD, KOLICINA,
--GARANCIJA, ISPORUKA, NARUDZBA_PROIZVODA i FAKTURA

select* 
from kontinent;

select* 
from drzava;

select* 
from grad;

select* 
from lokacija;

--1.
---Za svaki kontinent prikazati njegove države i gradove i broj lokacija zabilježenih u svakom gradu.
---Ako kontinent nema države ispisati ‘Nema države’ a ako nema grada ‘Nema grada’. Kolone
---nazvati Država, Grad i Kontinent, BrojLokacija.


select k.naziv as Kontinent, nvl(d.naziv, 'Nema drzave') as Drzava, nvl(g.naziv, 'Nema grada') as Grad,count(l.broj) as BrojLokacija
from kontinent k, drzava d, grad g, lokacija l
where k.kontinent_id = d.kontinent_id(+) and d.drzava_id = g.drzava_id(+) and g.grad_id = l.grad_id(+)
group by  k.naziv, d.naziv, g.naziv;


--provjera
SELECT Sum(Length(Drzava)*3+Length(Grad)*3+Length(Kontinent)*3)*MAX(BrojLokacija) FROM
(select k.naziv as Kontinent, nvl(d.naziv, 'Nema drzave') as Drzava, nvl(g.naziv, 'Nema grada') as Grad,count(l.broj) as BrojLokacija
from kontinent k, drzava d, grad g, lokacija l
where k.kontinent_id = d.kontinent_id(+) and d.drzava_id = g.drzava_id(+) and g.grad_id = l.grad_id(+)
group by  k.naziv, d.naziv, g.naziv);

--slanje
SELECT Sum(Length(Drzava)*7+Length(Grad)*7+Length(Kontinent)*7)*MAX(BrojLokacija) FROM
(select k.naziv as Kontinent, nvl(d.naziv, 'Nema drzave') as Drzava, nvl(g.naziv, 'Nema grada') as Grad,count(l.broj) as BrojLokacija
from kontinent k, drzava d, grad g, lokacija l
where k.kontinent_id = d.kontinent_id(+) and d.drzava_id = g.drzava_id(+) and g.grad_id = l.grad_id(+)
group by  k.naziv, d.naziv, g.naziv);

select* 
from pravno_lice;

select* 
from ugovor_za_pravno_lice;

--2
---Prikazati naziv za sva pravna lica koja nisu raskinula ugovor a godina potpisivanja ugovora je
---parna. Kolonu nazvati Naziv.
select p.naziv as Naziv 
from pravno_lice p, ugovor_za_pravno_lice u
where u.datum_raskidanja is null and mod(to_number(to_char(u.datum_potpisivanja, 'yyyy'), '9999'),2) = 0  and p.pravno_lice_id=u.pravno_lice_id ;


--provjera  dobar
SELECT SUM(LENGTH(naziv)*3) FROM
(select p.naziv as Naziv 
from pravno_lice p, ugovor_za_pravno_lice u
where u.datum_raskidanja is null and mod(to_number(to_char(u.datum_potpisivanja, 'yyyy'), '9999'),2) = 0  and p.pravno_lice_id=u.pravno_lice_id);


--slanje 
SELECT SUM(LENGTH(naziv)*7) FROM
(select p.naziv as Naziv 
from pravno_lice p, ugovor_za_pravno_lice u
where u.datum_raskidanja is null and mod(to_number(to_char(u.datum_potpisivanja, 'yyyy'), '9999'),2) = 0  and p.pravno_lice_id=u.pravno_lice_id);

--3
---Za svaku državu prikazati količinu svakog proizvoda koja se nalazi u skladištima te države ako je
---količina proizvoda veća od 50 i naziv države ne sadrži duplo slovo ‘s’. Kolone nazvati Drzava,
---Proizvod i Kolicina_proizvoda.

select d.naziv as Drzava, p.naziv as Proizvod, k.kolicina_proizvoda as Kolicina_proizvoda
from drzava d, grad g, lokacija l, proizvod p, skladiste s, kolicina k
where p.proizvod_id=k.proizvod_id and k.skladiste_id=s.skladiste_id 
and  s.lokacija_id=l.lokacija_id and l.grad_id=g.grad_id and d.drzava_id=g.drzava_id and k.kolicina_proizvoda>50 and d.naziv NOT LIKE '%s%s%';

--provjera dobar
SELECT SUM(Length(Drzava)*3 + Length(proizvod)*3 + kolicina_proizvoda*3) FROM 
(select d.naziv as Drzava, p.naziv as Proizvod, k.kolicina_proizvoda as Kolicina_proizvoda
from drzava d, grad g, lokacija l, proizvod p, skladiste s, kolicina k
where p.proizvod_id=k.proizvod_id and k.skladiste_id=s.skladiste_id 
and  s.lokacija_id=l.lokacija_id and l.grad_id=g.grad_id and d.drzava_id=g.drzava_id and k.kolicina_proizvoda>50 and d.naziv NOT LIKE '%s%s%');


--slanje 
SELECT SUM(Length(Drzava)*7 + Length(proizvod)*7 + kolicina_proizvoda*7) FROM 
(select d.naziv as Drzava, p.naziv as Proizvod, k.kolicina_proizvoda as Kolicina_proizvoda
from drzava d, grad g, lokacija l, proizvod p, skladiste s, kolicina k
where p.proizvod_id=k.proizvod_id and k.skladiste_id=s.skladiste_id 
and  s.lokacija_id=l.lokacija_id and l.grad_id=g.grad_id and d.drzava_id=g.drzava_id and k.kolicina_proizvoda>50 and d.naziv NOT LIKE '%s%s%');

--4
---Prikazati naziv proizvoda i broj mjeseci garancije za sve proizvode na koje postoji popust a broj
---mjeseci garancije im je djeljiv sa 3. Potrebno je prikazati rezultate bez ponavljanja.

select distinct p.naziv as Proizvod, p.broj_mjeseci_garancije as Broj_mjeseci_garancije
from proizvod p, narudzba_proizvoda n, popust pop
where p.proizvod_id=n.proizvod_id and n.popust_id=pop.popust_id and pop.postotak>0 and mod(p.broj_mjeseci_garancije,3) = 0;

--provjera
SELECT Sum(Length(naziv)*3) FROM
(select distinct p.naziv as Naziv, p.broj_mjeseci_garancije as Broj_mjeseci_garancije
from proizvod p, narudzba_proizvoda n, popust pop
where p.proizvod_id=n.proizvod_id and n.popust_id=pop.popust_id and pop.postotak>0 and mod(p.broj_mjeseci_garancije,3) = 0);

--slanje 
SELECT Sum(Length(naziv)*7) FROM
(select distinct p.naziv as Naziv, p.broj_mjeseci_garancije as Broj_mjeseci_garancije
from proizvod p, narudzba_proizvoda n, popust pop
where p.proizvod_id=n.proizvod_id and n.popust_id=pop.popust_id and pop.postotak>0 and mod(p.broj_mjeseci_garancije,3) = 0);


--5
--Prikazati kompletno ime i prezime u jednoj koloni i naziv odjela uposlenika koji je ujedno i kupac
--proizvoda a nije šef tog odjela. Kao vrijednost treće kolone nadodati vaš broj indeksa u svakom
--redu. Kolone nazvati “ime i prezime”, “Naziv odjela” i “Indeks”

select*
from uposlenik;

select*
from kupac;

select*
from odjel;

select*
from fizicko_lice;

select*
from  UGOVOR_ZA_UPOSLENIKA;

--odjel i uposlenik

select f.ime||' '||f.prezime "ime i prezime", o.naziv "Naziv odjela", 19290 "Indeks"
from fizicko_lice f, uposlenik u, odjel o, kupac k
where f.fizicko_lice_id=k.kupac_id and k.kupac_id!=o.sef_id and k.kupac_id=u.uposlenik_id and u.odjel_id=o.odjel_id;

--provjera
SELECT Sum(Length("ime i prezime")*3+Length("Naziv odjela")*3) 
FROM
(select f.ime||' '||f.prezime "ime i prezime", o.naziv "Naziv odjela", 19290 "Indeks"
from fizicko_lice f, uposlenik u, odjel o, kupac k
where f.fizicko_lice_id=k.kupac_id and k.kupac_id!=o.sef_id and k.kupac_id=u.uposlenik_id and u.odjel_id=o.odjel_id);

--slanje
SELECT Sum(Length("ime i prezime")*7+Length("Naziv odjela")*7) 
FROM
(select f.ime||' '||f.prezime "ime i prezime", o.naziv "Naziv odjela", 19290 "Indeks"
from fizicko_lice f, uposlenik u, odjel o, kupac k
where f.fizicko_lice_id=k.kupac_id and k.kupac_id!=o.sef_id and k.kupac_id=u.uposlenik_id and u.odjel_id=o.odjel_id);


--6
--Za sve narudžbe čiji je popust konvertovan u vrijednost cijene manji od 200 prikazati proizvod,
--cijenu proizvoda i postotak popusta narudžbe kao cijeli broj (od 0 do 100) i kao realni broj (od 0
--do 1). Narudžbe koje nemaju popust trebaju biti prikazane kao 0 posto popusta. Nazvati kolone
--Narudzba_id, Cijena, Postotak i PostotakRealni
select*
from narudzba_proizvoda;

select*
from popust;

select n.narudzba_id as NARUDZBA_ID, p.cijena as cijena , nvl(o.postotak, 0) as postotak, round(nvl(o.postotak,0),100) as postotakRealni
from narudzba_proizvoda n, proizvod p, popust o
where n.popust_id=o.popust_id(+) and n.proizvod_id=p.proizvod_id and p.cijena*nvl(o.postotak,0)/100<200;

--provjera
SELECT Sum(NARUDZBA_ID*3+cijena*3+postotak*3) FROM
(select n.narudzba_id as NARUDZBA_ID, p.cijena as cijena , nvl(o.postotak, 0) as postotak, round(nvl(o.postotak,0),100) as postotakRealni
from narudzba_proizvoda n, proizvod p, popust o
where n.popust_id=o.popust_id(+) and n.proizvod_id=p.proizvod_id and p.cijena*nvl(o.postotak,0)/100<200);

select* 
from kategorija;

--slanje\
SELECT Sum(NARUDZBA_ID*7+cijena*7+postotak*7) FROM
(select n.narudzba_id as NARUDZBA_ID, p.cijena as cijena , nvl(o.postotak, 0) as postotak, round(nvl(o.postotak,0),100) as postotakRealni
from narudzba_proizvoda n, proizvod p, popust o
where n.popust_id=o.popust_id(+) and n.proizvod_id=p.proizvod_id and p.cijena*nvl(o.postotak,0)/100<200);

--7
--Prikazati sve raspoložive kategorije proizvoda i njihove nadkategorije. Ako je id kategorije 1
--umjesto naziva kategorije treba pisati ‘Komp Oprema’ a ako nema kategorije treba pisati ‘Nema
--Kategorije’. Nazvati kolone “Kategorija” i “Nadkategorija”
SELECT k1.naziv "Kategorija", Decode(Nvl(k1.nadkategorija_id, 0), 0, 'Nema kategorije', 1 , 'Komp Oprema', k2.naziv) "Nadkategorija"
FROM kategorija k1, kategorija k2
WHERE k1.nadkategorija_id =  k2.kategorija_id(+);


--provjera
SELECT Sum(Length("Kategorija")*3+Length("Nadkategorija")*3) FROM
(SELECT k1.naziv "Kategorija", Decode(Nvl(k1.nadkategorija_id, 0), 0, 'Nema kategorije', 1 , 'Komp Oprema', k2.naziv) "Nadkategorija"
FROM kategorija k1, kategorija k2
WHERE k1.nadkategorija_id =  k2.kategorija_id(+));

select *
from UGOVOR_ZA_PRAVNO_LICE;


--slanje
SELECT Sum(Length("Kategorija")*7+Length("Nadkategorija")*7) FROM
(SELECT k1.naziv "Kategorija", Decode(Nvl(k1.nadkategorija_id, 0), 0, 'Nema kategorije', 1 , 'Komp Oprema', k2.naziv) "Nadkategorija"
FROM kategorija k1, kategorija k2
WHERE k1.nadkategorija_id =  k2.kategorija_id(+));


--8
--Za svaki ugovor čije čije prve dvije cifre čine broj koji nije veći od 50 ispisati datum raskidanja
--ugovora. Ako ne postoji datum raskidanja, potrebno je prikazati datum raskidanja kao datum
--potpisivanja ugovora plus dvije godine. Kolonu za datum raskidanja nazvati Raskid.

select  
case when substr(to_char(u.ugovor_id), 1, 2) <= '50' 
then nvl(u.datum_raskidanja, add_months(to_date(u.datum_potpisivanja, 'dd-mon-yy'), 24))
  end as Raskid
from UGOVOR_ZA_PRAVNO_LICE u
where substr(to_char(u.ugovor_id), 1, 2) <= '50';
  
--provjera 
SELECT Sum(To_Number(To_Char(RASKID,'YYYY'))) FROM
(select  
case when substr(to_char(u.ugovor_id), 1, 2) <= '50' 
then nvl(u.datum_raskidanja, add_months(to_date(u.datum_potpisivanja, 'dd-mon-yy'), 24))
  end as Raskid
from UGOVOR_ZA_PRAVNO_LICE u
where substr(to_char(u.ugovor_id), 1, 2) <= '50');

select*
from odjel;

--slanje
SELECT Sum(To_Number(To_Char(RASKID,'YYYY'))) * 2 FROM
(select  
case when substr(to_char(u.ugovor_id), 1, 2) <= '50' 
then nvl(u.datum_raskidanja, add_months(to_date(u.datum_potpisivanja, 'dd-mon-yy'), 24))
  end as Raskid
from UGOVOR_ZA_PRAVNO_LICE u
where substr(to_char(u.ugovor_id), 1, 2) <= '50');


--9
--Prikazati ime i prezime, naziv odjela i id odjela svih uposlenika pri čemu je naziv odjela sa
--MANAGER ako je u pitanju managment, HUMAN ako su u pitanju ljudski resursi i OTHER za
--sve ostalo, sortiranih prvo po imenu po rastućem poretku zatim po prezimenu po opadajućem
--poretku. Kolone nazvati ime prezime, odjel i odjel_id.

select f.ime as ime, f.prezime as prezime , decode(o.naziv, 'Management', 'Manager', 'Human resources', 'HUMAN', 'OTHER') as odjel, o.odjel_id as odjel_id
from odjel o, fizicko_lice f, uposlenik u
where f.fizicko_lice_id=u.uposlenik_id and u.odjel_id=o.odjel_id
order by f.ime asc, f.prezime desc;


--provjera
SELECT SUM(Length(ime)*3+Length(prezime)*3+Length(Odjel)*3) FROM 
(select f.ime as ime, f.prezime as prezime , decode(o.naziv, 'Management', 'Manager', 'Human resources', 'HUMAN', 'OTHER') as odjel, o.odjel_id as odjel_id
from odjel o, fizicko_lice f, uposlenik u
where f.fizicko_lice_id=u.uposlenik_id and u.odjel_id=o.odjel_id
order by f.ime asc, f.prezime desc)
WHERE ROWNUM<2;

--slanje

SELECT SUM(Length(ime)*7+Length(prezime)*7+Length(Odjel)*7) FROM 
(select f.ime as ime, f.prezime as prezime , decode(o.naziv, 'Management', 'Manager', 'Human resources', 'HUMAN', 'OTHER') as odjel, o.odjel_id as odjel_id
from odjel o, fizicko_lice f, uposlenik u
where f.fizicko_lice_id=u.uposlenik_id and u.odjel_id=o.odjel_id
order by f.ime asc, f.prezime desc)
WHERE ROWNUM<2;
--10
-- Prikazati svaku kategoriju proizvoda i za svaku kategoriju najskuplji i najjeftiniji proizvod te
--kategorije i zbir njihovih cijena sortirane po zbiru cijena najjeftinijeg i najskupljeg proizvoda u
--rastućem poretku. Zbir cijena nazvati ZCijena a proizvode Najjeftiniji i Najskuplji.



select k.naziv, p1.naziv as Najskuplji, p2.naziv as Najjeftiniji, t.maks + t.minim as ZCijena
from (select k.naziv as katNaziv,  max(cijena) maks, min(cijena) minim
from kategorija k, proizvod p
where p.kategorija_id=k.kategorija_id
group by k.naziv) t
inner join  kategorija k on k.naziv = t.katNaziv
inner join  proizvod  p1 on p1.cijena = t.maks
inner join  proizvod  p2 on p2.cijena = t.minim
order by ZCijena asc;


--provjera 
SELECT SUM(Length(Najjeftiniji)*3+ZCijena*3) FROM
(select k.naziv, p1.naziv as Najskuplji, p2.naziv as Najjeftiniji, t.maks + t.minim as ZCijena
from (select k.naziv as katNaziv,  max(cijena) maks, min(cijena) minim
from kategorija k, proizvod p
where p.kategorija_id=k.kategorija_id
group by k.naziv) t
inner join  kategorija k on k.naziv = t.katNaziv
inner join  proizvod  p1 on p1.cijena = t.maks
inner join  proizvod  p2 on p2.cijena = t.minim
order by ZCijena asc)
WHERE ROWNUM<4;



--slanje
SELECT SUM(Length(Najjeftiniji)*7+ZCijena*7) FROM
(select k.naziv, p1.naziv as Najskuplji, p2.naziv as Najjeftiniji, t.maks + t.minim as ZCijena
from (select k.naziv as katNaziv,  max(cijena) maks, min(cijena) minim
from kategorija k, proizvod p
where p.kategorija_id=k.kategorija_id
group by k.naziv) t
inner join  kategorija k on k.naziv = t.katNaziv
inner join  proizvod  p1 on p1.cijena = t.maks
inner join  proizvod  p2 on p2.cijena = t.minim
order by ZCijena asc
)
WHERE ROWNUM<4;
