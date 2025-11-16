import './Header.css';

interface HeaderProps {
  onSettingsClick: () => void;
}

export default function Header({ onSettingsClick }: HeaderProps) {
  return (
    <header className="app-header">
      <h1 className="app-title">Life Tracker</h1>
      <button
        className="settings-button"
        onClick={onSettingsClick}
        aria-label="Settings"
      >
        ⚙
      </button>
    </header>
  );
}
