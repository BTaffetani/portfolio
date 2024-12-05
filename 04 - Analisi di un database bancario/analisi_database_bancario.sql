/*
ANALISI DELLA CLIENTELA DI UN DATABASE BANCARIO
L'obiettivo della presente analisi è la costruzione di una tabella denormalizzata che riepiloghi i dati forniti da
una banca sulla sua clientela, allo scopo di prendere decisioni data-driven.
La prima parte è dedicata all'esplorazione dei dati forniti dalla banca. La seconda, la terza, la quarta e la quinta
sezione sono dedicate alle tabelle che raggruppano particolari tipi di indicatori per ogni cliente. La sesta e ultima
sezione è dedicata alla tabella riepilogativa oggetto della presente analisi.

ANALISI ESPLORATIVA DEI DATI
In prima analisi saranno esplorati i dati forniti dalla banca.

Il database si compone delle seguenti tabelle:
- la tabella "cliente" contiene informazioni anagrafiche sulla clientela;
- la tabella "conto" contiene informazioni sui conti posseduti dai clienti;
- la tabella "tranzazioni" contiene informazioni sulle transazioni dei clienti;
- la tabella "tipo_conto" è una tabella informativa sui tipi di conto messi a disposizione dalla banca;
- la tabella "tipo_transazione" è una tabella informativa sui tipi di transazione ammessi dalla banca.
*/

-- La tabella "cliente" memorizza l'identificativo del cliente (id_cliente),
-- il nome (nome, cognome) e la data di nascita (data_nascita).
select * from banca.cliente;

-- La tabella "conto" memorizza l'identificativo del conto (id_conto),
-- l'identificativo del proprietario del conto (id_cliente) e l'identificativo del tipo di conto (id_tipo_conto).
select * from banca.conto;

-- La tabella "transazioni" memorizza la data della transazione (data), l'identificativo del tipo di transazione
-- (id_tipo_transazione), l'importo transato (importo) e l'identificativo del conto (id_conto).
select * from banca.transazioni;

-- La tabella "tipo_conto" è una tabella informativa che associa a ogni identificativo del tipo di conto
-- (id_tipo_conto) la sua descrizione (desc_tipo_conto).
select * from banca.tipo_conto;

-- La tabella "tipo_transazione" è una tabella informativa che associa a ogni identificativo del tipo di transazione
-- (id_tipo_transazione) la sua descrizione (desc_tipo_trans) e il suo segno (segno).
select * from banca.tipo_transazione;

/*
INDICATORI DI BASE
La prima tabella ottenuta dai dati associa a ogni cliente la sua età.
Per la prima colonna si è mantenuto solo l'identificativo del cliente (id_cliente), mentre la seconda è calcolata a
partire dalla colonna della data di nascita.
*/

create table banca.indicatori_base (
	id_cliente int,
    eta int
);

insert into banca.indicatori_base
select id_cliente,
floor(datediff(current_date(),data_nascita)/365.25) as eta
from banca.cliente;

select * from banca.indicatori_base;

/*
INDICATORI SULLE TRANSAZIONI
La seconda tabella associa a ogni cliente il numero di transazioni e il totale degli importi transati sia in
entrata che in uscita.
Le colonne sono state calcolate unendo le tabelle "transazioni", "conto" e "tipo_transazioni".
*/

create table banca.indicatori_transazioni (
	id_cliente int,
    n_transazioni_entrata int,
    n_transazioni_uscita int,
    tot_importo_entrata float,
    tot_importo_uscita float
);

insert into banca.indicatori_transazioni
select id_cliente,
sum(case when segno="+" then 1 else 0 end) as n_transazioni_entrata,
sum(case when segno="-" then 1 else 0 end) as n_transazioni_uscita,
round(sum(case when segno="+" then abs(importo) else 0 end),2) as tot_importo_entrata,
round(sum(case when segno="-" then abs(importo) else 0 end),2) as tot_importo_uscita
from banca.transazioni transazioni
left join banca.conto conto
on transazioni.id_conto=conto.id_conto
left join banca.tipo_transazione tipo_transazione
on transazioni.id_tipo_trans=tipo_transazione.id_tipo_transazione
group by id_cliente;

select * from banca.indicatori_transazioni;

/*
INDICATORI SUI CONTI
La terza tabella associa a ogni cliente il numero totale di conti posseduti e il numero di conti di ciascun tipo.
Ricordiamo che la banca offre quattro tipologie di conti: Base, Business, Privati e Famiglie.
Le colonne sono state calcolate dalle tabelle "conto" e "tipo_conto".
*/

create table banca.indicatori_conti (
	id_cliente int,
    n_conti int,
    n_conti_base int,
    n_conti_business int,
	n_conti_privati int,
    n_conti_famiglie int
);

insert into banca.indicatori_conti
select id_cliente,
count(*) as n_conti,
sum(case when conto.id_tipo_conto=0 then 1 else 0 end) as n_conti_base,
sum(case when conto.id_tipo_conto=1 then 1 else 0 end) as n_conti_business,
sum(case when conto.id_tipo_conto=2 then 1 else 0 end) as n_conti_privati,
sum(case when conto.id_tipo_conto=3 then 1 else 0 end) as n_conti_famiglie
from banca.conto conto
left join banca.tipo_conto tipo_conto
on conto.id_tipo_conto=tipo_conto.id_tipo_conto
group by id_cliente;

select * from banca.indicatori_conti;

/*
INDICATORI SULLE TRANSAZIONI PER TIPO DI CONTO
La quarta e ultima tabella di indicatori associa a ogni cliente il numero di transazioni e gli importi transati
per tipo di conto posseduto, sia in entrata che in uscita.
I dati per calcolare le colonne sono stati ottenuti dalle tabelle "conto", "tipo_conto" e "tipo_transazione".
*/

create table banca.indicatori_transazioni_conti (
	id_cliente int,
    n_trans_entrata_base int,
    n_trans_entrata_business int,
    n_trans_entrata_privati int,
    n_trans_entrata_famiglie int,
    n_trans_uscita_base int,
    n_trans_uscita_business int,
    n_trans_uscita_privati int,
    n_trans_uscita_famiglie int,
    importo_entrata_base float,
    importo_entrata_business float,
    importo_entrata_privati float,
    importo_entrata_famiglie float,
    importo_uscita_base float,
    importo_uscita_business float,
    importo_uscita_privati float,
    importo_uscita_famiglie float
);

insert into banca.indicatori_transazioni_conti
select id_cliente,
sum(case when segno="+" and conto.id_tipo_conto=0 then 1 else 0 end) as n_trans_entrata_base,
sum(case when segno="+" and conto.id_tipo_conto=1 then 1 else 0 end) as n_trans_entrata_business,
sum(case when segno="+" and conto.id_tipo_conto=2 then 1 else 0 end) as n_trans_entrata_privati,
sum(case when segno="+" and conto.id_tipo_conto=3 then 1 else 0 end) as n_trans_entrata_famiglie,
sum(case when segno="-" and conto.id_tipo_conto=0 then 1 else 0 end) as n_trans_uscita_base,
sum(case when segno="-" and conto.id_tipo_conto=1 then 1 else 0 end) as n_trans_uscita_business,
sum(case when segno="-" and conto.id_tipo_conto=2 then 1 else 0 end) as n_trans_uscita_privati,
sum(case when segno="-" and conto.id_tipo_conto=3 then 1 else 0 end) as n_trans_uscita_famiglie,
sum(case when segno="+" and conto.id_tipo_conto=0 then abs(round(importo,2)) else 0 end) as importo_entrata_base,
sum(case when segno="+" and conto.id_tipo_conto=1 then abs(round(importo,2)) else 0 end) as importo_entrata_business,
sum(case when segno="+" and conto.id_tipo_conto=2 then abs(round(importo,2)) else 0 end) as importo_entrata_privati,
sum(case when segno="+" and conto.id_tipo_conto=3 then abs(round(importo,2)) else 0 end) as importo_entrata_famiglie,
sum(case when segno="-" and conto.id_tipo_conto=0 then abs(round(importo,2)) else 0 end) as importo_uscita_base,
sum(case when segno="-" and conto.id_tipo_conto=1 then abs(round(importo,2)) else 0 end) as importo_uscita_business,
sum(case when segno="-" and conto.id_tipo_conto=2 then abs(round(importo,2)) else 0 end) as importo_uscita_privati,
sum(case when segno="-" and conto.id_tipo_conto=3 then abs(round(importo,2)) else 0 end) as importo_uscita_famiglie
from banca.transazioni transazioni
left join banca.conto conto
on transazioni.id_conto=conto.id_conto
left join banca.tipo_conto tipo_conto
on conto.id_tipo_conto=tipo_conto.id_tipo_conto
left join banca.tipo_transazione tipo_transazione
on transazioni.id_tipo_trans=tipo_transazione.id_tipo_transazione
group by id_cliente;

select * from banca.indicatori_transazioni_conti;

/*
TABELLA RIEPILOGATIVA
Le tabelle appena costruite sono state unite in una tabella riepilogativa che riassume i dati per ogni cliente.
Nel corso della costruzione della tabella sono emersi dati mancanti per diversi clienti. Ipotizzando che l'assenza di
valori sia dovuta a richieste di servizi che non erano compresi nell'obiettivo della presente analisi, i valori
mancanti sono stati sostituiti da 0.
*/

create table banca.riepilogo(
	id_cliente int,
    eta int,
    n_transazioni_entrata int,
    n_transazioni_uscita int,
    tot_importo_entrata float,
    tot_importo_uscita float,
    n_conti int,
    n_conti_base int,
    n_conti_business int,
    n_conti_privati int,
    n_conti_famiglie int,
    n_trans_entrata_base int,
    n_trans_entrata_business int,
    n_trans_entrata_privati int,
    n_trans_entrata_famiglie int,
    n_trans_uscita_base int,
    n_trans_uscita_business int,
    n_trans_uscita_privati int,
    n_trans_uscita_famiglie int,
    importo_entrata_base float,
    importo_entrata_business float,
    importo_entrata_privati float,
    importo_entrata_famiglie float,
    importo_uscita_base float,
    importo_uscita_business float,
    importo_uscita_privati float,
    importo_uscita_famiglie float
);

insert into banca.riepilogo
select base.id_cliente as id_cliente,
eta,
case when n_transazioni_entrata is null then 0 else n_transazioni_entrata end as n_transazioni_entrata,
case when n_transazioni_uscita is null then 0 else n_transazioni_uscita end as n_transazioni_uscita,
case when tot_importo_entrata is null then 0 else tot_importo_entrata end as tot_importo_entrata,
case when tot_importo_uscita is null then 0 else tot_importo_uscita end as tot_importo_uscita,
case when n_conti is null then 0 else n_conti end as n_conti,
case when n_conti_base is null then 0 else n_conti_base end as n_conti_base,
case when n_conti_business is null then 0 else n_conti_business end as n_conti_business,
case when n_conti_privati is null then 0 else n_conti_privati end as n_conti_privati,
case when n_conti_famiglie is null then 0 else n_conti_famiglie end as n_conti_famiglie,
case when n_trans_entrata_base is null then 0 else n_trans_entrata_base end as n_trans_entrata_base,
case when n_trans_entrata_business is null then 0 else n_trans_entrata_business end as n_trans_entrata_business,
case when n_trans_entrata_privati is null then 0 else n_trans_entrata_privati end as n_trans_entrata_privati,
case when n_trans_entrata_famiglie is null then 0 else n_trans_entrata_famiglie end as n_trans_entrata_famiglie,
case when n_trans_uscita_base is null then 0 else n_trans_uscita_base end as n_trans_uscita_base,
case when n_trans_uscita_business is null then 0 else n_trans_uscita_business end as n_trans_uscita_business,
case when n_trans_uscita_privati is null then 0 else n_trans_uscita_privati end as n_trans_uscita_privati,
case when n_trans_uscita_famiglie is null then 0 else n_trans_uscita_famiglie end as n_trans_uscita_famiglie,
case when importo_entrata_base is null then 0 else importo_entrata_base end as importo_entrata_base,
case when importo_entrata_business is null then 0 else importo_entrata_business end as importo_entrata_business,
case when importo_entrata_privati is null then 0 else importo_entrata_privati end as importo_entrata_privati,
case when importo_entrata_famiglie is null then 0 else importo_entrata_famiglie end as importo_entrata_famiglie,
case when importo_uscita_base is null then 0 else importo_uscita_base end as importo_uscita_base,
case when importo_uscita_business is null then 0 else importo_uscita_business end as importo_uscita_business,
case when importo_uscita_privati is null then 0 else importo_uscita_privati end as importo_uscita_privati,
case when importo_uscita_famiglie is null then 0 else importo_uscita_famiglie end as importo_uscita_famiglie
from banca.indicatori_base base
left join banca.indicatori_transazioni transazioni
on base.id_cliente=transazioni.id_cliente
left join banca.indicatori_conti conti
on base.id_cliente=conti.id_cliente
left join banca.indicatori_transazioni_conti transazioni_conti
on base.id_cliente=transazioni_conti.id_cliente;

select * from banca.riepilogo