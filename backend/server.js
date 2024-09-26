const express = require('express');
const multer = require('multer');
const { Pool } = require('pg');
const app = express();
const cors = require('cors');

app.use(cors());
const port = 3000;
app.use(express.json());

// Set up multer storage to store files in memory
const storage = multer.memoryStorage();
const upload = multer({ storage: storage });

// Postgres SQL Pool Setup
const pool = new Pool({
  host: '34.71.87.187',
  port: 5432,
  database: 'datagovernance',
  user: 'postgres',
  password: 'India@5555',
});

//Endpoint For storing the Parking Owner Details
app.post('/parking_system_api/upload_parking_owner_details', upload.single('licence_file'), async (req, res) => {
  const { name, email, mobile, gender, group_name, parking_area, address, qr_image } = req.body;

  // Check if the file is provided
  const licenceFile = req.file ? req.file.buffer : null;

  try {
    const result = await pool.query(
      'INSERT INTO parking_system_owner_details (name, email, mobile, gender, group_name, parking_area, address, qr_image, file_data) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9) RETURNING id',
      [name, email, mobile, gender, group_name, parking_area, address, qr_image, licenceFile]
    );
    res.json({ success: true, message: 'User registered successfully', id: result.rows[0].id });
  } catch (err) {
    console.error(err);
    res.status(500).json({ success: false, message: 'Error uploading profile' });
  }
});

// Endpoint to store coordinator details
app.post('/parking_system_api/coordinator_detail_register', async (req, res) => {
  const { name, number, email, parkingArea, groupName, parkingId, selectedFile } = req.body;

  try {
    const query = `
      INSERT INTO parking_system_coordinator_details (name, number, email, parking_area, group_name, parking_id, selected_file_name, selected_file_size, selected_file_data)
      VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)
      RETURNING *;
    `;
    const values = [name, number, email, parkingArea, groupName, parkingId, selectedFile.name, selectedFile.size, selectedFile.data];

    const result = await pool.query(query, values);
    res.status(200).json({ message: 'Coordinator details saved successfully', data: result.rows[0] });
  } catch (err) {
    console.error(err.message);
    res.status(500).json({ message: 'Failed to save coordinator details' });
  }
});

// API for bike entry (IN)
app.post('/parking_system_api/bike-entry', async (req, res) => {
  const { number_plate } = req.body;
  const entryTime = new Date();

  try {
    const query = `INSERT INTO parking_system_bike_parking (number_plate, entry_time) VALUES ($1, $2) RETURNING *`;
    const result = await pool.query(query, [number_plate, entryTime]);
    res.status(200).json({ message: 'Bike entry recorded', data: result.rows[0] });
  } catch (err) {
    console.error(err.message);
    res.status(500).json({ message: 'Failed to record bike entry' });
  }
});

// API for bike exit (OUT) and calculate payment
app.post('/parking_system_api/bike-exit', async (req, res) => {
  const { number_plate } = req.body;
  const exitTime = new Date();
  const hourlyRate = 10; // Set a fixed hourly rate

  try {
    const query = `SELECT * FROM parking_system_bike_parking WHERE number_plate = $1 AND exit_time IS NULL LIMIT 1`;
    const result = await pool.query(query, [number_plate]);

    if (result.rows.length === 0) {
      return res.status(404).json({ message: 'No entry record found for this bike' });
    }

    const entryTime = result.rows[0].entry_time;
    const diffHours = Math.abs(new Date(exitTime) - new Date(entryTime)) / 36e5;
    const charge = diffHours * hourlyRate;

    const updateQuery = `
      UPDATE parking_system_bike_parking
      SET exit_time = $1, total_hours = $2, charge = $3
      WHERE number_plate = $4 AND exit_time IS NULL
      RETURNING *`;
    const updateResult = await pool.query(updateQuery, [exitTime, diffHours, charge, number_plate]);

    res.status(200).json({ message: 'Bike exit recorded, payment calculated', data: updateResult.rows[0] });
  } catch (err) {
    console.error(err.message);
    res.status(500).json({ message: 'Failed to record bike exit and calculate payment' });
  }
});

app.listen(port, () => {
  console.log(`Server running on http://localhost:${port}`);
});
