import './TrackersPage.css';

export default function TrackersPage() {
  const today = new Date().toLocaleDateString('en-US', {
    year: 'numeric',
    month: 'long',
    day: 'numeric'
  });

  return (
    <div className="trackers-page">
      <div className="page-header">
        <h2>Daily Trackers - {today}</h2>
        <button className="btn-primary">+ Add Tracker</button>
      </div>

      <div className="trackers-list">
        <div className="empty-state">
          <p>No trackers configured yet</p>
          <p className="empty-state-hint">
            Create trackers for habits like water intake, exercise, sleep, and more
          </p>
        </div>
      </div>
    </div>
  );
}
