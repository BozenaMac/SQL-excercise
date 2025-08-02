--Celem analizy jest sprawdzenie wpływu zjawisk El Nino i La Nina oraz działalności ludzkej na pożary oraz wylesiania w Amazonii w latach 1999-2019.


--1. wystąpienia pożarów w poszczególnych latach
SELECT year as rok, SUM(firespots) AS pozary_lacznie
FROM inpe_brazilian_amazon_fires ibaf 
GROUP BY year
ORDER BY year;

-- Wynik pokazuje wzrost liczby pożarów w latach 2002-2005 oraz 2015-2019


--2. średnie wylesienie w poszczególnych stanach
    SELECT 
    "Ano/Estados" AS rok, 
    AVG("AC") AS avg_AC, 
    AVG("AM") AS avg_AM, 
    AVG("PA") AS avg_PA,
    AVG("AP") AS avg_AP,
    AVG("MA") AS avg_MA,
    AVG("MT") AS avg_MT,
    AVG("RO") AS avg_RO,
    AVG("RR") AS avg_RR,
    AVG("TO") AS avg_TO
FROM def_area da 
GROUP BY "Ano/Estados";


-- Stany MT i PA wykazują największe średnie wylesienie


--3. korealcja pomiędzy El Nino/La Nina a liczbą pożarów
SELECT 
    pozary.year as rok, 
    el_nino.phenomenon as zjawisko, 
    SUM(pozary.firespots) AS pozary_lacznie
FROM inpe_brazilian_amazon_fires AS pozary
JOIN el_nino_la_nina AS el_nino
    ON pozary.year BETWEEN el_nino."start year" AND el_nino."end year"
GROUP BY pozary.year, el_nino.phenomenon
ORDER BY pozary.year;

SELECT 
    el_nino.phenomenon AS zjawisko, 
    SUM(pozary.firespots) AS lacznie_dla_zjawiska
FROM inpe_brazilian_amazon_fires AS pozary
JOIN el_nino_la_nina AS el_nino
    ON pozary.year BETWEEN el_nino."start year" AND el_nino."end year"
GROUP BY el_nino.phenomenon
ORDER BY el_nino.phenomenon;


--Liczba pożarów jest większa w latach El Nino w porównaniu do La Nina


--4. lata intensywne dla zjawisk
SELECT 
    el_nino."start year" AS poczatek, 
    el_nino."end year" AS koniec, 
    CASE 
        WHEN el_nino.severity = 'Very Strong' THEN 'Bardzo Silne'
        WHEN el_nino.severity = 'Strong' THEN 'Silne'
        ELSE el_nino.severity
    END AS intensywnosc, 
    SUM(pozary.firespots) AS pozary_lacznie
FROM el_nino_la_nina AS el_nino
JOIN inpe_brazilian_amazon_fires AS pozary
    ON pozary.year BETWEEN el_nino."start year" AND el_nino."end year"
WHERE el_nino.severity IN ('Very Strong', 'Strong')
GROUP BY el_nino."start year", el_nino."end year", el_nino.severity;

--intensywne zjawiska El Nino/La Nina wykazują większą liczbę pożarów, ale większa intensywność (bardzo silne) nie oznacza większej liczby pożarów w odniesieniu do "Silne"
-- porównując do zapytania pierwszego zjawiska nie są głównymi czynnikami wywołującymi pożary (cześciowe odwzorowanie na wykresach)

--5. rok z najwyższym wylesieniem w Amazonii
select "Ano/Estados" as rok, "AMZ LEGAL" as deforestacja_lacznie
from def_area da 
order by "AMZ LEGAL" desc 
limit 1;

-- nie występowały w tym roku intensywne zjawiska, przyczyna leży gdzie indziej


--6. 5 stanów z największa liczbą pożarów
SELECT state as stan, AVG(firespots) AS avg_pozary
FROM inpe_brazilian_amazon_fires ibaf 
GROUP BY state
ORDER BY avg_pozary DESC
LIMIT 5;



--7. korealcja średniego wylesienia AMZ w latach występowania El Nino/ La Nina
SELECT 
    el_nino.phenomenon as zjawisko, 
    AVG(deforestation."AMZ LEGAL") AS avg_deforestacja
FROM def_area AS deforestation
JOIN el_nino_la_nina AS el_nino
    ON deforestation."Ano/Estados" BETWEEN el_nino."start year" AND el_nino."end year"
GROUP BY el_nino.phenomenon
ORDER BY el_nino.phenomenon;

--większa średnie wylesie dla zjawiska El Nino


--8. miesięczny trend pożarów w 2003, 2015, 2019
SELECT month as miesiac, SUM(firespots) AS pozary_lacznie
FROM inpe_brazilian_amazon_fires ibaf 
WHERE year = 2019
GROUP BY month
ORDER BY month;

SELECT month as miesiac, SUM(firespots) AS pozary_lacznie
FROM inpe_brazilian_amazon_fires ibaf 
WHERE year = 2015
GROUP BY month
ORDER BY month;

SELECT month as miesiac, SUM(firespots) AS pozary_lacznie
FROM inpe_brazilian_amazon_fires ibaf 
WHERE year = 2003
GROUP BY month
ORDER BY month;

--analiza wybranych pokazuje trend pożarów  w miesiącach letnich


--9. procentowy udział stanów w całkowitym wylesieniu w latach 2004-2019
select 
	"Ano/Estados" as rok, 
	"AC" * 100 / "AMZ LEGAL" as procent_AC,
	"AM" * 100 / "AMZ LEGAL" as procent_AM,
	"AP" * 100 / "AMZ LEGAL" as procent_AP,
	"MA" * 100 / "AMZ LEGAL" as procent_MA,
	"MT" * 100 / "AMZ LEGAL" as procent_MT,
	"PA" * 100 / "AMZ LEGAL" as procent_PA,
	"RO" * 100 / "AMZ LEGAL" as procent_RO,
	"RR" * 100 / "AMZ LEGAL" as procent_RR,
	"TO" * 100 / "AMZ LEGAL" as procent_TO
from def_area da
order by rok;


-- stany MT i PA mają największy udział w wylesieniu


--10. korelacja liczby pożarów z wylesieniem
SELECT 
    deforestacja."Ano/Estados" AS rok, 
    SUM(pozary.firespots) AS pozary_lacznie, 
    deforestacja."AMZ LEGAL" AS obszar_deforestacji
FROM def_area AS deforestacja
JOIN inpe_brazilian_amazon_fires AS pozary
    ON deforestacja."Ano/Estados" = pozary.year
GROUP BY deforestacja."Ano/Estados", deforestacja."AMZ LEGAL"
ORDER BY deforestacja."Ano/Estados";


--rok 2004 był rokiem z najwyższą liczbą pożarów i powierzchni wylesienia




