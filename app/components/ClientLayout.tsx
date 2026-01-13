"use client"
import { useState } from "react";
import SideBar from "@/app/components/SideBar";
import MobileHeader from "@/app/components/MobileHeader";
import { usePathname } from "next/navigation";

export default function ClientLayout({
    children,
}: {
    children: React.ReactNode;
}) {
    const [isSidebarOpen, setIsSidebarOpen] = useState(false);
    const pathname = usePathname();
    const isAuthOrLandingPage = pathname === "/" || pathname === "/login" || pathname === "/register";

    return (
        <div className="flex min-h-screen bg-neutral-50 text-neutral-900">
            {!isAuthOrLandingPage && (
                <SideBar isOpen={isSidebarOpen} onClose={() => setIsSidebarOpen(false)} />
            )}
            <div className="flex-1 flex flex-col min-w-0 min-h-screen">
                {!isAuthOrLandingPage && (
                    <MobileHeader onMenuClick={() => setIsSidebarOpen(true)} />
                )}
                <main className="flex-1 overflow-x-hidden">
                    <div className={isAuthOrLandingPage ? "" : "p-4 md:p-8 max-w-7xl mx-auto"}>
                        {children}
                    </div>
                </main>
            </div>
        </div>
    );
}
