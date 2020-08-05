/** This gives  a count of the objects in the database 
    it avoids getting most things from the data dictionary 
    Dave Babler*/


SELECT COUNT(*) as [Number of this type of object], type_desc 
FROM sys.objects 
WHERE type NOT IN ('IT', 'S')
GROUP BY type_desc
ORDER BY type_desc;


--to get everything for the table.
SELECT *
FROM sys.objects
WHERE type NOT IN ('IT', 'S')
ORDER BY type_desc;