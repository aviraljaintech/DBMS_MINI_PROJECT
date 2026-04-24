# 🌍 Pollution Monitoring Database System

This is a complete mini-project for a DBMS college subject. It simulates a real-world pollution monitoring system where data is collected from environmental sensors and stored in a database for analysis.

## 📂 Project Structure
```text
/pollution-monitoring-db
  ├── backend/           # Node.js REST API
  │   ├── package.json
  │   └── server.js      # Express server & DB connection
  ├── database/          # MySQL Database Schema & Dummy Data
  │   └── schema.sql
  ├── frontend/          # HTML, CSS, Vanilla JS Dashboard
  │   ├── index.html
  │   ├── style.css
  │   └── app.js
  └── README.md          # Project Documentation (You are here)
```

## 🛠️ Tech Stack
- **Database:** MySQL
- **Backend:** Node.js, Express.js, `mysql2` package
- **Frontend:** HTML5, CSS3, Vanilla JavaScript, Chart.js (for graphs)

---

## 📊 Database Design (ER Diagram Explanation)

The database follows the **3rd Normal Form (3NF)** to avoid redundancy and ensure data integrity.

### Entities & Relationships:
1. **Locations (1) --- (N) Sensors**: One location can have multiple sensors installed.
2. **Sensors (1) --- (N) Readings**: A single sensor can generate multiple pollution readings over time.
3. **Pollutants (1) --- (N) Readings**: A specific pollutant type (like CO2, PM2.5) is associated with multiple readings.
4. **Readings (1) --- (N) Alerts**: A reading that exceeds safe limits triggers an alert.

### Tables Overview:
- `Locations`: Stores details of cities and areas where sensors are deployed.
- `Sensors`: Details of hardware devices and their installation locations.
- `Pollutants`: Master table of pollutants (CO2, NO2, PM2.5, etc.) and their statutory safe limits.
- `Readings`: The core transaction table holding the actual pollution values mapped to sensors, pollutants, and timestamps.
- `Alerts`: Generated when a reading exceeds the `safe_limit` defined in the Pollutants table.
- `Users`: System administrators and analysts (optional).

---

## 🚀 How to Run the Project

### 1. Setup the Database
1. Ensure you have **XAMPP/WAMP/MySQL Workbench** installed and running.
2. Open your MySQL client.
3. Run the complete SQL script provided in `database/schema.sql`.
   - *This will automatically create the database `pollution_monitoring`, create all tables, and insert dummy data.*

### 2. Run the Backend
1. Open a terminal and navigate to the `backend` folder:
   ```bash
   cd pollution-monitoring-db/backend
   ```
2. Install dependencies:
   ```bash
   npm install
   ```
3. Update MySQL credentials in `server.js` (around line 12) if your local MySQL uses a password (default is usually empty `''` for XAMPP).
4. Start the server:
   ```bash
   npm start
   ```
   *(The server will run on `http://localhost:3000`)*

### 3. Run the Frontend
1. Navigate to the `frontend` folder.
2. Open `index.html` directly in your web browser (or use VS Code Live Server).
3. The dashboard will automatically fetch data from your Node.js backend!

---

## 💡 Key SQL Queries Included (Great for Viva)
You can find these queries at the bottom of the `schema.sql` file. They cover:
1. **Find highest pollution area:** Uses `JOIN` and `ORDER BY` with `LIMIT 1`.
2. **Average pollution per day/location:** Uses `GROUP BY` and `AVG()` aggregate functions.
3. **Sensors exceeding limits:** Compares `Readings.value > Pollutants.safe_limit` using `JOIN`.
4. **Complex Joins:** Fetching alerts with location names and reading values.

---

## 📌 Features Included
- **Normalised DB:** 3NF compliant schema with proper Foreign Keys and `ON DELETE CASCADE` constraints.
- **RESTful API:** Clean Node.js backend serving JSON data to the frontend.
- **Real-time Charting:** Line chart implemented using Chart.js to visualize pollution trends dynamically.
- **Alert System:** Logic is handled in both SQL (dummy data) and the backend POST API (dynamic alert generation when a new high reading is submitted).
