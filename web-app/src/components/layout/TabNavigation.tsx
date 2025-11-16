import { NavLink } from 'react-router-dom';
import './TabNavigation.css';

export default function TabNavigation() {
  return (
    <nav className="tab-navigation">
      <NavLink
        to="/projects"
        className={({ isActive }) => isActive ? 'tab-link active' : 'tab-link'}
      >
        Projects
      </NavLink>
      <NavLink
        to="/trackers"
        className={({ isActive }) => isActive ? 'tab-link active' : 'tab-link'}
      >
        Trackers
      </NavLink>
    </nav>
  );
}
