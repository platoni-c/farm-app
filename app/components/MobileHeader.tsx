"use client"
import { Menu } from "lucide-react";

interface MobileHeaderProps {
    onMenuClick: () => void;
}

const MobileHeader = ({ onMenuClick }: MobileHeaderProps) => {
    return (
        <header className="lg:hidden sticky top-0 bg-white border-b border-neutral-100 h-16 px-4 flex items-center justify-between z-30 shadow-sm">
            <div className="font-extrabold text-lg text-neutral-900 tracking-tight">
                SAMUEL&#39;S FARM
            </div>
            <button
                onClick={onMenuClick}
                className="p-2 text-neutral-500 hover:bg-neutral-50 rounded-lg transition-colors"
                aria-label="Toggle menu"
            >
                <Menu className="w-6 h-6" />
            </button>
        </header>
    );
};

export default MobileHeader;
