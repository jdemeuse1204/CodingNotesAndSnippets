using System;
using System.Collections.Concurrent;
using System.Collections.Generic;
using System.Data;
using System.Data.OleDb;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ConsoleApp1
{
    public class ExcelFileReader
    {
        private readonly string fileNameAndPath;

        public readonly ConcurrentStack<int> RowNumbersRead;

        public ExcelFileReader(string fileNameAndPath)
        {
            this.fileNameAndPath = fileNameAndPath;
            this.RowNumbersRead = new ConcurrentStack<int>();
        }

        public async Task<int[]> ReadAsync(string sheetName, Action<OleDbDataReader, int> readRowCallBack, int readerCount = 1)
        {
            var tasks = new List<Task<int>>();
            for (var i = 0; i < readerCount; i++)
            {
                var start = (i + 1);
                tasks.Add(Task.Run(() =>
                {
                    return this.ReadSheet(sheetName, readRowCallBack, readerCount, start);
                }));
            }

            return await Task.WhenAll(tasks);
        }

        private int ReadSheet(string sheetName, Action<OleDbDataReader, int> readRowCallBack, int rowReadOffset, int start)
        {
            using (var connection = new OleDbConnection($@"Provider=Microsoft.ACE.OLEDB.12.0;Data Source={fileNameAndPath};Mode=Read;Extended Properties='Excel 14.0;HDR=YES';Jet OLEDB:Engine Type=37;"))
            {
                if (connection.State != ConnectionState.Open) { connection.Open(); }

                var sql = $"Select * From [{sheetName}$]";

                using (var command = new OleDbCommand(sql, connection))
                using (var reader = command.ExecuteReader(CommandBehavior.CloseConnection))
                {
                    var rowNumber = 0;
                    var rowsRead = 0;

                    var nextRowToRead = start;

                    while (reader.Read())
                    {
                        rowNumber++;

                        if (nextRowToRead != rowNumber)
                        {
                            continue;
                        }

                        this.RowNumbersRead.Push(rowNumber);

                        rowsRead++;
                        nextRowToRead += rowReadOffset;
                        readRowCallBack(reader, rowNumber);
                    }

                    return rowsRead;
                }
            }
        }
    }
}
