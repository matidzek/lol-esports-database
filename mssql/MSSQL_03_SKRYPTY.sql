-- Dla turnieju o zadanym ID wypisuje ranking kandydatów na MVP
-- 1. Instrukcja IF EXISTS sprawdza, czy turniej istnieje, a jeśli nie,
--      to wypisuje komunikat i kończy procedurę
-- 2. Otwiera KURSOR sumujący zabójstwa,śmierci i asysty każdego gracza
--      ze wszystkich meczów danego turnieju (złączenie tabel
--      Statystyki,Gry,Mecze,Gracz)
-- 3. Kursor pobiera kolejne wiersze i liczy
--      wskaźnik KDA = (zabójstwa + asysty) / śmierci (jeśli śmierci = 0,
--      to przyjmuje zabójstwa + asysty) i wypisuje pozycję rankingu

CREATE PROCEDURE KandydaciNaMVP
@turniejid INT
AS
BEGIN
SET NOCOUNT ON;
    IF NOT EXISTS (SELECT 1 FROM Turnieje WHERE ID = @turniejid)
    BEGIN
        PRINT 'Turniej o ID = ' + CAST(@turniejid AS VARCHAR(10)) + ' nie istnieje';
        RETURN;
    END

    DECLARE @nazwaTurnieju VARCHAR(128);
    SELECT @nazwaTurnieju = Nazwa FROM Turnieje WHERE ID = @turniejid;
    PRINT 'Kandydaci na MVP turnieju: ' + @nazwaTurnieju;

    DECLARE @nick VARCHAR(128);
    DECLARE @zabojstwa INT, @smierci INT, @asysty INT;
    DECLARE @kda DECIMAL(5,2);
    DECLARE @lp INT = 0;

    DECLARE Cur_Gracze CURSOR FOR
        SELECT g.nick, SUM(s.Zabojstwa), SUM(s.Smierci), SUM(s.Asysty)
        FROM Statystyki_gracza_z_gry s
        JOIN Gry   gr ON gr.ID_gry = s.Gry_ID_gry
        JOIN Mecze m  ON m.id = gr.Mecze_id
        JOIN Gracz g  ON g.id = s.Gracz_id
        WHERE m.Turnieje_ID = @turniejid
        GROUP BY g.nick
	ORDER BY CASE 
        	 WHEN SUM(s.Smierci) = 0 THEN CAST(SUM(s.Zabojstwa) + SUM(s.Asysty) AS DECIMAL(5,2))
                 ELSE CAST(SUM(s.Zabojstwa) + SUM(s.Asysty) AS DECIMAL(5,2)) / SUM(s.Smierci)
        END DESC;

    OPEN Cur_Gracze;
    FETCH NEXT FROM Cur_Gracze INTO @nick, @zabojstwa, @smierci, @asysty;
    WHILE @@FETCH_STATUS = 0
    BEGIN
        SET @lp = @lp + 1;
        IF @smierci = 0
            SET @kda = @zabojstwa + @asysty;
        ELSE
            SET @kda = CAST(@zabojstwa + @asysty AS DECIMAL(5,2)) / @smierci;
        PRINT CAST(@lp AS VARCHAR(10)) + '. ' + @nick + 'KDA = ' 
        + CAST(@zabojstwa AS VARCHAR(10)) + '/' + CAST(@smierci AS VARCHAR(10))
        + '/' + CAST(@asysty AS VARCHAR(10)) +
        '  (KDA = ' + CAST(@kda AS VARCHAR(10)) + ')';
        FETCH NEXT FROM Cur_Gracze INTO @nick, @zabojstwa, @smierci, @asysty;
    END
    CLOSE Cur_Gracze;
    DEALLOCATE Cur_Gracze;

    IF @lp = 0
        PRINT 'Brak zarejestrowanych statystyk dla tego turnieju';
END;

-- Obsługuje transfer gracza do nowej drużyny i dba o spójność historii
-- zatrudnienia w tabeli Druzyny_gracza
-- 1. Sprawdza, czy gracz istnieje. Jeśli nie, to RAISERROR i RETURN.
-- 2. Zamyka aktualnie otwarty okres zatrudnienia tam gdzie 
--      Data_opuszcenia IS NULL i wpisując dzisiejszą datę, a następnie
--      dodaje nowy wiersz nowego zatrudnienia również z dzisiejszą datą
-- 3. Gdy wystąpi błąd blok CATCH wykonuje ROLLBACK i wypisuje
--      komunikat 'Error: Błąd transferu'


CREATE PROCEDURE TransferGracza
@graczid INT,
@nowadruzyna INT,
@sezonid INT,
@rola VARCHAR(128) = 'Zawodnik'
AS
BEGIN
    SET NOCOUNT ON;
    IF NOT EXISTS (SELECT 1 FROM Gracz WHERE id = @graczid)
    BEGIN
        DECLARE @ErrorMsg VARCHAR(100);
        SET @ErrorMsg = 'Gracz o podanym ID ' + CAST(@graczid AS VARCHAR(10)) + ' nie istnieje';
        RAISERROR(@ErrorMsg, 16, 1);
        RETURN;
    END
    BEGIN TRY
        BEGIN TRANSACTION;
        UPDATE Druzyny_gracza
        SET Data_opuszcenia = CAST(GETDATE() AS DATE)
        WHERE Gracz_id = @graczid AND Data_opuszcenia IS NULL;
        INSERT INTO Druzyny_gracza
        (Gracz_id, Drużyny_id, Sezon_ID, Rola_w_druzynie, Data_dolaczenia, Data_opuszcenia)
        VALUES
        (@graczid, @nowadruzyna, @sezonid, @rola, CAST(GETDATE() AS DATE), NULL);
        COMMIT TRANSACTION;
        PRINT 'Transfer zapisany: gracz ' + CAST(@graczid AS VARCHAR(10)) +
              ' wędruje do drużyny: ' + CAST(@nowadruzyna AS VARCHAR(10)) +
              ' jako: ' + @rola;
    END TRY
    BEGIN CATCH
        ROLLBACK;
        PRINT 'Error: Błąd transferu';
    END CATCH
END;
GO

-- (Efektywniejszym by było stworzenie constraintów na encjach)
-- Pełni rolę walidacji danych i blokuje zapis ujemnych statystyk
-- ,i nie pozwala aby gracz grał championem, którego sam zbanował
-- 1. Instrukcja IF EXISTS sprawdza, czy w tabeli wstawionych wierszy
--      są wiersze łamiące którąkolwiek z reguł
-- 2. Jeśli tak, to otwiera KURSOR po błędnych wierszach i dla każdego
--      wypisuje czytelny komunikat
-- 3. Następnie wycofuje całą operację za pomocą ROLLBACK i rzuca
--      RAISERROR, aby zablokować niepoprawny zapis

CREATE TRIGGER WalidacjaDanychGracza
ON Statystyki_gracza_z_gry
FOR INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    IF EXISTS (
        SELECT 1 FROM inserted
        WHERE Zabojstwa < 0 OR Smierci < 0 OR Asysty < 0 OR Zdobyty_zloto < 0
        OR (Champion_zbanowany IS NOT NULL AND Champion_gracza = Champion_zbanowany)
    )
    BEGIN
        DECLARE @gid INT, @chg VARCHAR(128), @chb VARCHAR(128);
        DECLARE @zab INT, @sm INT, @as INT, @zl INT;
        DECLARE Cur_Bledy CURSOR FOR
            SELECT Gracz_id, Champion_gracza, Champion_zbanowany,
                   Zabojstwa, Smierci, Asysty, Zdobyty_zloto
            FROM inserted
            WHERE Zabojstwa < 0 OR Smierci < 0 OR Asysty < 0 OR Zdobyty_zloto < 0
            OR (Champion_zbanowany IS NOT NULL AND Champion_gracza = Champion_zbanowany);

        OPEN Cur_Bledy;
        FETCH NEXT FROM Cur_Bledy INTO @gid, @chg, @chb, @zab, @sm, @as, @zl;
        WHILE @@FETCH_STATUS = 0
        BEGIN
            IF @zab < 0 OR @sm < 0 OR @as < 0 OR @zl < 0
                PRINT 'Odrzucono gracza: ' + CAST(@gid AS VARCHAR(10)) +
                      ', ponieważ ma ujemne statystyki.';
            IF @chb IS NOT NULL AND @chg = @chb
                PRINT 'Odrzuconogracza: ' + CAST(@gid AS VARCHAR(10)) +
                      ', ponieważ gra zbanowanym przez siebie championem: ' + @chg;
            FETCH NEXT FROM Cur_Bledy INTO @gid, @chg, @chb, @zab, @sm, @as, @zl;
        END
        CLOSE Cur_Bledy;
        DEALLOCATE Cur_Bledy;
        ROLLBACK TRANSACTION;
        RAISERROR('Naruszono reguly walidacji danych - operacja wycofana', 10, 2);
    END
END;
GO

--   Po każdej zmianie w tabeli Gry przelicza wynik tylko dla meczów,
--   których dotyczyła zmiana. Dla każdego takiego meczu zlicza 
--   liczbę gier wygranych przez drużynę pierwszą i drugą.
CREATE TRIGGER PrzeliczMecz
ON Gry
FOR INSERT, DELETE
AS
BEGIN
SET NOCOUNT ON;
    UPDATE m SET m.Wynik_druzyny_1 =
             (SELECT COUNT(*) FROM Gry g
               WHERE g.Mecze_id = m.id AND g.Zwycieska_druzyna = m.Drużyna_1_id),
           m.Wynik_druzyny_2 =
             (SELECT COUNT(*) FROM Gry g
               WHERE g.Mecze_id = m.id AND g.Zwycieska_druzyna = m.Drużyna_2_id)
     FROM Mecze m
     WHERE m.id IN (SELECT Mecze_id FROM inserted) OR m.id IN (SELECT Mecze_id FROM deleted);
END;