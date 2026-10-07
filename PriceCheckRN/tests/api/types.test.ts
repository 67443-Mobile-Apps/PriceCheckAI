import type { APIItem } from '../../src/api/types';

const items = require('../../assets/prices.json') as APIItem[];

describe('APIItem decoding', () => {
  it('bundled prices.json matches APIItem[]', () => {
    expect(Array.isArray(items)).toBe(true);
    expect(items.length).toBe(6);

    const first = items[0];
    expect(first.barcode).toBe('037000127913');
    expect(first.item).toBe('Charmin Soft 12 Mega Rolls');
    expect(first.prices.length).toBe(2);
    expect(first.prices[0].location).toBe('Target');
    expect(first.prices[0].price).toBe(14.79);
    expect(first.prices[0].daysAgo).toBe(3);
  });

  it('every entry has a non-empty prices array', () => {
    for (const item of items) {
      expect(item.prices.length).toBeGreaterThan(0);
    }
  });
});
