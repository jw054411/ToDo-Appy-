import { BrowserRouter, Routes, Route, Navigate } from 'react-router-dom';
import { useState } from 'react';
import Layout from './components/layout/Layout';
import ProjectsPage from './pages/ProjectsPage';
import TrackersPage from './pages/TrackersPage';
import SettingsPage from './pages/SettingsPage';
import './App.css';

function App() {
  const [showSettings, setShowSettings] = useState(false);

  const handleSettingsClick = () => {
    setShowSettings(true);
  };

  const handleCloseSettings = () => {
    setShowSettings(false);
  };

  return (
    <BrowserRouter>
      {showSettings ? (
        <div className="settings-overlay">
          <div className="settings-modal">
            <div className="settings-modal-header">
              <h2>Settings</h2>
              <button className="close-button" onClick={handleCloseSettings}>
                ✕
              </button>
            </div>
            <div className="settings-modal-content">
              <SettingsPage />
            </div>
          </div>
        </div>
      ) : null}

      <Routes>
        <Route path="/" element={<Layout onSettingsClick={handleSettingsClick} />}>
          <Route index element={<Navigate to="/projects" replace />} />
          <Route path="projects" element={<ProjectsPage />} />
          <Route path="trackers" element={<TrackersPage />} />
        </Route>
      </Routes>
    </BrowserRouter>
  );
}

export default App;
