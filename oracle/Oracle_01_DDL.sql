
-- Klasy postaci
CREATE TABLE Klasa (
    Nazwa_klasy varchar2(128) NOT NULL,
    CONSTRAINT Klasa_pk PRIMARY KEY (Nazwa_klasy)
);

-- Pozycje na mapie (Top, Jungle, Mid, ADC, Support)
CREATE TABLE Pozycja (
    Nazwa_pozycji varchar2(32) NOT NULL,
    CONSTRAINT Pozycja_pk PRIMARY KEY (Nazwa_pozycji)
);

CREATE TABLE Regiony (
    id integer NOT NULL,
    Nazwa varchar2(128) NOT NULL,
    CONSTRAINT Regiony_pk PRIMARY KEY (id),
    CONSTRAINT Regiony_uq UNIQUE (Nazwa)
);

-- Faza Grupowa, Play-offs, Finał itd.
CREATE TABLE Etap (
    ID integer NOT NULL,
    nazwa varchar2(128) NOT NULL,
    CONSTRAINT Etap_pk PRIMARY KEY (ID)
);

-- Formaty drabinki (Best of 3, Double Elimination, ...)
CREATE TABLE Format (
    id_formatu integer NOT NULL,
    nazwa varchar2(128) NOT NULL,
    CONSTRAINT Format_pk PRIMARY KEY (id_formatu)
);

-- Sezon 12 split 1, Sezon 12 split 3, Sezon 4 split 1 itd.
-- Para "Nr_sezonu" i "split" jest unikalna, ID jest sztucznym kluczem głównym pomocniczym
CREATE TABLE Sezon (
    ID integer NOT NULL,
    Nr_sezonu integer NOT NULL,
    split integer NOT NULL,
    CONSTRAINT Sezon_pk PRIMARY KEY (ID),
    CONSTRAINT Sezon_uq UNIQUE (Nr_sezonu, split),
    CONSTRAINT Sezon_split_chk CHECK (split BETWEEN 1 AND 3)
);

-- Champion z przypisaną klasą
CREATE TABLE Champion (
    Nazwa_championa varchar2(128) NOT NULL,
    Klasa_Nazwa_klasy varchar2(128) NOT NULL,
    CONSTRAINT Champion_pk PRIMARY KEY (Nazwa_championa)
);

-- Meta championa: jak silny jest na danej pozycji w danym splicie
CREATE TABLE Pozycje_championów (
    Pozycja_Nazwa_pozycji varchar2(32) NOT NULL,
    Champion_Nazwa_championa varchar2(128) NOT NULL,
    Sezon_ID integer NOT NULL,
    tier_championa nchar(1) NOT NULL,
    Winrate number(5,2) NOT NULL,
    Pickrate number(5,2) NOT NULL,
    Banrate number(5,2) NOT NULL,
    CONSTRAINT Pozycje_championów_pk PRIMARY KEY (Pozycja_Nazwa_pozycji, Champion_Nazwa_championa, Sezon_ID),
    CONSTRAINT Poz_tier_chk CHECK (tier_championa IN ('S','A','B','C','D','F')),
    CONSTRAINT Poz_winrate_chk CHECK (Winrate BETWEEN 0 AND 100),
    CONSTRAINT Poz_pickrate_chk CHECK (Pickrate BETWEEN 0 AND 100),
    CONSTRAINT Poz_banrate_chk CHECK (Banrate BETWEEN 0 AND 100)
);

CREATE TABLE Gracz (
    id integer NOT NULL,
    nick varchar2(128) NOT NULL,
    pochodzenie_gracza integer NOT NULL,
    CONSTRAINT Gracz_pk PRIMARY KEY (id)
);

CREATE TABLE Drużyny (
    id integer NOT NULL,
    region_turniejowy_drużyny integer NOT NULL,
    Nazwa varchar2(128) NOT NULL,
    Data_zalozenia date NOT NULL,
    Data_rozwiazania date NULL,
    CONSTRAINT Drużyny_pk PRIMARY KEY (id)
);

-- Pula championów gracza w danym splicie (z jego winrate na danym splicie)
CREATE TABLE Championy_gracza (
    ID integer NOT NULL,
    Gracz_id integer NOT NULL,
    Champion_Nazwa_championa varchar2(128) NOT NULL,
    Sezon_ID integer NOT NULL,
    Win_rate number(5,2) NOT NULL,
    CONSTRAINT Championy_gracza_pk PRIMARY KEY (ID),
    CONSTRAINT Champgr_uq UNIQUE (Gracz_id, Champion_Nazwa_championa, Sezon_ID),
    CONSTRAINT Champgr_wr_chk CHECK (Win_rate BETWEEN 0 AND 100)
);

-- Historia zatrudnienia gracza (gdzie, kiedy, jaka rola)
CREATE TABLE Druzyny_gracza (
    Gracz_id integer NOT NULL,
    Drużyny_id integer NOT NULL,
    Sezon_ID integer NOT NULL,
    Rola_w_druzynie nvarchar2(128) NOT NULL,
    Data_dolaczenia date NOT NULL,
    Data_opuszcenia date NULL,
    CONSTRAINT Druzyny_gracza_pk PRIMARY KEY (Gracz_id, Drużyny_id, Sezon_ID)
);

-- Turniej (zwycięzca, MVP, pula nagród, format, lokalizacja, daty)
CREATE TABLE Turnieje (
    ID integer NOT NULL,
    Sezon_ID integer NOT NULL,
    zwyciezca integer NOT NULL,
    MVP_Gracz_id integer NULL,
    Nazwa varchar2(128) NOT NULL,
    Pula_nagrod integer NOT NULL,
    Miejsce_eventu varchar2(128) NOT NULL,
    Data_startu date NOT NULL,
    Data_konca date NOT NULL,
    Format_id_formatu integer NOT NULL,
    CONSTRAINT Turnieje_pk PRIMARY KEY (ID),
    CONSTRAINT Turn_daty_chk CHECK (Data_konca >= Data_startu),
    CONSTRAINT Turn_pula_chk CHECK (Pula_nagrod >= 0)
);

-- Rozdział typów turnieju: globalny
CREATE TABLE Globalne (
    Turnieje_ID integer NOT NULL,
    Typ_globalny varchar2(128) NOT NULL,
    CONSTRAINT Globalne_pk PRIMARY KEY (Turnieje_ID)
);

-- Rozdział typów turnieju: lokalny
CREATE TABLE Lokalne (
    Turnieje_ID integer NOT NULL,
    Regiony_id integer NOT NULL,
    Etap_ID integer NOT NULL,
    CONSTRAINT Lokalne_pk PRIMARY KEY (Turnieje_ID)
);

CREATE TABLE Druzyny_turniejow (
    Drużyny_id integer NOT NULL,
    Turnieje_id integer NOT NULL,
    Miejsce_w_turnieju integer NOT NULL,
    CONSTRAINT Druzyny_turniejow_pk PRIMARY KEY (Drużyny_id, Turnieje_id),
    CONSTRAINT Druzturn_miejsce_chk CHECK (Miejsce_w_turnieju >= 1)
);

CREATE TABLE Mecze (
    id integer NOT NULL,
    Drużyna_1_id integer NOT NULL,
    Drużyna_2_id integer NOT NULL,
    Turnieje_ID integer NOT NULL,
    Wynik_druzyny_1 integer NOT NULL,
    Wynik_druzyny_2 integer NOT NULL,
    Data_meczu date NOT NULL,
    Etap_ID integer NOT NULL,
    CONSTRAINT Mecze_pk PRIMARY KEY (id),
    CONSTRAINT Mecze_rozne_chk CHECK (Drużyna_1_id <> Drużyna_2_id),
    CONSTRAINT Mecze_wynik_chk CHECK (Wynik_druzyny_1 >= 0 AND Wynik_druzyny_2 >= 0)
);

-- Pojedyncza gra w meczu
CREATE TABLE Gry (
    ID_gry integer NOT NULL,
    Mecze_id integer NOT NULL,
    Nr_gry integer NOT NULL,
    Zwycieska_druzyna integer NOT NULL,
    CONSTRAINT Gry_pk PRIMARY KEY (ID_gry),
    CONSTRAINT Gry_uq UNIQUE (Mecze_id, Nr_gry)
);

-- Statystyki pojedynczego gracza w pojedynczej grze
CREATE TABLE Statystyki_gracza_z_gry (
    Gracz_id integer NOT NULL,
    Gry_ID_gry integer NOT NULL,
    Champion_gracza varchar2(128) NOT NULL,
    Champion_zbanowany varchar2(128) NULL,
    Zabojstwa integer NOT NULL,
    Smierci integer NOT NULL,
    Asysty integer NOT NULL,
    Zdobyty_zloto integer NOT NULL,
    CONSTRAINT Statystyki_gracza_z_gry_pk PRIMARY KEY (Gracz_id, Gry_ID_gry),
    CONSTRAINT Stat_kda_chk CHECK (Zabojstwa >= 0 AND Smierci >= 0 AND Asysty >= 0),
    CONSTRAINT Stat_zloto_chk CHECK (Zdobyty_zloto >= 0)
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