 With [Schema] As (
SELECT
Case 
	When IS_NULLABLE = 'YES' And 
		(DATA_TYPE = 'char' Or 
		DATA_TYPE = 'varchar' OR
		DATA_TYPE = 'text' OR
		DATA_TYPE = 'nvarchar') Then 0
	When IS_NULLABLE = 'YES' Then 1
	Else 0
End As [IsNullable],
Case
	When DATA_TYPE = 'char' Or DATA_TYPE = 'varchar' Then 'string'
	When DATA_TYPE = 'money' Or DATA_TYPE = 'real' Then 'decimal'
	When DATA_TYPE = 'date' Or DATA_TYPE = 'datetime' Or DATA_TYPE = 'smalldatetime' OR DATA_TYPE = 'datetime2' Then 'DateTime'
	When DATA_TYPE = 'datetimeoffset' Then 'DateTimeOffset'
	When DATA_TYPE = 'uniqueidentifier' Then 'Guid'
	When DATA_TYPE = 'text' Then 'string'
	When DATA_TYPE = 'time' Then 'TimeSpan'
	When DATA_TYPE = 'bit' Then 'bool'
	When DATA_TYPE = 'nvarchar' Then 'string'
	Else DATA_TYPE
End As [Type],
COLUMN_NAME
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = N'User'
And TABLE_SCHEMA = N'dbo')

Select 
'public ' + [Type] + IIF([IsNullable] = 1, '?', '') + ' ' + [COLUMN_NAME] + ' { get;set; }'
From [Schema]
