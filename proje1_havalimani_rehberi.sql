-- Proje 1: Havaliman? Rehberi
-- Veri: OurAirports airports.csv (86.368 havaliman?)
-- Araç: SQL Server 2022 Express


-- S1: Türkiye'de kaç havaliman? var?
SELECT COUNT(*) AS havalimani_sayisi
FROM airports
WHERE iso_country = 'TR';

-- S2: Türkiye'deki havalimanlar?n?n türlerine göre da??l?m?
SELECT type, COUNT(*) AS sayi
FROM airports 
WHERE iso_country = 'TR'
GROUP BY type
ORDER BY sayi DESC;

-- S3: Türkiye'nin en yüksek rak?ml? 10 havaliman?
SELECT TOP 10 name, municipality, type, elevation_ft
FROM airports
WHERE iso_country = 'TR'
	AND elevation_ft IS NOT NULL
ORDER BY elevation_ft DESC;

-- S4: En çok large_airport'a sahip 10 ülke 
SELECT TOP 10 iso_country, COUNT(*) AS buyuk_havalimani
FROM airports
WHERE type = 'large_airport'
GROUP BY iso_country
ORDER BY buyuk_havalimani DESC;

-- S5: Türkiye'de tarifeli seferi olan havalimanlar?
SELECT TOP 10 name, municipality,iata_code,type
FROM airports
WHERE iso_country = 'TR'
	AND scheduled_service = '1'
ORDER BY name;

-- S6: Türkiye'de türlere göre ortalama rakım (ft)
SELECT type,
       COUNT(*)                                  AS sayi,
       AVG(elevation_ft)                         AS ortalama_yanlis,
       ROUND(AVG(CAST(elevation_ft AS FLOAT)), 0) AS ortalama_dogru
FROM airports
WHERE iso_country = 'TR'
GROUP BY type
ORDER BY ortalama_dogru DESC;

-- S7: Esenboğa'nın bütün bilgileri
SELECT *
FROM airports
WHERE ident = 'LTAC';

-- S8: Tarifeli seferi olduğu halde IATA kodu olmayan havalimanları (veri kalitesi)
SELECT iso_country, name, ident, iata_code
FROM airports
WHERE scheduled_service = '1'
  AND NULLIF(iata_code, '') IS NULL;

  -- S9: Kıtalara göre havalimanı sayısı
SELECT continent, COUNT(*) AS sayi
FROM airports
GROUP BY continent
ORDER BY sayi DESC;

-- S10: Ankara'daki havalimanları ve pistler
SELECT name, type, ident
FROM airports
WHERE iso_country = 'TR'
  AND municipality LIKE '%Ankara%';


  -- S11: En uzun havalimanı adı (aktarımı bozan kayıt)
SELECT TOP 1 name, LEN(name) AS karakter
FROM airports
ORDER BY LEN(name) DESC;

-- S12: Türkiye'deki kapalı havalimanları
SELECT name, municipality
FROM airports
WHERE iso_country = 'TR' AND type = 'closed'
ORDER BY name;

-- S13: En az 5 havalimanı/pisti olan iller
SELECT iso_region, COUNT(*) AS sayi
FROM airports
WHERE iso_country = 'TR'
GROUP BY iso_region
HAVING COUNT(*) >= 5
ORDER BY sayi DESC;

-- S14: Türkiye'nin en kuzeydeki yolcu havalimanı
SELECT name, municipality, latitude_deg
FROM airports
WHERE iso_country = 'TR'
  AND type IN ('large_airport', 'medium_airport')
  AND latitude_deg = (SELECT MAX(latitude_deg)
                      FROM airports
                      WHERE iso_country = 'TR'
                        AND type IN ('large_airport', 'medium_airport'));

-- S15: Esenboğa'ya en yakın 10 yolcu havalimanı (km)
DECLARE @esb geography =
    (SELECT geography::Point(latitude_deg, longitude_deg, 4326)
     FROM airports WHERE ident = 'LTAC');

SELECT TOP 10 name, municipality,
       ROUND(@esb.STDistance(geography::Point(latitude_deg, longitude_deg, 4326)) / 1000, 0) AS km
FROM airports
WHERE iso_country = 'TR'
  AND type IN ('large_airport', 'medium_airport')
  AND ident <> 'LTAC'
ORDER BY km;