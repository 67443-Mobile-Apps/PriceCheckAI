import { desc, lt, and, eq } from 'drizzle-orm';
import type { BaseSQLiteDatabase } from 'drizzle-orm/sqlite-core';
import { priceObservations, type PriceObservation } from './schema';
import type { PriceLookup } from '../api/types';

export type HistoryDb = BaseSQLiteDatabase<'sync', unknown, Record<string, unknown>>;

export function createHistoryStore(db: HistoryDb) {
  return {
    save(lookup: PriceLookup, when: Date = new Date()): void {
      const dayKey = toDayKey(when);
      db.insert(priceObservations)
        .values({
          barcode: lookup.barcode,
          itemName: lookup.itemName,
          location: lookup.location,
          price: lookup.price,
          date: when,
          dayKey,
        })
        .onConflictDoUpdate({
          target: [priceObservations.barcode, priceObservations.location, priceObservations.dayKey],
          set: {
            price: lookup.price,
            itemName: lookup.itemName,
            date: when,
          },
        })
        .run();
    },

    allObservations(): PriceObservation[] {
      return db
        .select()
        .from(priceObservations)
        .orderBy(desc(priceObservations.date))
        .all() as PriceObservation[];
    },

    purgeOlderThan(days: number, now: Date = new Date()): void {
      const cutoff = new Date(now.getTime() - days * 86_400_000);
      db.delete(priceObservations).where(lt(priceObservations.date, cutoff)).run();
    },

    findByKey(barcode: string, location: string, dayKey: string): PriceObservation | null {
      const rows = db
        .select()
        .from(priceObservations)
        .where(
          and(
            eq(priceObservations.barcode, barcode),
            eq(priceObservations.location, location),
            eq(priceObservations.dayKey, dayKey),
          ),
        )
        .all();
      return (rows[0] as PriceObservation) ?? null;
    },
  };
}

export type HistoryStore = ReturnType<typeof createHistoryStore>;

export function toDayKey(date: Date): string {
  const y = date.getFullYear();
  const m = String(date.getMonth() + 1).padStart(2, '0');
  const d = String(date.getDate()).padStart(2, '0');
  return `${y}-${m}-${d}`;
}
