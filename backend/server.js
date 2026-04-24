const express = require('express');
const cors = require('cors');
const mysql = require('mysql2');

const app = express();
app.use(cors());
app.use(express.json());

// Database connection setup
const db = mysql.createConnection({
  host: 'localhost',
  user: 'root',      // Replace with your MySQL username
  password: '',      // Replace with your MySQL password
  database: 'pollution_monitoring'
});

db.connect((err) => {
  if (err) {
    console.error('Error connecting to MySQL database: ', err);
    return;
  }
  console.log('Connected to MySQL database successfully.');
});

// =======================
// REST APIs
// =======================

// 1. Get all recent readings with location and pollutant details
app.get('/api/readings', (req, res) => {
  const query = `
    SELECT r.reading_id, l.name as location, l.city, p.name as pollutant, r.value, p.unit, r.timestamp
    FROM Readings r
    JOIN Sensors s ON r.sensor_id = s.sensor_id
    JOIN Locations l ON s.location_id = l.location_id
    JOIN Pollutants p ON r.pollutant_id = p.pollutant_id
    ORDER BY r.timestamp DESC
    LIMIT 50
  `;
  db.query(query, (err, results) => {
    if (err) return res.status(500).json({ error: err.message });
    res.json(results);
  });
});

// 2. Get active alerts
app.get('/api/alerts', (req, res) => {
  const query = `
    SELECT a.alert_id, a.message, a.alert_time, l.name as location
    FROM Alerts a
    JOIN Readings r ON a.reading_id = r.reading_id
    JOIN Sensors s ON r.sensor_id = s.sensor_id
    JOIN Locations l ON s.location_id = l.location_id
    WHERE a.status = 'ACTIVE'
    ORDER BY a.alert_time DESC
  `;
  db.query(query, (err, results) => {
    if (err) return res.status(500).json({ error: err.message });
    res.json(results);
  });
});

// 3. Add a new reading (simulate real-time data ingestion from sensors)
app.post('/api/readings', (req, res) => {
  const { sensor_id, pollutant_id, value } = req.body;
  
  const query = `INSERT INTO Readings (sensor_id, pollutant_id, value) VALUES (?, ?, ?)`;
  db.query(query, [sensor_id, pollutant_id, value], (err, result) => {
    if (err) return res.status(500).json({ error: err.message });
    
    // Check if value exceeds safe limit to generate an alert
    const checkLimitQuery = `SELECT safe_limit FROM Pollutants WHERE pollutant_id = ?`;
    db.query(checkLimitQuery, [pollutant_id], (limitErr, limitResults) => {
      if (!limitErr && limitResults.length > 0) {
        if (value > limitResults[0].safe_limit) {
          const alertMsg = `Pollution level exceeded safe limit! Value recorded: ${value}`;
          const alertQuery = `INSERT INTO Alerts (reading_id, message) VALUES (?, ?)`;
          db.query(alertQuery, [result.insertId, alertMsg]);
        }
      }
    });

    res.status(201).json({ message: 'Reading added successfully', reading_id: result.insertId });
  });
});

// 4. Get locations for optional filtering
app.get('/api/locations', (req, res) => {
  db.query('SELECT * FROM Locations', (err, results) => {
    if (err) return res.status(500).json({ error: err.message });
    res.json(results);
  });
});

const PORT = 3000;
app.listen(PORT, () => {
  console.log(`Server is running on http://localhost:${PORT}`);
});
