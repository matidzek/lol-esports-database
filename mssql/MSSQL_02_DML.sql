INSERT INTO Regiony (id, Nazwa) VALUES (1, 'Europe (LEC)');
INSERT INTO Regiony (id, Nazwa) VALUES (2, 'Korea (LCK)');
INSERT INTO Regiony (id, Nazwa) VALUES (3, 'China (LPL)');
INSERT INTO Regiony (id, Nazwa) VALUES (4, 'North America (LCS)');
INSERT INTO Regiony (id, Nazwa) VALUES (5, 'International');

INSERT INTO Klasa (Nazwa_klasy) VALUES ('Wojownik');
INSERT INTO Klasa (Nazwa_klasy) VALUES ('Mag');
INSERT INTO Klasa (Nazwa_klasy) VALUES ('Strzelec');
INSERT INTO Klasa (Nazwa_klasy) VALUES ('Zabójca');
INSERT INTO Klasa (Nazwa_klasy) VALUES ('Obrońca');
INSERT INTO Klasa (Nazwa_klasy) VALUES ('Wspierający');

INSERT INTO Pozycja (Nazwa_pozycji) VALUES ('Top');
INSERT INTO Pozycja (Nazwa_pozycji) VALUES ('Jungle');
INSERT INTO Pozycja (Nazwa_pozycji) VALUES ('Mid');
INSERT INTO Pozycja (Nazwa_pozycji) VALUES ('ADC');
INSERT INTO Pozycja (Nazwa_pozycji) VALUES ('Support');

INSERT INTO Etap (ID, nazwa) VALUES (1, 'Faza grupowa');
INSERT INTO Etap (ID, nazwa) VALUES (2, 'Play-offs');
INSERT INTO Etap (ID, nazwa) VALUES (3, 'Półfinał');
INSERT INTO Etap (ID, nazwa) VALUES (4, 'Finał');

INSERT INTO Format (id_formatu, nazwa) VALUES (1, 'Best of 1');
INSERT INTO Format (id_formatu, nazwa) VALUES (2, 'Best of 3');
INSERT INTO Format (id_formatu, nazwa) VALUES (3, 'Best of 5');
INSERT INTO Format (id_formatu, nazwa) VALUES (4, 'Double elimination');

INSERT INTO Sezon (ID, Nr_sezonu, split) VALUES (101, 12, 1);
INSERT INTO Sezon (ID, Nr_sezonu, split) VALUES (102, 12, 2);
INSERT INTO Sezon (ID, Nr_sezonu, split) VALUES (103, 13, 1);
INSERT INTO Sezon (ID, Nr_sezonu, split) VALUES (104, 13, 2);

INSERT INTO Champion (Nazwa_championa, Klasa_Nazwa_klasy) VALUES ('Gragas', 'Mag');
INSERT INTO Champion (Nazwa_championa, Klasa_Nazwa_klasy) VALUES ('Ahri', 'Mag');
INSERT INTO Champion (Nazwa_championa, Klasa_Nazwa_klasy) VALUES ('Ornn', 'Obrońca');
INSERT INTO Champion (Nazwa_championa, Klasa_Nazwa_klasy) VALUES ('Malphite', 'Obrońca');
INSERT INTO Champion (Nazwa_championa, Klasa_Nazwa_klasy) VALUES ('Shyvana', 'Wojownik');
INSERT INTO Champion (Nazwa_championa, Klasa_Nazwa_klasy) VALUES ('Kled', 'Wojownik');
INSERT INTO Champion (Nazwa_championa, Klasa_Nazwa_klasy) VALUES ('Thresh', 'Wspierający');
INSERT INTO Champion (Nazwa_championa, Klasa_Nazwa_klasy) VALUES ('Braum', 'Wspierający');
INSERT INTO Champion (Nazwa_championa, Klasa_Nazwa_klasy) VALUES ('Lucian', 'Strzelec');
INSERT INTO Champion (Nazwa_championa, Klasa_Nazwa_klasy) VALUES ('Kai''sa', 'Strzelec');
INSERT INTO Champion (Nazwa_championa, Klasa_Nazwa_klasy) VALUES ('Talon', 'Zabójca');
INSERT INTO Champion (Nazwa_championa, Klasa_Nazwa_klasy) VALUES ('Shaco', 'Zabójca');

-- 1 Europe, 2 Korea, 3 China
INSERT INTO Gracz (id, nick, pochodzenie_gracza) VALUES (1, 'Faker', 2);
INSERT INTO Gracz (id, nick, pochodzenie_gracza) VALUES (2, 'Caps', 1);
INSERT INTO Gracz (id, nick, pochodzenie_gracza) VALUES (3, 'Ruler', 2);
INSERT INTO Gracz (id, nick, pochodzenie_gracza) VALUES (4, 'Jankos', 1);
INSERT INTO Gracz (id, nick, pochodzenie_gracza) VALUES (5, 'Dopa', 3);

INSERT INTO Drużyny (id, region_turniejowy_drużyny, Nazwa, Data_zalozenia, Data_rozwiazania)
VALUES (1, 2, 'T1', '2003-01-01', NULL);
INSERT INTO Drużyny (id, region_turniejowy_drużyny, Nazwa, Data_zalozenia, Data_rozwiazania)
VALUES (2, 1, 'Birch Esports', '2010-04-10', NULL);
INSERT INTO Drużyny (id, region_turniejowy_drużyny, Nazwa, Data_zalozenia, Data_rozwiazania)
VALUES (3, 3, 'JD Gaming', '2017-06-07', NULL);
INSERT INTO Drużyny (id, region_turniejowy_drużyny, Nazwa, Data_zalozenia, Data_rozwiazania)
VALUES (5, 2, 'EggSeller.Daj', '2017-12-27', NULL);

INSERT INTO Pozycje_championów (Pozycja_Nazwa_pozycji, Champion_Nazwa_championa, Sezon_ID, tier_championa, Winrate, Pickrate, Banrate)
VALUES ('Mid', 'Ahri', 101, 'S', 52.50, 15.00, 20.00);
INSERT INTO Pozycje_championów (Pozycja_Nazwa_pozycji, Champion_Nazwa_championa, Sezon_ID, tier_championa, Winrate, Pickrate, Banrate)
VALUES ('Jungle', 'Shyvana', 101, 'A', 49.80, 25.00, 10.00);
INSERT INTO Pozycje_championów (Pozycja_Nazwa_pozycji, Champion_Nazwa_championa, Sezon_ID, tier_championa, Winrate, Pickrate, Banrate)
VALUES ('ADC', 'Lucian', 102, 'S', 53.20, 30.00, 45.00);
INSERT INTO Pozycje_championów (Pozycja_Nazwa_pozycji, Champion_Nazwa_championa, Sezon_ID, tier_championa, Winrate, Pickrate, Banrate)
VALUES ('Support', 'Thresh', 101, 'B', 48.50, 12.00, 5.00);
INSERT INTO Pozycje_championów (Pozycja_Nazwa_pozycji, Champion_Nazwa_championa, Sezon_ID, tier_championa, Winrate, Pickrate, Banrate)
VALUES ('Top', 'Ornn', 103, 'A', 51.00, 10.00, 8.00);


INSERT INTO Championy_gracza (ID, Gracz_id, Champion_Nazwa_championa, Sezon_ID, Win_rate)
VALUES (1, 1, 'Ahri', 101, 75.00);
INSERT INTO Championy_gracza (ID, Gracz_id, Champion_Nazwa_championa, Sezon_ID, Win_rate)
VALUES (2, 2, 'Zed', 101, 60.00);
INSERT INTO Championy_gracza (ID, Gracz_id, Champion_Nazwa_championa, Sezon_ID, Win_rate)
VALUES (3, 3, 'Jinx', 102, 80.00);
INSERT INTO Championy_gracza (ID, Gracz_id, Champion_Nazwa_championa, Sezon_ID, Win_rate)
VALUES (4, 4, 'Thresh', 101, 67.00);
INSERT INTO Championy_gracza (ID, Gracz_id, Champion_Nazwa_championa, Sezon_ID, Win_rate)
VALUES (5, 5, 'Shyvana', 101, 65.00);


INSERT INTO Druzyny_gracza (Gracz_id, Drużyny_id, Sezon_ID, Rola_w_druzynie, Data_dolaczenia, Data_opuszcenia)
VALUES (1, 1, 101, 'Midlaner', '2013-02-01', NULL);
INSERT INTO Druzyny_gracza (Gracz_id, Drużyny_id, Sezon_ID, Rola_w_druzynie, Data_dolaczenia, Data_opuszcenia)
VALUES (2, 2, 101, 'Midlaner', '2019-01-01', NULL);
INSERT INTO Druzyny_gracza (Gracz_id, Drużyny_id, Sezon_ID, Rola_w_druzynie, Data_dolaczenia, Data_opuszcenia)
VALUES (3, 3, 102, 'ADC', '2023-01-01', NULL);
INSERT INTO Druzyny_gracza (Gracz_id, Drużyny_id, Sezon_ID, Rola_w_druzynie, Data_dolaczenia, Data_opuszcenia)
VALUES (5, 1, 101, 'Support', '2021-11-15', NULL);
INSERT INTO Druzyny_gracza (Gracz_id, Drużyny_id, Sezon_ID, Rola_w_druzynie, Data_dolaczenia, Data_opuszcenia)
VALUES (4, 2, 101, 'Jungler', '2018-01-01', '2022-01-01');

INSERT INTO Turnieje (ID, Sezon_ID, zwyciezca, MVP_Gracz_id, Nazwa, Pula_nagrod, Miejsce_eventu, Data_startu, Data_konca, Format_id_formatu)
VALUES (1, 102, 1, 1, 'Worlds 2023', 1000000, 'Seoul, Korea', '2023-10-10', '2023-12-01', 3);
INSERT INTO Turnieje (ID, Sezon_ID, zwyciezca, MVP_Gracz_id, Nazwa, Pula_nagrod, Miejsce_eventu, Data_startu, Data_konca, Format_id_formatu)
VALUES (2, 103, 5, 3, 'MSI 2024', 500000, 'Hanoi, China', '2024-05-01', '2024-06-01', 4);
INSERT INTO Turnieje (ID, Sezon_ID, zwyciezca, MVP_Gracz_id, Nazwa, Pula_nagrod, Miejsce_eventu, Data_startu, Data_konca, Format_id_formatu)
VALUES (3, 101, 2, 2, 'LEC Winter 2023', 250000, 'Berlin, Germany', '2023-01-01', '2023-03-01', 2);

INSERT INTO Globalne (Turnieje_ID, Typ_globalny) VALUES (1, 'Worlds');
INSERT INTO Globalne (Turnieje_ID, Typ_globalny) VALUES (2, 'MSI');
INSERT INTO Lokalne (Turnieje_ID, Regiony_id, Etap_ID) VALUES (3, 1, 2);

-- Druzyny_turniejow (udział i zajęte miejsce)
INSERT INTO Druzyny_turniejow (Drużyny_id, Turnieje_id, Miejsce_w_turnieju) VALUES (1, 1, 1);
INSERT INTO Druzyny_turniejow (Drużyny_id, Turnieje_id, Miejsce_w_turnieju) VALUES (3, 1, 3);
INSERT INTO Druzyny_turniejow (Drużyny_id, Turnieje_id, Miejsce_w_turnieju) VALUES (2, 1, 9);
INSERT INTO Druzyny_turniejow (Drużyny_id, Turnieje_id, Miejsce_w_turnieju) VALUES (5, 2, 1);
INSERT INTO Druzyny_turniejow (Drużyny_id, Turnieje_id, Miejsce_w_turnieju) VALUES (2, 3, 1);


INSERT INTO Mecze (id, Drużyna_1_id, Drużyna_2_id, Turnieje_ID, Wynik_druzyny_1, Wynik_druzyny_2, Data_meczu, Etap_ID)
VALUES (1, 1, 3, 1, 3, 1, '2023-11-19', 4);
INSERT INTO Mecze (id, Drużyna_1_id, Drużyna_2_id, Turnieje_ID, Wynik_druzyny_1, Wynik_druzyny_2, Data_meczu, Etap_ID)
VALUES (2, 2, 4, 3, 3, 0, '2023-02-20', 3);

INSERT INTO Gry (ID_gry, Mecze_id, Nr_gry, Zwycieska_druzyna) VALUES (10, 1, 1, 1);
INSERT INTO Gry (ID_gry, Mecze_id, Nr_gry, Zwycieska_druzyna) VALUES (11, 1, 2, 3);
INSERT INTO Gry (ID_gry, Mecze_id, Nr_gry, Zwycieska_druzyna) VALUES (12, 1, 3, 1);
INSERT INTO Gry (ID_gry, Mecze_id, Nr_gry, Zwycieska_druzyna) VALUES (13, 1, 4, 1);
INSERT INTO Gry (ID_gry, Mecze_id, Nr_gry, Zwycieska_druzyna) VALUES (20, 2, 1, 2);

INSERT INTO Statystyki_gracza_z_gry (Gracz_id, Gry_ID_gry, Champion_gracza, Champion_zbanowany, Zabojstwa, Smierci, Asysty, Zdobyty_zloto)
VALUES (1, 10, 'Ahri', 'Kled', 5, 1, 10, 14500);
INSERT INTO Statystyki_gracza_z_gry (Gracz_id, Gry_ID_gry, Champion_gracza, Champion_zbanowany, Zabojstwa, Smierci, Asysty, Zdobyty_zloto)
VALUES (5, 10, 'Thresh', 'Lucian', 1, 2, 15, 9500);
INSERT INTO Statystyki_gracza_z_gry (Gracz_id, Gry_ID_gry, Champion_gracza, Champion_zbanowany, Zabojstwa, Smierci, Asysty, Zdobyty_zloto)
VALUES (3, 10, 'Kai''sa', 'Shyvana', 2, 4, 2, 11000);
INSERT INTO Statystyki_gracza_z_gry (Gracz_id, Gry_ID_gry, Champion_gracza, Champion_zbanowany, Zabojstwa, Smierci, Asysty, Zdobyty_zloto)
VALUES (2, 20, 'Talon', 'Ahri', 8, 2, 4, 16000);
INSERT INTO Statystyki_gracza_z_gry (Gracz_id, Gry_ID_gry, Champion_gracza, Champion_zbanowany, Zabojstwa, Smierci, Asysty, Zdobyty_zloto)
VALUES (4, 20, 'Shaco', 'Ornn', 4, 1, 8, 12500);
