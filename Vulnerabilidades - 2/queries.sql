-- Ver estrutura da tabela
USE DBGovDatabase;
GO
EXEC sp_help 'vw.VULNERABILIDADES_CONTAINER';

/* Dica: Rodar uma parte específica do arquivo
Selecionar apenas a parte da query que deseja executar com o mouse ou teclado.
Pressionar Ctrl+Shift+E ou clicar com o botão direito e escolher "Run Query".
O VS Code vai executar somente o trecho selecionado, ignorando o restante do arquivo.
*/

-- Ver dados em uma tabela
SELECT DISTINCT OWNINGGROUPMANAGER
FROM vw.VULNERABILIDADES_CONTAINER;

USE DBGovDatabase;

-- Consulta de Location
select distinct location FROM vw.VULNERABILIDADES_CONTAINER;

SELECT DISTINCT 
  RIGHT(location, CHARINDEX('/', REVERSE(location)) - 1) AS ultimo_segmento
FROM vw.VULNERABILIDADES_CONTAINER;


SELECT TOP 15 LOCATION, COUNT(LOCATION) AS quantidade
FROM vw.VULNERABILIDADES_CONTAINER 
WHERE OWNINGGROUPMANAGER IN ('Andre Silva','Fernando Ito','Joao Aloia','Rodrigo Bernardo','Thiago Trigo')
  AND ExperianVulnerabilitySeverity IN ('High', 'Critical')
  AND TRY_CONVERT(DATE, DueDate, 103) IS NOT NULL
  AND DATEDIFF(
        day,
        CAST(GETDATE() AS DATE),
        CONVERT(DATE, DueDate, 103)
      ) < 0    
GROUP BY LOCATION 
ORDER BY quantidade DESC;


USE DBGovDatabase;

SELECT TOP 15 LOCATION, COUNT(LOCATION) AS quantidade
FROM vw.VULNERABILIDADES_CONTAINER 
WHERE OWNINGGROUPMANAGER IN ($var_manager)
  AND ExperianVulnerabilitySeverity IN ('High', 'Critical')
  AND TRY_CONVERT(DATE, DueDate, 103) IS NOT NULL
  AND DATEDIFF(
        day,
        CAST(GETDATE() AS DATE),
        CONVERT(DATE, DueDate, 103)
      ) < 0    
GROUP BY LOCATION 
ORDER BY quantidade DESC;

USE DBGovDatabase;
SELECT 
    CLOUDACCOUNTID,
    CVE,    LOCATION,
    DETECTIONDNS,
    FORMAT(CONVERT(DATETIME, DUEDATE, 103), 'dd-MM-yyyy') AS ConvertedDate,

    --  (DUEDATE, 'dd-MM-yy') as date_due,
    DUEDATE,
    DATEDIFF(day, GETDATE(), TRY_CONVERT(DATE, DueDate, 103)) AS DaysUntilOverdue,
    EXPERIANVULNERABILITYSEVERITY,
    VULNERABILITYNAME,
    ENVIRONMENT,
    SOFTWAREFAMILY,
    OWNINGGROUPEMAIL,
    OWNINGGROUPMANAGER,
    VULNCONTACTGROUP
FROM vw.VULNERABILIDADES_CONTAINER
WHERE 
    ExperianVulnerabilitySeverity IN ('High', 'Critical')
    AND OWNINGGROUPMANAGER IN ('Andre Silva','Fernando Ito','Joao Aloia','Rodrigo Bernardo','Thiago Trigo')
    AND TRY_CONVERT(DATE, DueDate, 103) IS NOT NULL
    AND DATEDIFF(
      day,
      CAST(GETDATE() AS DATE),
      CONVERT(DATE, DueDate, 103)
    ) <= 30
ORDER BY DaysUntilOverdue;

USE DBGovDatabase;
SELECT 
    distinct CLOUDACCOUNTID
FROM vw.VULNERABILIDADES_CONTAINER
WHERE 
    ExperianVulnerabilitySeverity IN ('High', 'Critical')
    AND OWNINGGROUPMANAGER IN ('Andre Silva','Fernando Ito','Joao Aloia','Rodrigo Bernardo','Thiago Trigo')
    AND TRY_CONVERT(DATE, DueDate, 103) IS NOT NULL
    AND DATEDIFF(
      day,
      CAST(GETDATE() AS DATE),
      CONVERT(DATE, DueDate, 103)
    ) <= 30;

USE DBGovDatabase;
SELECT 
    CLOUDACCOUNTID,
    CVE,    LOCATION,
    DETECTIONDNS,
    FORMAT(CONVERT(DATETIME, DUEDATE, 103), 'dd-MM-yyyy') AS DueDate,
    DATEDIFF(day, GETDATE(), TRY_CONVERT(DATE, DueDate, 103)) AS DaysUntilOverdue,
    EXPERIANVULNERABILITYSEVERITY,
    VULNERABILITYNAME,
    ENVIRONMENT,
    SOFTWAREFAMILY,
    OWNINGGROUPEMAIL,
    OWNINGGROUPMANAGER,
    VULNCONTACTGROUP
FROM vw.VULNERABILIDADES_CONTAINER
WHERE 
    ExperianVulnerabilitySeverity IN ('High', 'Critical')
    AND OWNINGGROUPMANAGER IN ('Andre Silva','Fernando Ito','Joao Aloia','Rodrigo Bernardo','Thiago Trigo')
    AND TRY_CONVERT(DATE, DueDate, 103) IS NOT NULL
    AND DATEDIFF(
      day,
      CAST(GETDATE() AS DATE),
      CONVERT(DATE, DueDate, 103)
    ) <= 30
ORDER BY DaysUntilOverdue;