import { sqliteTable, integer, text, real, uniqueIndex } from 'drizzle-orm/sqlite-core';

export const priceObservations = sqliteTable(
  'price_observations',
  {
    id: integer('id').primaryKey({ autoIncrement: true }),
    barcode: text('barcode').notNull(),
    itemName: text('item_name').notNull(),
    location: text('location').notNull(),
    price: real('price').notNull(),
    date: integer('date', { mode: 'timestamp' }).notNull(),
    dayKey: text('day_key').notNull(),
  },
  (t) => [uniqueIndex('obs_barcode_loc_day').on(t.barcode, t.location, t.dayKey)],
);

export type PriceObservation = typeof priceObservations.$inferSelect;
export type NewPriceObservation = typeof priceObservations.$inferInsert;

export const CREATE_TABLE_SQL = `
  CREATE TABLE IF NOT EXISTS price_observations (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    barcode TEXT NOT NULL,
    item_name TEXT NOT NULL,
    location TEXT NOT NULL,
    price REAL NOT NULL,
    date INTEGER NOT NULL,
    day_key TEXT NOT NULL
  );
  CREATE UNIQUE INDEX IF NOT EXISTS obs_barcode_loc_day
    ON price_observations(barcode, location, day_key);
`;
