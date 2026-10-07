import { makeMockPriceAPI } from '../../src/api/priceAPI';
import type { APIItem } from '../../src/api/types';

const sample: APIItem[] = [
  {
    barcode: '037000127913',
    item: 'Charmin Soft 12 Mega Rolls',
    prices: [
      { location: 'Target', price: 14.79, daysAgo: 3 },
      { location: 'Giant Eagle', price: 14.95, daysAgo: 5 },
    ],
  },
  {
    barcode: '034000111206',
    item: 'Hershey Miniatures 17.6oz',
    prices: [{ location: 'Giant Eagle', price: 5.89, daysAgo: 6 }],
  },
];

const makeAPI = () => makeMockPriceAPI(() => sample);

describe('MockPriceAPI', () => {
  it('lookup: known barcode at known location returns price', async () => {
    const api = makeAPI();
    const result = await api.lookup('037000127913', 'Target');
    expect(result).not.toBeNull();
    expect(result!.itemName).toBe('Charmin Soft 12 Mega Rolls');
    expect(result!.price).toBe(14.79);
    expect(result!.location).toBe('Target');
  });

  it('lookup: known barcode at absent location returns null', async () => {
    const api = makeAPI();
    expect(await api.lookup('034000111206', 'Target')).toBeNull();
  });

  it('lookup: unknown barcode returns null', async () => {
    const api = makeAPI();
    expect(await api.lookup('999999999999', 'Target')).toBeNull();
  });

  it('knownLocations returns sorted unique chains', async () => {
    const api = makeAPI();
    expect(await api.knownLocations()).toEqual(['Giant Eagle', 'Target']);
  });

  it('allBarcodes is sorted alphabetically by item name', async () => {
    const api = makeAPI();
    const entries = await api.allBarcodes();
    expect(entries.map((e) => e.item)).toEqual([
      'Charmin Soft 12 Mega Rolls',
      'Hershey Miniatures 17.6oz',
    ]);
  });
});
