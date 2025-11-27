
/*RFM-Analyse: Recency, Frequency, Monetary
Die RFM-Analyse unterteilt Kunden in Segmente basierend auf:
Recency (Wie recently haben sie gekauft?)
Frequency (Wie häufig haben sie gekauft?)
Monetary (Wie viel Geld haben sie ausgegeben?)
*/

WITH customer_stats AS (
SELECT
	Customer_ID,
	MAX(Date) as last_purchase,
	COUNT(Order_ID) as frequency,
	SUM(Unit_Price * Quantity - Discount_Amount) as monetary,
	DATEDIFF ((SELECT MAX(Date) FROM sales_report), MAX(Date)) as recency
FROM sales_report
GROUP BY Customer_ID
),
rfm_scores AS (
SELECT
	Customer_ID, 
	NTILE(5) OVER (ORDER BY recency DESC) as R,
	NTILE(5) OVER (ORDER BY frequency) as F,
	NTILE(5) OVER (ORDER BY monetary) as M
FROM customer_stats
)
SELECT
	CONCAT(R, F, M) as RFM_segment,
    CASE 
        WHEN CONCAT(R, F, M) IN ('555','554','545','544') THEN 'Champions'
        WHEN R IN (4,5) AND F IN (4,5) THEN 'Loyal Customers'
        WHEN R IN (4,5) AND M IN (4,5) THEN 'Big Spenders'
        ELSE 'Other'
    END as segment_name,
    COUNT(*) as customers_count,
    AVG(monetary) as avg_monetary
FROM rfm_scores 
JOIN customer_stats USING(Customer_ID)
GROUP BY CONCAT(R, F, M), segment_name
ORDER BY customers_count DESC;

/* In Power BI können wir folgende Diagrammen basteln:
Kreisdiagramm - Verteilung der Kundensegmente
Karten - regionale Verteilung der Top-Segmente
KPIs - Gesamtkunden, Champions-Anteil, durchschnittlicher Kundenwert
*/

#Analysis of seasonality and temporal patterns

SELECT
    DAYNAME(Date) as day_of_week,
    MONTHNAME(Date) as month,
    Device_Type,
    COUNT(*) as orders,
	AVG(Unit_Price * Quantity - Discount_Amount) as avg_order_value,
    AVG (Session_Duration_Minutes) as avg_session_duration,
    AVG(Customer_Rating) as avg_rating
FROM sales_report
GROUP BY 
    DAYNAME(Date), MONTHNAME(Date), Device_Type
ORDER BY 
    FIELD(day_of_week, 'Monday','Tuesday','Wednesday','Thursday','Friday','Saturday','Sunday'),
    month;   

#More details for Power BI visualisation
SELECT
    Date,
    DAYNAME(Date) as day_of_week,
    DAYOFWEEK(Date) as day_number,
    MONTHNAME(Date) as month,
    MONTH(Date) as month_number,
    Device_Type,
    Product_Category_Name,
    City_Name,
    Unit_Price * Quantity - Discount_Amount as order_value,
    Session_Duration_Minutes,
    Customer_Rating,
    Is_Returning_Customer
FROM sales_report; 

/* Was wir genau in Power BI sehen werden:

 -Deutliche Spitzen und Einbrüche nach Wochentagen
 -Saisontrends und monatliche Schwankungen
 -Unterschiede im Nutzerverhalten zwischen verschiedenen Gerätetypen
 -Zusammenhänge zwischen Sitzungsdauer und Bestellwert
 -Regionale Muster nach Städten
 */
 
 # Device funnel analysis
 WITH device_funnel AS (
    SELECT
        Device_Type,
        COUNT(*) as sessions,
        COUNT(DISTINCT CASE WHEN Pages_Viewed >= 3 THEN Order_ID END) as engaged_sessions,
        COUNT(DISTINCT Order_ID) as purchases,
        SUM(Unit_Price * Quantity - Discount_Amount) as revenue
    FROM sales_report
    GROUP BY Device_Type
)
SELECT
    Device_Type,
    sessions,
    engaged_sessions,
    purchases,
    revenue,
    ROUND(engaged_sessions * 100.0 / sessions, 2) as engagement_rate
FROM device_funnel
ORDER BY engagement_rate DESC;