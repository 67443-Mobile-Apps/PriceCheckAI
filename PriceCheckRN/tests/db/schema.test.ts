import { makeTestDb } from './testDb';
import { priceObservations } from '../../src/db/schema';

describe('priceObservations schema', () => {
  it('inserts and reads back a row with correct field types', () => {
    const db = makeTestDb();
    const now = new Date();

    db.insert(priceObservations)
      .values({
        barcode: '037000127913',
        itemName: 'Charmin Soft 12 Mega Rolls',
        location: 'Target',
        price: 14.79,
        date: now,
        dayKey: '2026-10-07',
      })
      .run();

    const rows = db.select().from(priceObservations).all();
    expect(rows).toHaveLength(1);
    expect(rows[0].barcode).toBe('037000127913');
    expect(rows[0].itemName).toBe('Charmin Soft 12 Mega Rolls');
    expect(rows[0].price).toBe(14.79);
    expect(rows[0].date).toBeInstanceOf(Date);
    expect(rows[0].dayKey).toBe('2026-10-07');
  });

  it('enforces unique index on (barcode, location, dayKey)', () => {
    const db = makeTestDb();
    const base = {
      barcode: 'A',
      itemName: 'Alpha',
      location: 'Target',
      price: 1.0,
      date: new Date(),
      dayKey: '2026-10-07',
    };

    db.insert(priceObservations).values(base).run();
    expect(() => db.insert(priceObservations).values(base).run()).toThrow();
  });
});
