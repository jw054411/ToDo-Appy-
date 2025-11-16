import './ProjectsPage.css';

export default function ProjectsPage() {
  return (
    <div className="projects-page">
      <div className="page-header">
        <h2>Big Projects</h2>
        <button className="btn-primary">+ New Project</button>
      </div>

      <div className="projects-list">
        <div className="empty-state">
          <p>No projects yet</p>
          <p className="empty-state-hint">
            Create your first project to start tracking maintenance and costs
          </p>
        </div>
      </div>

      <div className="page-header">
        <h2>Micro Projects</h2>
        <button className="btn-primary">+ New Micro</button>
      </div>

      <div className="projects-list">
        <div className="empty-state">
          <p>No micro projects yet</p>
          <p className="empty-state-hint">
            Track smaller items like light bulbs, filters, and subscriptions
          </p>
        </div>
      </div>
    </div>
  );
}
