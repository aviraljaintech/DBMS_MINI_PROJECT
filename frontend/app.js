const API_URL = 'http://localhost:3000/api';
let chartInstance = null;

document.addEventListener('DOMContentLoaded', () => {
    fetchData();

    document.getElementById('refresh-btn').addEventListener('click', () => {
        fetchData();
        // Optional: simulate adding a random reading on refresh to demonstrate real-time alert/graph updates
        // simulateRandomReading();
    });
});

async function fetchData() {
    try {
        await fetchAlerts();
        await fetchReadings();
    } catch (error) {
        console.error("Error fetching data:", error);
    }
}

async function fetchAlerts() {
    try {
        const res = await fetch(`${API_URL}/alerts`);
        const alerts = await res.json();
        
        const container = document.getElementById('alerts-container');
        container.innerHTML = '';

        if (!alerts || alerts.length === 0) {
            container.innerHTML = '<p style="color: #27ae60; font-weight: bold;">✅ No active alerts. Air quality is within safe limits!</p>';
            return;
        }

        alerts.forEach(alert => {
            const div = document.createElement('div');
            div.className = 'alert-card';
            const date = new Date(alert.alert_time).toLocaleString();
            div.innerHTML = `
                <span><strong>${alert.location}:</strong> ${alert.message}</span>
                <span style="font-size: 0.9em; opacity: 0.8;">${date}</span>
            `;
            container.appendChild(div);
        });
    } catch (err) {
        document.getElementById('alerts-container').innerHTML = '<p>Error loading alerts. Make sure backend is running.</p>';
    }
}

async function fetchReadings() {
    try {
        const res = await fetch(`${API_URL}/readings`);
        const readings = await res.json();
        
        // Update Table
        const tbody = document.getElementById('readings-table-body');
        tbody.innerHTML = '';

        if (!readings || readings.length === 0) {
            tbody.innerHTML = '<tr><td colspan="5">No data available</td></tr>';
            return;
        }

        readings.forEach(r => {
            const tr = document.createElement('tr');
            const date = new Date(r.timestamp).toLocaleString();
            tr.innerHTML = `
                <td>${date}</td>
                <td>${r.location}, ${r.city}</td>
                <td>${r.pollutant}</td>
                <td><strong>${r.value}</strong></td>
                <td>${r.unit}</td>
            `;
            tbody.appendChild(tr);
        });

        // Update Chart (Showing recent 15 readings)
        updateChart(readings.slice(0, 15).reverse());
    } catch (err) {
        document.getElementById('readings-table-body').innerHTML = '<tr><td colspan="5">Error loading data. Make sure backend is running.</td></tr>';
    }
}

function updateChart(data) {
    const ctx = document.getElementById('pollutionChart').getContext('2d');
    
    const labels = data.map(d => {
        const date = new Date(d.timestamp);
        return `${date.getHours()}:${String(date.getMinutes()).padStart(2, '0')} (${d.pollutant})`;
    });
    const values = data.map(d => d.value);
    
    if (chartInstance) {
        chartInstance.destroy();
    }

    chartInstance = new Chart(ctx, {
        type: 'line',
        data: {
            labels: labels,
            datasets: [{
                label: 'Recent Pollutant Readings',
                data: values,
                borderColor: '#3498db',
                backgroundColor: 'rgba(52, 152, 219, 0.2)',
                borderWidth: 2,
                pointBackgroundColor: '#2980b9',
                fill: true,
                tension: 0.4
            }]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            scales: {
                y: { 
                    beginAtZero: true,
                    title: {
                        display: true,
                        text: 'Value'
                    }
                },
                x: {
                    title: {
                        display: true,
                        text: 'Time & Pollutant'
                    }
                }
            },
            plugins: {
                legend: {
                    position: 'top',
                }
            }
        }
    });
}
