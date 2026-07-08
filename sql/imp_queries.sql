-- Query 1: Transport Jobs with Vehicle & Partner Details
SELECT
    tj.JobID            AS "Job ID",
    lp.Name             AS "Partner Name",
    vh.VehicleType      AS "Vehicle Type",
    vh.RegNo            AS "Registration No",
    vh.CapacityKg       AS "Capacity (kg)",
    tj.SchedDate        AS "Scheduled Date",
    tj.Status           AS "Job Status",
    tj.AmtPayable       AS "Amount Payable"
FROM transport_job tj
JOIN vehicle vh
    ON tj.VehicleID = vh.VehicleID
JOIN logistics_partner lp
    ON vh.PartnerID = lp.PartnerID
ORDER BY tj.SchedDate DESC;

-- Query 2: Total Subsidy per Scheme with Disbursement Count
SELECT
    ss.SchemeID                 AS "Scheme ID",
    ss.SchemeName               AS "Scheme Name",
    ss.Type                     AS "Scheme Type",
    ss.EligibleCrop             AS "Eligible Crop",
    COUNT(DISTINCT sd.FarmerID) AS "Farmers Benefited",
    SUM(sd.AmtDisbursed)        AS "Total Disbursed (₹)"
FROM subsidy_scheme ss
LEFT JOIN subsidy_disbursement sd
    ON ss.SchemeID = sd.SchemeID
GROUP BY
    ss.SchemeID,
    ss.SchemeName,
    ss.Type,
    ss.EligibleCrop
ORDER BY
    SUM(sd.AmtDisbursed) DESC;

-- Query 3: Current Stock Available in Each Warehouse
SELECT
    wh.WarehouseID      AS "Warehouse ID",
    wh.Location         AS "Location",
    cs.Name             AS "Cooperative Name",
    inv.CropName        AS "Crop Name",
    inv.Grade           AS "Grade",
    SUM(inv.QtyAvailKg) AS "Total Stock (kg)"
FROM warehouse wh
JOIN cooperative_society cs
    ON wh.CoopID = cs.CoopID
LEFT JOIN inventory inv
    ON wh.WarehouseID = inv.WarehouseID
GROUP BY
    wh.WarehouseID,
    wh.Location,
    cs.Name,
    inv.CropName,
    inv.Grade
ORDER BY
    SUM(inv.QtyAvailKg) DESC;
