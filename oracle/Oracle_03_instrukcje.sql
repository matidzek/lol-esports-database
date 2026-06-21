
-- Dla turnieju o zadanym ID wypisuje ranking kandydatów na MVP
-- 1. Sprawdzenie za pomocą COUNT(*), czy turniej istnieje, a jeśli nie,
--    to wypisuje komunikat i kończy procedurę za pomocą RETURN
-- 2. Otwiera KURSOR sumujący zabójstwa, śmierci i asysty każdego gracza
--    ze wszystkich meczów danego turnieju (złączenie tabel
--    Statystyki, Gry, Mecze, Gracz)
-- 3. Kursor pobiera kolejne wiersze i liczy
--    wskaźnik KDA = (zabójstwa + asysty) / śmierci (jeśli śmierci = 0,
--    o przyjmuje zabójstwa + asysty) i wypisuje pozycję rankingu
CREATE OR REPLACE PROCEDURE KandydaciNaMVP ( p_turniejid IN INTEGER)
IS
    v_nazwaTurnieju Turnieje.Nazwa%TYPE;
    v_licznik INTEGER;
    v_nick Gracz.nick%TYPE;
    v_zabojstwa INTEGER;
    v_smierci INTEGER;
    v_asysty INTEGER;
    v_kda NUMBER(5,2);
    v_lp INTEGER := 0;
    CURSOR CurGracze IS
        SELECT g.nick, SUM(s.Zabojstwa),SUM(s.Smierci),SUM(s.Asysty)
        FROM Statystyki_gracza_z_gry s
        JOIN Gry gr ON gr.ID_gry = s.Gry_ID_gry
        JOIN Mecze m  ON m.id = gr.Mecze_id
        JOIN Gracz g  ON g.id = s.Gracz_id
        WHERE m.Turnieje_ID = p_turniejid
        GROUP BY g.nick
        ORDER BY CASE
            WHEN SUM(s.Smierci) = 0 THEN SUM(s.Zabojstwa) + SUM(s.Asysty)
                                    ELSE (SUM(s.Zabojstwa) + SUM(s.Asysty)) / SUM(s.Smierci)
            END DESC;
BEGIN
    SELECT COUNT(*) INTO v_licznik FROM Turnieje WHERE ID = p_turniejid;
    IF v_licznik = 0 THEN
        DBMS_OUTPUT.PUT_LINE('Turniej o ID: ' || p_turniejid || ' nie istnieje');
        RETURN;
    END IF;

    SELECT Nazwa INTO v_nazwaTurnieju FROM Turnieje WHERE ID = p_turniejid;
    DBMS_OUTPUT.PUT_LINE('Kandydaci na MVP turnieju o nazwie: ' || v_nazwaTurnieju);

    OPEN CurGracze;
    LOOP
        FETCH CurGracze INTO v_nick, v_zabojstwa, v_smierci, v_asysty;
        EXIT WHEN CurGracze%NOTFOUND;
        v_lp := v_lp + 1;
        IF v_smierci = 0 THEN
            v_kda := v_zabojstwa + v_asysty;
        ELSE
            v_kda := (v_zabojstwa + v_asysty) / v_smierci;
        END IF;

        DBMS_OUTPUT.PUT_LINE(v_lp || ' , ' || v_nick || ' KDA = ' ||
            v_zabojstwa || '/' || v_smierci || '/' || v_asysty ||
            '  (KDA = ' || TO_CHAR(v_kda) || ')');
    END LOOP;
    CLOSE CurGracze;

    IF v_lp = 0 THEN
        DBMS_OUTPUT.PUT_LINE('Brak zarejestrowanych statystyk dla tego turnieju');
    END IF;
END;

-- Obsługuje transfer gracza do nowej drużyny i dba o spójność historii
-- zatrudnienia w tabeli Druzyny_gracza
-- 1. Sprawdza, czy gracz istnieje. Jeśli nie, to wywoła RAISE_APPLICATION_ERROR
-- 2. Zamyka aktualnie otwarty okres zatrudnienia tam, gdzie
--    Data_opuszcenia IS NULL, wpisując dzisiejszą datę, a następnie
--    dodaje nowy wiersz nowego zatrudnienia również z dzisiejszą datą
-- 3. Gdy podczas transferu wystąpi błąd, w bloku EXCEPTION wykonuje się ROLLBACK
--    i wypisuje komunikat 'Error: Błąd transferu'
CREATE OR REPLACE PROCEDURE TransferGracza (
p_graczid IN INTEGER,
p_nowadruzyna IN INTEGER,
p_sezonid IN INTEGER,
p_rola IN VARCHAR2 DEFAULT 'Zawodnik'
)
IS
    v_licznik INTEGER;
BEGIN
-- sprawdzenie, czy gracz istnieje
    SELECT COUNT(*) INTO v_licznik FROM Gracz WHERE id = p_graczid;
    IF v_licznik = 0 THEN
        RAISE_APPLICATION_ERROR(-20100, 'Gracz o podanym id ' || p_graczid || ' nie istnieje');
    END IF;

    BEGIN
        UPDATE Druzyny_gracza
        SET Data_opuszcenia = TRUNC(SYSDATE)
        WHERE Gracz_id = p_graczid AND Data_opuszcenia IS NULL;

        INSERT INTO Druzyny_gracza
        (Gracz_id, Drużyny_id, Sezon_ID, Rola_w_druzynie, Data_dolaczenia, Data_opuszcenia)
        VALUES
        (p_graczid, p_nowadruzyna, p_sezonid, p_rola, TRUNC(SYSDATE), NULL);

        COMMIT;
        DBMS_OUTPUT.PUT_LINE('Transfer zapisany: gracz ' || p_graczid ||
            ' wędruje do drużyny: ' || p_nowadruzyna || ' jako: ' || p_rola);
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            DBMS_OUTPUT.PUT_LINE('Error: Błąd transferu');
    END;
END;


-- (Efektywniejszym rozwiązaniem byłoby stworzenie ograniczeń CHECK na encji)
-- Wyzwalacz FOR EACH ROW walidujący dane
-- Blokuje zapis ujemnych statystyk i nie pozwala, aby gracz grał
-- championem, którego sam zbanował
-- W PL SQL wyzwalacz wierszowy odpala się dla każdego wiersza osobno,
-- dlatego nie potrzebuje kursora
-- RAISE_APPLICATION_ERROR automatycznie wycofuje instrukcję
CREATE OR REPLACE TRIGGER WalidacjaDanychGracza
BEFORE INSERT OR UPDATE ON Statystyki_gracza_z_gry
FOR EACH ROW
BEGIN
    IF :NEW.Zabojstwa < 0 OR :NEW.Smierci < 0
       OR :NEW.Asysty < 0 OR :NEW.Zdobyty_zloto < 0 THEN
        RAISE_APPLICATION_ERROR(-20010,
            'Odrzucono gracza: ' || :NEW.Gracz_id ||
            ', ponieważ ma ujemne statystyki.');
    END IF;

    IF :NEW.Champion_zbanowany IS NOT NULL
       AND :NEW.Champion_gracza = :NEW.Champion_zbanowany THEN
        RAISE_APPLICATION_ERROR(-20011,
            'Odrzucono gracza: ' || :NEW.Gracz_id ||
            ', ponieważ gra zbanowanym przez siebie championem: ' || :NEW.Champion_gracza);
    END IF;
END;

-- Po każdej zmianie w tabeli Gry przelicza wynik meczów na podstawie
-- faktycznej liczby gier wygranych przez drużynę pierwszą i drugą.
CREATE OR REPLACE TRIGGER PrzeliczMecz
AFTER INSERT OR DELETE ON Gry
BEGIN
    UPDATE Mecze m
       SET m.Wynik_druzyny_1 =
             (SELECT COUNT(*) FROM Gry g
               WHERE g.Mecze_id = m.id AND g.Zwycieska_druzyna = m.Drużyna_1_id),
           m.Wynik_druzyny_2 =
             (SELECT COUNT(*) FROM Gry g
               WHERE g.Mecze_id = m.id AND g.Zwycieska_druzyna = m.Drużyna_2_id);
END;