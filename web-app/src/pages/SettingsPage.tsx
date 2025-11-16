import './SettingsPage.css';

export default function SettingsPage() {
  return (
    <div className="settings-page">
      <h2>Settings</h2>

      <section className="settings-section">
        <h3>Project Types</h3>
        <div className="settings-item">
          <button className="settings-link">
            Manage Big Project Types (0)
          </button>
        </div>
        <div className="settings-item">
          <button className="settings-link">
            Manage Micro Project Types (0)
          </button>
        </div>
      </section>

      <section className="settings-section">
        <h3>Tracker Types</h3>
        <div className="settings-item">
          <button className="settings-link">
            Manage Daily Trackers (0)
          </button>
        </div>
      </section>

      <section className="settings-section">
        <h3>Data Management</h3>
        <div className="settings-item">
          <button className="settings-link">
            Export Data (JSON/CSV)
          </button>
        </div>
        <div className="settings-item">
          <button className="settings-link">
            Import Data
          </button>
        </div>
        <div className="settings-item">
          <button className="settings-link">
            Backup Database
          </button>
        </div>
      </section>

      <section className="settings-section">
        <h3>Appearance</h3>
        <div className="settings-item">
          <label htmlFor="theme-select">Theme:</label>
          <select id="theme-select" className="settings-select">
            <option value="light">Light</option>
            <option value="dark">Dark</option>
          </select>
        </div>
      </section>
    </div>
  );
}
