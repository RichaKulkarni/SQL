DECLARE @MyCursor CURSOR;
DECLARE @MyField VARCHAR(MAX);
DECLARE @sql NVARCHAR(MAX);
DECLARE @dStat NVARCHAR(MAX);

DECLARE @DbCursor CURSOR;
DECLARE @DbField VARCHAR(MAX);
DECLARE @tabsql NVARCHAR(MAX);
DECLARE @crsStatement NVARCHAR(MAX);
DECLARE @tabStatement NVARCHAR(MAX);

DECLARE @ActionCursor CURSOR;
DECLARE @TableField VARCHAR(MAX);
DECLARE @Table_Field VARCHAR(MAX);
DECLARE @Table_Field1 VARCHAR(MAX);
DECLARE @Table_Field2 VARCHAR(MAX);
DECLARE @Table_Field3 VARCHAR(MAX);
DECLARE @ActionStatement NVARCHAR(MAX);
DECLARE @ActionStatement1 NVARCHAR(MAX);
DECLARE @ActionStatement2 NVARCHAR(MAX);
DECLARE @ActionStatement3 NVARCHAR(MAX);
DECLARE @ColumnStatement NVARCHAR(MAX);

DECLARE @DelCursor CURSOR;
DECLARE @DelField VARCHAR(MAX);
DECLARE @DelStatement NVARCHAR(MAX);

BEGIN
	--Start with initial delete of all tables
	SET @DelCursor = CURSOR FOR
	select top 1000 [Table] from [MyDB].[dbo].[DeleteTables]   

	OPEN @DelCursor 
	FETCH NEXT FROM @DelCursor 
	INTO @DelField      

	WHILE @@FETCH_STATUS = 0
	 BEGIN
		 SET @DelStatement = N'DELETE FROM [MyDB].[dbo].[' +@DelField+ '];';
		 print @DelStatement;
		 exec sp_executesql @DelStatement;
      
	 FETCH NEXT FROM @DelCursor
	 INTO @DelField
	 END;
	 CLOSE @DelCursor;
     DEALLOCATE @DelCursor;  
	-- End intial deletion of tables
	
    SET @MyCursor = CURSOR FOR
    SELECT srvname FROM sys.sysservers WHERE srvname like 'LINKEDSERVER_%'
    
    OPEN @MyCursor 
    FETCH NEXT FROM @MyCursor 
    INTO @MyField

    WHILE @@FETCH_STATUS = 0
    BEGIN    
      --implement cursor to run through all tables within db
      set @crsStatement = N'DECLARE DbCursor CURSOR FOR SELECT name FROM [' + @MyField +'].master.sys.databases WHERE name IS NOT NULL AND name NOT IN(''msdb'', ''model'', ''tempdb'',''master'',''reportserver'',''reportservertempdb'');';
      exec sp_executesql @crsStatement

      OPEN DbCursor
      FETCH NEXT FROM DbCursor
      INTO @DbField
      
      WHILE @@FETCH_STATUS=0
      BEGIN
         BEGIN TRY
            --Iterate through Action table and to get table names we want
            SET @ActionCursor = CURSOR FOR
            select [Table] from [MyDB].[dbo].[Action]   

            OPEN @ActionCursor 
            FETCH NEXT FROM @ActionCursor 
            INTO @TableField

            WHILE @@FETCH_STATUS = 0
            BEGIN
               SET @Table_Field = @TableField;
               SET @Table_Field1 = @TableField;
               SET @Table_Field2 = @TableField;
               SET @Table_Field3 = @TableField;
               
               
               IF(@Table_Field3 = 'X')
                   BEGIN
                      SET @ActionStatement3 = N'IF EXISTS (SELECT * FROM [' +@MyField+ '].[' +@DbField+ '].sys.tables WHERE name = ''X'') INSERT INTO [MyDB].[dbo].[X] SELECT '''+@MyField+''','''+@DbField+''','''+@Table_Field3+''',* FROM [' +@MyField+ '].[' +@DbField+ '].[dbo].[X];';
                      print @ActionStatement3;
                      --list all column names of current LS.DB.TABLE
                      SET @ColumnStatement = N'SELECT c.name FROM [' +@MyField+ '].[' +@DbField+ '].sys.columns c, [' +@MyField+ '].[' +@DbField+ '].sys.tables t WHERE c.object_id = t.object_id AND t.name = ''' +@Table_Field+ ''';'
                      print @ColumnStatement;
                      BEGIN TRY
                         --exec sp_executesql @ColumnStatement;
                         exec sp_executesql @ActionStatement3;
                      END TRY
                      BEGIN CATCH
                         SELECT ERROR_MESSAGE() AS ErrorMessage
                      END CATCH;
                      print ' ';
                      SET @ActionStatement3 = NULL;
                      SET @ColumnStatement = NULL;
                   END;
                ELSE IF(@Table_Field3 = 'Y')
                   BEGIN
                      SET @ActionStatement3 = N'IF EXISTS (SELECT * FROM [' +@MyField+ '].[' +@DbField+ '].sys.tables WHERE name = ''Y'') INSERT INTO [MyDB].[dbo].[Y] SELECT '''+@MyField+''','''+@DbField+''','''+@Table_Field3+''',* FROM [' +@MyField+ '].[' +@DbField+ '].[dbo].[Y];';
                      print @ActionStatement3;
                      --list all column names of current LS.DB.TABLE
                      SET @ColumnStatement = N'SELECT c.name FROM [' +@MyField+ '].[' +@DbField+ '].sys.columns c, [' +@MyField+ '].[' +@DbField+ '].sys.tables t WHERE c.object_id = t.object_id AND t.name = ''' +@Table_Field+ ''';'
                      print @ColumnStatement;
                      BEGIN TRY
                         --exec sp_executesql @ColumnStatement;
                         exec sp_executesql @ActionStatement3;
                      END TRY
                      BEGIN CATCH
                         SELECT ERROR_MESSAGE() AS ErrorMessage
                      END CATCH;
                      print ' ';
                      SET @ActionStatement3 = NULL;
                      SET @ColumnStatement = NULL;
                   END;
                ELSE
                    BEGIN
                       print 'ELSE';
                    END;
               --Clear Values for Next Iteration
               SET @ActionStatement = NULL;
               SET @ActionStatement1 = NULL;
			   SET @ActionStatement2 = NULL;
			   SET @ActionStatement3 = NULL;
			   SET @Table_Field = NULL;
			   SET @Table_Field1 = NULL;
			   SET @Table_Field2 = NULL;
			   SET @Table_Field3 = NULL;
			   
			   print '*** TableField = ****'
			   print @TableField;
 
            FETCH NEXT FROM @ActionCursor 
            INTO @TableField 
            END; 

            CLOSE @ActionCursor;
            DEALLOCATE @ActionCursor;
            
         END TRY
         BEGIN CATCH
           SELECT ERROR_MESSAGE() AS ErrorMessage
         END CATCH
      FETCH NEXT FROM DbCursor
      INTO @DbField
      END;
      
      CLOSE DbCursor;
      DEALLOCATE DbCursor;
      
    FETCH NEXT FROM @MyCursor 
    INTO @MyField 
    END; 

    CLOSE @MyCursor ;
    DEALLOCATE @MyCursor;
END;
