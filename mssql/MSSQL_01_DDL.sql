CREATE TABLE Klasa (
    Nazwa_klasy varchar(128) NOT NULL,
    CONSTRAINT Klasa_pk PRIMARY KEY (Nazwa_klasy)
);

-- Pozycje na mapie (Top, Jungle, Mid, ADC, Support)
CREATE TABLE Pozycja (
    Nazwa_pozycji varchar(32) NOT NULL,
    CONSTRAINT Pozycja_pk PRIMARY KEY (Nazwa_pozycji)
);

CREATE TABLE Regiony (
    id int NOT NULL,
    Nazwa varchar(128) NOT NULL,
    CONSTRAINT Regiony_pk PRIMARY KEY (id),
    CONSTRAINT Regiony_uq UNIQUE (Nazwa)
);

-- Faza Grupowa, Play-offs, Finał itd.
CREATE TABLE Etap (
    ID int NOT NULL,
    nazwa varchar(128) NOT NULL,
    CONSTRAINT Etap_pk PRIMARY KEY (ID)
);

-- Formaty drabinki (Best of 3, Double Elimination, ...)
CREATE TABLE Format (
    id_formatu int NOT NULL,
    nazwa varchar(128) NOT NULL,
    CONSTRAINT Format_pk PRIMARY KEY (id_formatu)
);

-- Sezon 12 split 1, Sezon 12 split 3, Sezon 4 split 1 itd.
-- Para "Nr_sezonu" i "split" jest unikalna, ID jest sztucznym kluczem głównym pomocniczym
CREATE TABLE Sezon (
    ID int NOT NULL,
    Nr_sezonu int NOT NULL,
    split int NOT NULL,
    CONSTRAINT Sezon_pk PRIMARY KEY (ID),
    CONSTRAINT Sezon_uq UNIQUE (Nr_sezonu, split),
    CONSTRAINT Sezon_split_chk CHECK (split BETWEEN 1 AND 3)
);

-- Champion z przypisaną klasą
CREATE TABLE Champion (
    Nazwa_championa varchar(128) NOT NULL,
    Klasa_Nazwa_klasy varchar(128) NOT NULL,
    CONSTRAINT Champion_pk PRIMARY KEY (Nazwa_championa)
);

-- Meta championa: jak silny jest na danej pozycji w danym splicie
CREATE TABLE Pozycje_championów (
    Pozycja_Nazwa_pozycji varchar(32) NOT NULL,
    Champion_Nazwa_championa varchar(128) NOT NULL,
    Sezon_ID int NOT NULL,
    tier_championa nchar(1) NOT NULL,
    Winrate decimal(5,2) NOT NULL,
    Pickrate decimal(5,2) NOT NULL,
    Banrate decimal(5,2) NOT NULL,
    CONSTRAINT Pozycje_championów_pk PRIMARY KEY (Pozycja_Nazwa_pozycji, Champion_Nazwa_championa, Sezon_ID),
    CONSTRAINT Poz_tier_chk CHECK (tier_championa IN ('S','A','B','C','D','F')),
    CONSTRAINT Poz_winrate_chk CHECK (Winrate BETWEEN 0 AND 100),
    CONSTRAINT Poz_pickrate_chk CHECK (Pickrate BETWEEN 0 AND 100),
    CONSTRAINT Poz_banrate_chk CHECK (Banrate BETWEEN 0 AND 100)
);

CREATE TABLE Gracz (
    id int NOT NULL,
    nick varchar(128) NOT NULL,
    pochodzenie_gracza int NOT NULL,
    CONSTRAINT Gracz_pk PRIMARY KEY (id)
);

CREATE TABLE Drużyny (
    id int NOT NULL,
    region_turniejowy_drużyny int NOT NULL,
    Nazwa varchar(128) NOT NULL,
    Data_zalozenia date NOT NULL,
    Data_rozwiazania date NULL,
    CONSTRAINT Drużyny_pk PRIMARY KEY (id)
);

-- Pula championów gracza w danym splicie (z jego winrate na danym splicie)
CREATE TABLE Championy_gracza (
    ID int NOT NULL,
    Gracz_id int NOT NULL,
    Champion_Nazwa_championa varchar(128) NOT NULL,
    Sezon_ID int NOT NULL,
    Win_rate decimal(5,2) NOT NULL,
    CONSTRAINT Championy_gracza_pk PRIMARY KEY (ID),
    CONSTRAINT Champgr_uq UNIQUE (Gracz_id, Champion_Nazwa_championa, Sezon_ID),
    CONSTRAINT Champgr_wr_chk CHECK (Win_rate BETWEEN 0 AND 100)
);

-- Historia zatrudnienia gracza (gdzie, kiedy, jaka rola)
CREATE TABLE Druzyny_gracza (
    Gracz_id int NOT NULL,
    Drużyny_id int NOT NULL,
    Sezon_ID int NOT NULL,
    Rola_w_druzynie nvarchar(128) NOT NULL,
    Data_dolaczenia date NOT NULL,
    Data_opuszcenia date NULL,
    CONSTRAINT Druzyny_gracza_pk PRIMARY KEY (Gracz_id, Drużyny_id, Sezon_ID)
);

-- Turniej (zwycięzca, MVP, pula nagród, format, lokalizacja, daty)
CREATE TABLE Turnieje (
    ID int NOT NULL,
    Sezon_ID int NOT NULL,
    zwyciezca int NOT NULL,
    MVP_Gracz_id int NULL,
    Nazwa varchar(128) NOT NULL,
    Pula_nagrod int NOT NULL,
    Miejsce_eventu varchar(128) NOT NULL,
    Data_startu date NOT NULL,
    Data_konca date NOT NULL,
    Format_id_formatu int NOT NULL,
    CONSTRAINT Turnieje_pk PRIMARY KEY (ID),
    CONSTRAINT Turn_daty_chk CHECK (Data_konca >= Data_startu),
    CONSTRAINT Turn_pula_chk CHECK (Pula_nagrod >= 0)
);

-- Rozdział typów turnieju: globalny
CREATE TABLE Globalne (
    Turnieje_ID int NOT NULL,
    Typ_globalny varchar(128) NOT NULL,
    CONSTRAINT Globalne_pk PRIMARY KEY (Turnieje_ID)
);

-- Rozdział typów turnieju: lokalny
CREATE TABLE Lokalne (
    Turnieje_ID int NOT NULL,
    Regiony_id int NOT NULL,
    Etap_ID int NOT NULL,
    CONSTRAINT Lokalne_pk PRIMARY KEY (Turnieje_ID)
);

CREATE TABLE Druzyny_turniejow (
    Drużyny_id int NOT NULL,
    Turnieje_id int NOT NULL,
    Miejsce_w_turnieju int NOT NULL,
    CONSTRAINT Druzyny_turniejow_pk PRIMARY KEY (Drużyny_id, Turnieje_id),
    CONSTRAINT Druzturn_miejsce_chk CHECK (Miejsce_w_turnieju >= 1)
);

CREATE TABLE Mecze (
    id int NOT NULL,
    Drużyna_1_id int NOT NULL,
    Drużyna_2_id int NOT NULL,
    Turnieje_ID int NOT NULL,
    Wynik_druzyny_1 int NOT NULL,
    Wynik_druzyny_2 int NOT NULL,
    Data_meczu date NOT NULL,
    Etap_ID int NOT NULL,
    CONSTRAINT Mecze_pk PRIMARY KEY (id),
    CONSTRAINT Mecze_rozne_chk CHECK (Drużyna_1_id <> Drużyna_2_id),
    CONSTRAINT Mecze_wynik_chk CHECK (Wynik_druzyny_1 >= 0 AND Wynik_druzyny_2 >= 0)
);

-- Pojedyncza gra w meczu
CREATE TABLE Gry (
    ID_gry int NOT NULL,
    Mecze_id int NOT NULL,
    Nr_gry int NOT NULL,
    Zwycieska_druzyna int NOT NULL,
    CONSTRAINT Gry_pk PRIMARY KEY (ID_gry),
    CONSTRAINT Gry_uq UNIQUE (Mecze_id, Nr_gry)
);

-- Statystyki pojedynczego gracza w pojedynczej grze
CREATE TABLE Statystyki_gracza_z_gry (
    Gracz_id int NOT NULL,
    Gry_ID_gry int NOT NULL,
    Champion_gracza varchar(128) NOT NULL,
    Champion_zbanowany varchar(128) NULL,
    Zabojstwa int NOT NULL,
    Smierci int NOT NULL,
    Asysty int NOT NULL,
    Zdobyty_zloto int NOT NULL,
    CONSTRAINT Statystyki_gracza_z_gry_pk PRIMARY KEY (Gracz_id, Gry_ID_gry)
);

ALTER TABLE Champion ADD CONSTRAINT FK_Champion_Klasa
    FOREIGN KEY (Klasa_Nazwa_klasy) REFERENCES Klasa (Nazwa_klasy);

ALTER TABLE Championy_gracza ADD CONSTRAINT FK_ChampGracza_Champion
    FOREIGN KEY (Champion_Nazwa_championa) REFERENCES Champion (Nazwa_championa);

ALTER TABLE Championy_gracza ADD CONSTRAINT FK_ChampGracza_Sezon
    FOREIGN KEY (Sezon_ID) REFERENCES Sezon (ID);

ALTER TABLE Championy_gracza ADD CONSTRAINT FK_ChampGracza_Gracz
    FOREIGN KEY (Gracz_id) REFERENCES Gracz (id);

ALTER TABLE Druzyny_gracza ADD CONSTRAINT FK_DruzGracza_Druzyny
    FOREIGN KEY (Drużyny_id) REFERENCES Drużyny (id);

ALTER TABLE Druzyny_gracza ADD CONSTRAINT FK_DruzGracza_Gracz
    FOREIGN KEY (Gracz_id) REFERENCES Gracz (id);

ALTER TABLE Druzyny_gracza ADD CONSTRAINT FK_DruzGracza_Sezon
    FOREIGN KEY (Sezon_ID) REFERENCES Sezon (ID);

ALTER TABLE Druzyny_turniejow ADD CONSTRAINT FK_DruzTurn_Druzyny
    FOREIGN KEY (Drużyny_id) REFERENCES Drużyny (id);

ALTER TABLE Druzyny_turniejow ADD CONSTRAINT FK_DruzTurn_Turnieje
    FOREIGN KEY (Turnieje_id) REFERENCES Turnieje (ID);

ALTER TABLE Drużyny ADD CONSTRAINT FK_Druzyny_Regiony
    FOREIGN KEY (region_turniejowy_drużyny) REFERENCES Regiony (id);

ALTER TABLE Globalne ADD CONSTRAINT FK_Globalne_Turnieje
    FOREIGN KEY (Turnieje_ID) REFERENCES Turnieje (ID);

ALTER TABLE Gracz ADD CONSTRAINT FK_Gracz_Regiony
    FOREIGN KEY (pochodzenie_gracza) REFERENCES Regiony (id);

ALTER TABLE Gry ADD CONSTRAINT FK_Gry_Druzyny
    FOREIGN KEY (Zwycieska_druzyna) REFERENCES Drużyny (id);

ALTER TABLE Gry ADD CONSTRAINT FK_Gry_Mecze
    FOREIGN KEY (Mecze_id) REFERENCES Mecze (id);

ALTER TABLE Lokalne ADD CONSTRAINT FK_Lokalne_Etap
    FOREIGN KEY (Etap_ID) REFERENCES Etap (ID);

ALTER TABLE Lokalne ADD CONSTRAINT FK_Lokalne_Regiony
    FOREIGN KEY (Regiony_id) REFERENCES Regiony (id);

ALTER TABLE Lokalne ADD CONSTRAINT FK_Lokalne_Turnieje
    FOREIGN KEY (Turnieje_ID) REFERENCES Turnieje (ID);

ALTER TABLE Mecze ADD CONSTRAINT FK_Mecze_Druzyny1
    FOREIGN KEY (Drużyna_1_id) REFERENCES Drużyny (id);

ALTER TABLE Mecze ADD CONSTRAINT FK_Mecze_Druzyny2
    FOREIGN KEY (Drużyna_2_id) REFERENCES Drużyny (id);

ALTER TABLE Mecze ADD CONSTRAINT FK_Mecze_Etap
    FOREIGN KEY (Etap_ID) REFERENCES Etap (ID);

ALTER TABLE Mecze ADD CONSTRAINT FK_Mecze_Turnieje
    FOREIGN KEY (Turnieje_ID) REFERENCES Turnieje (ID);

ALTER TABLE Pozycje_championów ADD CONSTRAINT FK_PozChamp_Sezon
    FOREIGN KEY (Sezon_ID) REFERENCES Sezon (ID);

ALTER TABLE Pozycje_championów ADD CONSTRAINT FK_PozChamp_Champion
    FOREIGN KEY (Champion_Nazwa_championa) REFERENCES Champion (Nazwa_championa);

ALTER TABLE Pozycje_championów ADD CONSTRAINT FK_PozChamp_Pozycja
    FOREIGN KEY (Pozycja_Nazwa_pozycji) REFERENCES Pozycja (Nazwa_pozycji);

ALTER TABLE Statystyki_gracza_z_gry ADD CONSTRAINT FK_Stat_ChampBan
    FOREIGN KEY (Champion_zbanowany) REFERENCES Champion (Nazwa_championa);

ALTER TABLE Statystyki_gracza_z_gry ADD CONSTRAINT FK_Stat_ChampGracza
    FOREIGN KEY (Champion_gracza) REFERENCES Champion (Nazwa_championa);

ALTER TABLE Statystyki_gracza_z_gry ADD CONSTRAINT FK_Stat_Gry
    FOREIGN KEY (Gry_ID_gry) REFERENCES Gry (ID_gry);

ALTER TABLE Statystyki_gracza_z_gry ADD CONSTRAINT FK_Stat_Gracz
    FOREIGN KEY (Gracz_id) REFERENCES Gracz (id);

ALTER TABLE Turnieje ADD CONSTRAINT FK_Turnieje_Druzyny
    FOREIGN KEY (zwyciezca) REFERENCES Drużyny (id);

ALTER TABLE Turnieje ADD CONSTRAINT FK_Turnieje_Format
    FOREIGN KEY (Format_id_formatu) REFERENCES Format (id_formatu);

ALTER TABLE Turnieje ADD CONSTRAINT FK_Turnieje_Gracz
    FOREIGN KEY (MVP_Gracz_id) REFERENCES Gracz (id);

ALTER TABLE Turnieje ADD CONSTRAINT FK_Turnieje_Sezon
    FOREIGN KEY (Sezon_ID) REFERENCES Sezon (ID);