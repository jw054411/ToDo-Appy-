import { Outlet } from 'react-router-dom';
import Header from './Header';
import TabNavigation from './TabNavigation';
import './Layout.css';

interface LayoutProps {
  onSettingsClick: () => void;
}

export default function Layout({ onSettingsClick }: LayoutProps) {
  return (
    <div className="app-layout">
      <Header onSettingsClick={onSettingsClick} />
      <TabNavigation />
      <main className="app-content">
        <Outlet />
      </main>
    </div>
  );
}
