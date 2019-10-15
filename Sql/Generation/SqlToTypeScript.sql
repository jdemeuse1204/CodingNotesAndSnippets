  With [Schema] As (
SELECT
Case 
	When IS_NULLABLE = 'YES' And 
		(DATA_TYPE = 'char' Or 
		DATA_TYPE = 'varchar' OR
		DATA_TYPE = 'text') Then 0
	When IS_NULLABLE = 'YES' Then 1
	Else 0
End As [IsNullable],
Case
	When DATA_TYPE = 'char' Or DATA_TYPE = 'varchar' Then 'string'
	When DATA_TYPE = 'money' Or DATA_TYPE = 'real' Then 'number'
	When DATA_TYPE = 'date' Or DATA_TYPE = 'datetime' Or DATA_TYPE = 'smalldatetime' OR DATA_TYPE = 'datetime2' Then 'Date'
	When DATA_TYPE = 'datetimeoffset' Then 'Date'
	When DATA_TYPE = 'uniqueidentifier' Then 'string'
	When DATA_TYPE = 'text' Then 'string'
	When DATA_TYPE = 'time' Then 'Date'
	When DATA_TYPE = 'int' OR DATA_TYPE = 'float'  Then 'number'
	Else DATA_TYPE
End As [Type],
COLUMN_NAME
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = N'SomeTable'
And TABLE_SCHEMA = N'dbo')

Select 
	[COLUMN_NAME] + IIF([IsNullable] = 1, '?', '') + ': ' + [Type] + ';'
From [Schema]
