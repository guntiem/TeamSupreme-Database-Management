-- Query 1: Find all accessible Entities of UserID = 6

SELECT DISTINCT U.UserID, U.Name, COALESCE(UP.EntityID, GP.EntityID) AS EntityID
FROM User U
LEFT JOIN Party P ON U.UserID = P.UserID
LEFT JOIN UserPermissions UP ON U.UserID = UP.UserID
LEFT JOIN GroupPermissions GP ON P.GroupID = GP.GroupID
WHERE U.UserID = 6;

-- Query 2: Find all Users part of Multiple Groups

SELECT U.UserID, U.Name
FROM User U
LEFT JOIN Party P ON U.UserID = P.UserID
GROUP BY U.UserID, U.Name
HAVING COUNT(P.GroupID) > 1;

-- Query 3: Find all Users that have UserPermission and GroupPermission on the same Entity

SELECT UserID, Name, UserEntityID AS EntityID
FROM (
    SELECT DISTINCT U.UserID, U.Name, UP.EntityID AS UserEntityID, GP.EntityID AS GroupEntityID
    FROM User U
    LEFT JOIN Party P ON U.UserID = P.UserID
    LEFT JOIN UserPermissions UP ON U.UserID = UP.UserID
    LEFT JOIN GroupPermissions GP ON P.GroupID = GP.GroupID
) A
WHERE UserEntityID = GroupEntityID;

-- Query 4: Find all Users that have access to View ('SELECT') EntityID = 5

SELECT DISTINCT A.UserID, U.Name
FROM (
    SELECT UserID FROM Entity E
    LEFT JOIN UserPermissions UP ON E.EntityID = UP.EntityID AND UP.PermissionType = 'SELECT'
    WHERE E.EntityID = 5
    UNION
    SELECT P.UserID FROM Entity E
    LEFT JOIN GroupPermissions GP ON E.EntityID = GP.EntityID AND GP.PermissionType = 'SELECT'
    LEFT JOIN Party P ON GP.GroupID = P.GroupID
    WHERE E.EntityID = 5
) A
LEFT JOIN User U ON A.UserID = U.UserID;

-- Query 5: Find all Users that do not have access to View any Entities

SELECT *
FROM User 
WHERE UserID NOT IN (
    SELECT UserID FROM Entity E
    LEFT JOIN UserPermissions UP ON E.EntityID = UP.EntityID AND UP.PermissionType = 'SELECT'
    WHERE UP.UserID IS NOT NULL
    UNION
    SELECT P.UserID FROM Entity E
    LEFT JOIN GroupPermissions GP ON E.EntityID = GP.EntityID AND NameUserIDD AND GP.PermissionType = 'SELECT'
    LEFT JOIN Party P ON GP.GroupID = P.GroupID
    WHERE P.UserID IS NOT NULL
);

SHOW ERRORS;
