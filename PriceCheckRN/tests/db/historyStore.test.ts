import { makeTestDb } from './testDb';
import { createHistoryStore } from '../../src/db/historyStore';
import type { PriceLookup } from '../../src/api/types';

const lookup = (overrides: Partial<PriceLookup> = {}): PriceLookup => ({
  barcode: '037000127913',
  itemName: 'Charmin Soft 12 Mega Rolls',
  location: 'Target',
  price: 14.79,
  date: new Date(),
  ...overrides,
});

describe('HistoryStore', () => {
  it('saving same (barcode, location, day) twice leaves one row with latest price', () => {
    const store = createHistoryStore(makeTestDb());
    const today = new Date();

    store.save(lookup({ price: 14.79 }), today);
    store.save(lookup({ price: 13.99 }), today);

    const all = store.allObservations();
    expect(all).toHaveLength(1);
    expect(all[0].price).toBe(13.99);
  });

  it('saving different locations on same day keeps both rows', () => {
    const store = createHistoryStore(makeTestDb());
    const today = new Date();

    store.save(lookup({ location: 'Target', price: 14.79 }), today);
    store.save(lookup({ location: 'Giant Eagle', price: 14.95 }), today);

    expect(store.allObservations()).toHaveLength(2);
  });

  it('purge removes observations older than cutoff', () => {
    const store = createHistoryStore(makeTestDb());
    const now = new Date();
    const old = new Date(now.getTime() - 100 * 86_400_000);
    const recent = new Date(now.getTime() - 5 * 86_400_000);

    store.save(lookup({ barcode: 'A' }), old);
    store.save(lookup({ barcode: 'B' }), recent);

    store.purgeOlderThan(90, now);

    const all = store.allObservations();
    expect(all).toHaveLength(1);
    expect(all[0].barcode).toBe('B');
  });

  it('allObservations is sorted newest-first', () => {
    const store = createHistoryStore(makeTestDb());
    const now = new Date();
    const older = new Date(now.getTime() - 10 * 86_400_000);
    const newer = new Date(now.getTime() - 1 * 86_400_000);

    store.save(lookup({ barcode: 'A' }), older);
    store.save(lookup({ barcode: 'B' }), newer);

    expect(store.allObservations().map((o) => o.barcode)).toEqual(['B', 'A']);
  });
});
