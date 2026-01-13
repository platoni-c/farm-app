"use server"

import { createClient } from "@/supabase/server";
import { revalidatePath } from "next/cache";

export async function harvestCrop(cropId: string) {
    const supabase = await createClient();

    const { error } = await supabase
        .from('crops')
        .update({
            status: 'Completed',
            actual_harvest_date: new Date().toISOString()
        })
        .eq('id', cropId);

    if (error) {
        throw new Error(error.message);
    }

    revalidatePath('/dashboard');
    revalidatePath('/crops');
    revalidatePath(`/crops/${cropId}`);
}

export async function recordMortality(cropId: string, count: number, notes?: string) {
    const supabase = await createClient();
    const today = new Date().toISOString().split('T')[0];

    // Check if a log already exists for today
    const { data: existingLog } = await supabase
        .from('daily_logs')
        .select('id, mortality, notes')
        .eq('crop_id', cropId)
        .eq('log_date', today)
        .maybeSingle();

    if (existingLog) {
        // Increment mortality
        const { error } = await supabase
            .from('daily_logs')
            .update({
                mortality: (existingLog.mortality || 0) + count,
                notes: notes ? (existingLog.notes ? `${existingLog.notes}\n${notes}` : notes) : existingLog.notes
            })
            .eq('id', existingLog.id);

        if (error) throw new Error(error.message);
    } else {
        // Create new log
        const { error } = await supabase
            .from('daily_logs')
            .insert({
                crop_id: cropId,
                log_date: today,
                mortality: count,
                notes: notes,
                feed_consumed_kg: 0 // Default
            });

        if (error) throw new Error(error.message);
    }

    revalidatePath('/dashboard');
    revalidatePath('/crops');
    revalidatePath(`/crops/${cropId}`);
}
