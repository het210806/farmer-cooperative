CREATE SCHEMA IF NOT EXISTS fccss; 
SET search_path TO fccss; 

-- FARMER TABLE 
CREATE TABLE farmer ( 
farmerid INT NOT NULL, 
aadhaarno CHAR(12) NOT NULL, 
name VARCHAR(100) NOT NULL, 
phone VARCHAR(15), 
village VARCHAR(100), 
status VARCHAR(20), 
PRIMARY KEY (farmerid), 
UNIQUE (aadhaarno) 
);

-- COOPERATIVE_SOCIETY TABLE
CREATE TABLE cooperative_society ( 
coopid INT NOT NULL, 
name VARCHAR(150) NOT NULL, 
regno VARCHAR(50) NOT NULL, 
district VARCHAR(100), 
state VARCHAR(100), 
phone VARCHAR(15), 
PRIMARY KEY (coopid), 
UNIQUE (regno) 
);

-- LOGISTIC_PARTNER TABLE
CREATE TABLE logistics_partner ( 
partnerid INT NOT NULL, 
name VARCHAR(150) NOT NULL, 
serviceregion VARCHAR(200), 
gstin VARCHAR(15), 
phone VARCHAR(15), 
PRIMARY KEY (partnerid) 
);

--  BUYER TABLE
CREATE TABLE buyer ( 
buyerid INT NOT NULL, 
bizname VARCHAR(150) NOT NULL, 
type VARCHAR(50), 
email VARCHAR(150), 
gstin VARCHAR(15), 
PRIMARY KEY (buyerid) 
);

--SUBSIDY_SCHEME TABLE
CREATE TABLE subsidy_scheme (
    schemeid INT NOT NULL,
    schemename VARCHAR(150),
    type VARCHAR(50),
    startdate DATE,
    eligiblecrop VARCHAR(100),
    PRIMARY KEY (schemeid)
);

-- FARMER_MEMBERSHIP TABLE
CREATE TABLE farmer_membership ( 
memberid INT NOT NULL, 
farmerid INT NOT NULL, 
coopid INT NOT NULL, 
enrolldate DATE, 
memberfee DECIMAL(10,2), 
status VARCHAR(20), 
PRIMARY KEY (memberid), 
FOREIGN KEY (farmerid) REFERENCES farmer(farmerid) 
ON UPDATE CASCADE ON DELETE CASCADE, 
FOREIGN KEY (coopid) REFERENCES cooperative_society(coopid) 
ON UPDATE CASCADE ON DELETE CASCADE 
);

-- CROP_LOT TABLE
CREATE TABLE crop_lot ( 
lotid INT NOT NULL, 
farmerid INT NOT NULL, 
cropname VARCHAR(100) NOT NULL, 
variety VARCHAR(100), 
qtykg DECIMAL(12,2) NOT NULL, 
harvestdate DATE, 
season VARCHAR(50), 
PRIMARY KEY (lotid), 
FOREIGN KEY (farmerid) REFERENCES farmer(farmerid) 
ON UPDATE CASCADE ON DELETE CASCADE 
); 

-- WAREHOUSE TABLE
CREATE TABLE warehouse ( 
warehouseid INT NOT NULL, 
coopid INT NOT NULL, 
location VARCHAR(200), 
capacitykg DECIMAL(14,2), 
address VARCHAR(300), 
PRIMARY KEY (warehouseid), 
FOREIGN KEY (coopid) REFERENCES cooperative_society(coopid) 
ON UPDATE CASCADE ON DELETE CASCADE 
); 

-- VEHICLE TABLE
CREATE TABLE vehicle ( 
vehicleid INT NOT NULL, 
partnerid INT NOT NULL, 
vehicletype VARCHAR(50), 
capacitykg DECIMAL(12,2), 
regno VARCHAR(20) NOT NULL, 
PRIMARY KEY (vehicleid), 
UNIQUE (regno), 
FOREIGN KEY (partnerid) REFERENCES logistics_partner(partnerid)
ON UPDATE CASCADE ON DELETE CASCADE 
); 

-- CROP_PRICE TABLE
CREATE TABLE crop_price (
    priceid INT NOT NULL,
    coopid INT NOT NULL,
    cropname VARCHAR(100),
    grade VARCHAR(10),
    priceperkg DECIMAL(10,2),
    effectivedate DATE,
    settleadmin VARCHAR(100),
    PRIMARY KEY (priceid),
    FOREIGN KEY (coopid) REFERENCES cooperative_society(coopid)
    ON UPDATE CASCADE ON DELETE CASCADE
);

-- PROCUREMENT TABLE
CREATE TABLE procurement ( 
procureid INT NOT NULL, 
lotid INT NOT NULL, 
coopid INT NOT NULL, 
procuredate DATE NOT NULL, 
qtykg DECIMAL(12,2) NOT NULL, 
priceperkg DECIMAL(10,2) NOT NULL, 
totalamt DECIMAL(14,2) NOT NULL, 
PRIMARY KEY (procureid), 
FOREIGN KEY (lotid) REFERENCES crop_lot(lotid) 
ON UPDATE CASCADE ON DELETE CASCADE, 
FOREIGN KEY (coopid) REFERENCES cooperative_society(coopid) 
ON UPDATE CASCADE ON DELETE CASCADE 
); 

-- QUALITY_CHECK TABLE
CREATE TABLE quality_check ( 
qcid INT NOT NULL, 
lotid INT NOT NULL, 
grade VARCHAR(10) NOT NULL, 
moisturepct DECIMAL(5,2), 
inspector VARCHAR(100), 
qcdate DATE NOT NULL, 
PRIMARY KEY (qcid), 
FOREIGN KEY (lotid) REFERENCES crop_lot(lotid) 
ON UPDATE CASCADE ON DELETE CASCADE 
);

-- FARMER_PAYMENT TABLE
CREATE TABLE farmer_payment ( 
paymentid INT NOT NULL, 
procureid INT NOT NULL, 
farmerid INT NOT NULL, 
grossamt DECIMAL(14,2) NOT NULL, 
deductions DECIMAL(14,2), 
netpayable DECIMAL(14,2) NOT NULL, 
paydate DATE NOT NULL, 
mode VARCHAR(30), 
PRIMARY KEY (paymentid), 
FOREIGN KEY (procureid) REFERENCES procurement(procureid)
ON UPDATE CASCADE ON DELETE CASCADE, 
FOREIGN KEY (farmerid) REFERENCES farmer(farmerid) 
ON UPDATE CASCADE ON DELETE CASCADE 
);

-- INVENTORY TABLE
CREATE TABLE inventory ( 
inventoryid INT NOT NULL, 
warehouseid INT NOT NULL, 
procureid INT NOT NULL, 
cropname VARCHAR(100) NOT NULL, 
grade VARCHAR(10), 
qtyavailkg DECIMAL(12,2) NOT NULL, 
receiveddate DATE, 
shelfdate DATE, 
PRIMARY KEY (inventoryid), 
FOREIGN KEY (warehouseid) REFERENCES warehouse(warehouseid) 
ON UPDATE CASCADE ON DELETE CASCADE, 
FOREIGN KEY (procureid) REFERENCES procurement(procureid) 
ON UPDATE CASCADE ON DELETE CASCADE 
);

-- ORDER_HEADER TABLE
CREATE TABLE order_header ( 
orderid INT NOT NULL, 
buyerid INT NOT NULL, 
orderdate DATE NOT NULL, 
status VARCHAR(30), 
delivaddr VARCHAR(300), 
qtyordered DECIMAL(12,2), 
PRIMARY KEY (orderid), 
FOREIGN KEY (buyerid) REFERENCES buyer(buyerid) 
ON UPDATE CASCADE ON DELETE CASCADE 
); 

-- ORDER_ITEM TABLE
CREATE TABLE order_item ( 
orderitemid INT NOT NULL, 
orderid INT NOT NULL, 
inventoryid INT NOT NULL, 
qtykg DECIMAL(12,2) NOT NULL, 
priceperkg DECIMAL(10,2) NOT NULL, 
totalamt DECIMAL(14,2) NOT NULL, 
PRIMARY KEY (orderitemid), 
FOREIGN KEY (orderid) REFERENCES order_header(orderid) 
ON UPDATE CASCADE ON DELETE CASCADE, 
FOREIGN KEY (inventoryid) REFERENCES inventory(inventoryid) 
ON UPDATE CASCADE ON DELETE CASCADE 
);

-- TRANSPORT_JOB TABLE
CREATE TABLE transport_job ( 
jobid INT NOT NULL, 
vehicleid INT NOT NULL, 
procureid INT NOT NULL, 
orderid INT, 
scheddate DATE, 
srcaddr VARCHAR(300), 
amtpayable DECIMAL(14,2), 
status VARCHAR(30), 
PRIMARY KEY (jobid), 
FOREIGN KEY (vehicleid) REFERENCES vehicle(vehicleid) 
ON UPDATE CASCADE ON DELETE CASCADE, 
FOREIGN KEY (procureid) REFERENCES procurement(procureid) 
ON UPDATE CASCADE ON DELETE CASCADE, 
FOREIGN KEY (orderid) REFERENCES order_header(orderid) 
ON UPDATE CASCADE ON DELETE SET NULL 
);

-- SUBSIDY_DISBURSEMENT TABLE
CREATE TABLE subsidy_disbursement (
    disburseid INT NOT NULL,
    schemeid INT NOT NULL,
    farmerid INT NOT NULL,
    procureid INT NOT NULL,
    amtdisbursed DECIMAL(14,2),
    disdate DATE,
    refno VARCHAR(100),
    status VARCHAR(30),
    PRIMARY KEY (disburseid),
    FOREIGN KEY (schemeid) REFERENCES subsidy_scheme(schemeid)
    ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (farmerid) REFERENCES farmer(farmerid)
    ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (procureid) REFERENCES procurement(procureid)
    ON UPDATE CASCADE ON DELETE CASCADE
);
