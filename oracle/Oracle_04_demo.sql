-- PROCEDURA Raport_MVP_Kandydatow
--  Wypisanie rankingu kandydatów na MVP turnieju o id = 1
--  Procedura otwiera kursor i dla każdego gracza liczy KDA i ustawia ich w rankingu

BEGIN
    KandydaciNaMVP(3);
END;

-- Wywołanie dla nieistniejącego turnieju
BEGIN
    KandydaciNaMVP(999);
END;


-- ---------------------------------------------------------------------
-- PROCEDURA TransferGracza
-- Poprawny transfer: gracz 4 zostaje trenerem w drużynie 1 w splicie 101
-- Procedura zamknie poprzedni okres i doda nowy wpis.
BEGIN
    TransferGracza(4, 1, 101, 'Trener');
END;

-- Historia zatrudnienia gracza 4 po transferze
SELECT Gracz_id, Drużyny_id, Sezon_ID, Rola_w_druzynie, Data_dolaczenia, Data_opuszcenia
FROM Druzyny_gracza
WHERE Gracz_id = 4
ORDER BY Data_dolaczenia;

-- Transfer wywołujący błąd, próba ponownego przypisania gracza 1
BEGIN
    TransferGracza(1, 1, 101, 'Midlaner');
END;


-- ----------------------------------------------------------
-- WYZWALACZ WalidacjaDanychGracza(z kursorem)
-- Próba zapisu ujemnych statystyk wypisuje powód,
-- wykonuje ROLLBACK i zgłasza błąd

BEGIN
    INSERT INTO Statystyki_gracza_z_gry
        (Gracz_id, Gry_ID_gry, Champion_gracza, Champion_zbanowany, Zabojstwa, Smierci, Asysty, Zdobyty_zloto)
    VALUES (2, 12, 'Gragas', 'Ahri', -5, 1, 3, 10000);
EXCEPTION
    WHEN OTHERS THEN
        dbms_output.put_line('Przechwycono (oczekiwane): ' || SQLERRM);
END;

-- Próba zagrania zbanowanym przez siebie championem, wyzwalacz odrzuca
BEGIN
    INSERT INTO Statystyki_gracza_z_gry
        (Gracz_id, Gry_ID_gry, Champion_gracza, Champion_zbanowany, Zabojstwa, Smierci, Asysty, Zdobyty_zloto)
    VALUES (2, 12, 'Gragas', 'Gragas', 3, 1, 3, 10000);
EXCEPTION
    WHEN OTHERS THEN
        dbms_output.put_line('Error: ' || SQLERRM);
END;


-- ---------------------------------------------------------------------
-- WYZWALACZ PrzeliczMecz
-- Mecz 2 ma na razie tylko jedną zapisaną grę (gra 20)
-- Dopiszę drugą grę i sprawdzę, czy wyzwalacz
-- automatycznie przeliczy wynik meczu na podstawie tabeli Gry

-- stan przed dopisaniem gry
SELECT id, Wynik_druzyny_1, Wynik_druzyny_2 FROM Mecze WHERE id = 2;

-- dopisanie nowej gry
INSERT INTO Gry (ID_gry, Mecze_id, Nr_gry, Zwycieska_druzyna) VALUES (21, 2, 2, 3);

-- stan po dopisaniu gry
SELECT id, Wynik_druzyny_1, Wynik_druzyny_2 FROM Mecze WHERE id = 2;

COMMIT;
