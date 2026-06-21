-- PROCEDURA KandydaciNaMVP (z kursorem)
-- Wypisanie rankingu kandydatów na MVP turnieju o ID = 1
-- Procedura otwiera kursor i dla każdego gracza liczy KDA i ustawia ich w rankingu

EXEC KandydaciNaMVP @turniejid = 1;
GO
-- Wywołanie dla nieistniejącego turnieju
EXEC KandydaciNaMVP @turniejid = 10;
GO

-- ----------------------------------------------------------
-- PROCEDURA TransferGracza
-- Poprawny transfer: gracz 4 zostaje trenerem w drużynie 1 w splicie 101
-- Procedura zamknie poprzedni okres i doda nowy wpis.
EXEC TransferGracza @graczid = 4, @nowadruzyna = 1, @sezonid = 101, @rola = 'Trener';
GO

-- Historia zatrudnienia gracza 4 po transferze
SELECT *
FROM Druzyny_gracza
WHERE Gracz_id = 4
ORDER BY Data_dolaczenia;

GO

-- Transfer wywołujący błąd, próba ponownego przypisania gracza 1
-- do drużyny 1 w splicie 101. Przez to, że wiersz z takim kluczem głównym już istnieje,
-- to zadziała blok TRY CATCH, ROLLBACK i komunikat o błędzie
EXEC TransferGracza @graczid = 1, @nowadruzyna = 1, @sezonid = 101, @rola = 'Midlaner';
GO

-- ----------------------------------------------------------
-- WYZWALACZ WalidacjaDanychGracza(z kursorem)
-- Próba zapisu ujemnych statystyk wypisuje powód,
-- wykonuje ROLLBACK i zgłasza błąd
BEGIN TRY
    INSERT INTO Statystyki_gracza_z_gry
        (Gracz_id, Gry_ID_gry, Champion_gracza, Champion_zbanowany, Zabojstwa, Smierci, Asysty, Zdobyty_zloto)
    VALUES (2, 12, 'Gragas', 'Ahri', -5, -1, -3, 10000);
END TRY
BEGIN CATCH
    PRINT 'Error: ' + ERROR_MESSAGE();
END CATCH
GO

-- Próba zagrania zbanowanym przez siebie championem, wyzwalacz odrzuca
BEGIN TRY
    INSERT INTO Statystyki_gracza_z_gry
        (Gracz_id, Gry_ID_gry, Champion_gracza, Champion_zbanowany, Zabojstwa, Smierci, Asysty, Zdobyty_zloto)
    VALUES (2, 12, 'Gragas', 'Gragas', 3, 1, 3, 10000);
END TRY
BEGIN CATCH
    PRINT 'Error: ' + ERROR_MESSAGE();
END CATCH
GO

-- ---------------------------------------------------------------------
-- WYZWALACZ PrzeliczMecz
-- Mecz 2 ma na razie tylko jedną zapisaną grę (gra 20)
-- Dopiszę drugą grę i sprawdzę, czy wyzwalacz
-- automatycznie przeliczy wynik meczu na podstawie tabeli Gry

-- stan przed dopisaniem gry
SELECT id, Wynik_druzyny_1, Wynik_druzyny_2 FROM Mecze WHERE id = 2;
GO

-- dopisanie nowej gry
INSERT INTO Gry (ID_gry, Mecze_id, Nr_gry, Zwycieska_druzyna) VALUES (21, 2, 2, 5);
GO

-- stan po dopisaniu gry
SELECT id, Wynik_druzyny_1, Wynik_druzyny_2 FROM Mecze WHERE id = 2;
GO

